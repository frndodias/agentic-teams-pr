-- objeto: s_ltv_comprador_loja
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_ltv_comprador_loja AS
WITH pedidos_validos AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, p.valor_total, p.data_hora_pedido
  FROM fc_catalog.ecommerce.s_pedidos p
  WHERE p.status_pedido NOT IN ('cancelado','pendente')
    AND p.valor_total > 1.00
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos g
                WHERE g.pedido_id = p.pedido_id AND g.status IN ('aprovado','estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
)
SELECT
  l.loja_id,
  i.comprador_sk,
  l.segmento,
  l.status AS status_loja,
  SUM(pv.valor_total) AS receita_total,
  COUNT(DISTINCT pv.pedido_id) AS pedidos_pagos,
  MIN(CAST(pv.data_hora_pedido AS DATE)) AS data_primeira_compra,
  date_trunc('MONTH', MIN(CAST(pv.data_hora_pedido AS DATE))) AS mes_primeira_compra
FROM pedidos_validos pv
JOIN fc_catalog.agentic_teams_sandbox.s_identidade_comprador i
  ON i.comprador_id = pv.comprador_id AND i.loja_id = pv.loja_id AND i.flag_teste = 0
JOIN fc_catalog.ecommerce.s_lojas l ON l.loja_id = pv.loja_id
GROUP BY l.loja_id, i.comprador_sk, l.segmento, l.status;
