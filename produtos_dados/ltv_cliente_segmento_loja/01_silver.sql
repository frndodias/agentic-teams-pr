-- objeto: s_ltv_comprador_loja
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_ltv_comprador_loja
COMMENT 'LTV por comprador unificado e loja: receita bruta (valor_total) acumulada de pedidos pagos válidos em todo o histórico de s_pedidos. Uma linha por loja_id + comprador_hash. Sem dados pessoais. Segmento e status são atuais (s_lojas).'
AS
WITH pagamento_ok AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_pagamentos
  WHERE status IN ('aprovado', 'estornado')
),
chargeback_perdido AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_disputas
  WHERE tipo = 'chargeback' AND status = 'perdida'
),
teste AS (
  SELECT loja_id, comprador_id
  FROM fc_catalog.ecommerce.s_compradores
  WHERE lower(coalesce(nome, '')) LIKE '%test%'
     OR lower(coalesce(email, '')) LIKE '%test%'
),
pedidos_validos AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, p.data_hora_pedido, p.valor_total
  FROM fc_catalog.ecommerce.s_pedidos p
  JOIN pagamento_ok pg ON pg.pedido_id = p.pedido_id
  LEFT ANTI JOIN chargeback_perdido cb ON cb.pedido_id = p.pedido_id
  LEFT ANTI JOIN teste t ON t.loja_id = p.loja_id AND t.comprador_id = p.comprador_id
  WHERE p.status_pedido NOT IN ('cancelado', 'pendente')
    AND p.valor_total > 1.00
)
SELECT
  pv.loja_id,
  i.comprador_hash,
  l.segmento,
  l.status AS status_loja,
  COUNT(DISTINCT pv.pedido_id) AS qtd_pedidos,
  SUM(pv.valor_total) AS receita_total,
  MIN(CAST(pv.data_hora_pedido AS DATE)) AS data_primeira_compra,
  MAX(CAST(pv.data_hora_pedido AS DATE)) AS data_ultima_compra
FROM pedidos_validos pv
JOIN fc_catalog.ecommerce.s_identidade_comprador i
  ON i.loja_id = pv.loja_id AND i.comprador_id = pv.comprador_id
JOIN fc_catalog.ecommerce.s_lojas l ON l.loja_id = pv.loja_id
WHERE i.comprador_hash IS NOT NULL
GROUP BY pv.loja_id, i.comprador_hash, l.segmento, l.status;
