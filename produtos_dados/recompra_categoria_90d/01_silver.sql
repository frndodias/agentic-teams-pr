-- objeto: s_recompra_comprador_categoria_90d
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_comprador_categoria_90d
COMMENT 'Pedidos pagos (sem teste) dos últimos 90 dias até a última data com dados de s_pedidos, por loja x comprador_hash x categoria (categoria atual de s_produtos). Sem PII.'
AS
WITH janela AS (
  SELECT max(CAST(data_hora_pedido AS DATE)) AS data_fim,
         date_sub(max(CAST(data_hora_pedido AS DATE)), 89) AS data_inicio
  FROM fc_catalog.ecommerce.s_pedidos
),
ped AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN janela j
  WHERE CAST(p.data_hora_pedido AS DATE) BETWEEN j.data_inicio AND j.data_fim
    AND p.status_pedido NOT IN ('cancelado','pendente')
    AND p.valor_total > 1
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos pg
                WHERE pg.pedido_id = p.pedido_id AND pg.status IN ('aprovado','estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
ped_ok AS (
  SELECT p.pedido_id, p.loja_id, i.comprador_hash
  FROM ped p
  JOIN fc_catalog.ecommerce.s_identidade_comprador i
    ON i.loja_id = p.loja_id AND i.comprador_id = p.comprador_id
  LEFT JOIN fc_catalog.ecommerce.s_compradores c
    ON c.loja_id = p.loja_id AND c.comprador_id = p.comprador_id
  WHERE NOT (lower(coalesce(c.nome,'')) LIKE '%test%' OR lower(coalesce(c.email,'')) LIKE '%test%')
),
cat AS (
  SELECT DISTINCT it.pedido_id, pr.categoria
  FROM fc_catalog.ecommerce.s_itens_pedido it
  JOIN ped_ok po ON po.pedido_id = it.pedido_id
  JOIN fc_catalog.ecommerce.s_produtos pr ON pr.produto_id = it.produto_id
  WHERE pr.categoria IS NOT NULL
)
SELECT po.loja_id,
       po.comprador_hash,
       c.categoria,
       COUNT(DISTINCT po.pedido_id) AS qtd_pedidos_pagos,
       MAX(j.data_inicio) AS data_inicio_janela,
       MAX(j.data_fim) AS data_fim_janela
FROM ped_ok po
JOIN cat c ON c.pedido_id = po.pedido_id
CROSS JOIN janela j
GROUP BY po.loja_id, po.comprador_hash, c.categoria;
