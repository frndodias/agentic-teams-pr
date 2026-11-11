-- objeto: s_intervalo_compras_comprador_categoria
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_intervalo_compras_comprador_categoria
COMMENT 'Por loja, comprador_hash e categoria: datas da 1ª e 2ª compra paga (dentro da categoria) e intervalo em dias. Histórico completo de s_pedidos. Categoria atual de s_produtos. Sem PII. Apenas compradores com >=2 pedidos pagos na categoria.'
AS
WITH pedidos_pagos AS (
  SELECT p.pedido_id, p.loja_id, i.comprador_hash, p.data_hora_pedido
  FROM fc_catalog.ecommerce.s_pedidos p
  JOIN fc_catalog.ecommerce.s_identidade_comprador i
    ON i.loja_id = p.loja_id AND i.comprador_id = p.comprador_id
  WHERE p.valor_total > 1.00
    AND p.status_pedido NOT IN ('cancelado', 'pendente')
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos g
                WHERE g.pedido_id = p.pedido_id AND g.status IN ('aprovado', 'estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
pedido_categoria AS (
  SELECT it.pedido_id, pr.categoria
  FROM fc_catalog.ecommerce.s_itens_pedido it
  JOIN fc_catalog.ecommerce.s_produtos pr ON pr.produto_id = it.produto_id
  WHERE pr.categoria IS NOT NULL
  GROUP BY it.pedido_id, pr.categoria
),
base AS (
  SELECT pp.loja_id, pp.comprador_hash, pc.categoria, pp.pedido_id, pp.data_hora_pedido,
         ROW_NUMBER() OVER (PARTITION BY pp.loja_id, pp.comprador_hash, pc.categoria
                            ORDER BY pp.data_hora_pedido, pp.pedido_id) AS ordem
  FROM pedidos_pagos pp
  JOIN pedido_categoria pc ON pc.pedido_id = pp.pedido_id
),
pares AS (
  SELECT loja_id, comprador_hash, categoria,
         MAX(CASE WHEN ordem = 1 THEN pedido_id END) AS pedido_id_primeira_compra,
         MAX(CASE WHEN ordem = 2 THEN pedido_id END) AS pedido_id_segunda_compra,
         MAX(CASE WHEN ordem = 1 THEN data_hora_pedido END) AS ts_primeira_compra,
         MAX(CASE WHEN ordem = 2 THEN data_hora_pedido END) AS ts_segunda_compra
  FROM base
  WHERE ordem <= 2
  GROUP BY loja_id, comprador_hash, categoria
)
SELECT loja_id, comprador_hash, categoria,
       pedido_id_primeira_compra, pedido_id_segunda_compra,
       CAST(ts_primeira_compra AS DATE) AS data_primeira_compra,
       CAST(ts_segunda_compra AS DATE) AS data_segunda_compra,
       DATE_TRUNC('MONTH', CAST(ts_primeira_compra AS DATE)) AS mes_primeira_compra,
       DATEDIFF(CAST(ts_segunda_compra AS DATE), CAST(ts_primeira_compra AS DATE)) AS dias_entre_compras
FROM pares
WHERE pedido_id_segunda_compra IS NOT NULL;
