-- objeto: s_pedidos_pagos_trimestre
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_trimestre AS
WITH pag AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_pagamentos
  WHERE status IN ('aprovado','estornado')
),
cb AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_disputas
  WHERE tipo = 'chargeback' AND status = 'perdida'
)
SELECT
  p.pedido_id,
  p.loja_id,
  i.comprador_sk,
  coalesce(l.regiao, 'Não informada') AS regiao,
  p.data_hora_pedido,
  CAST(p.data_hora_pedido AS DATE) AS data_pedido,
  concat(year(p.data_hora_pedido), '-T', quarter(p.data_hora_pedido)) AS trimestre,
  p.status_pedido
FROM fc_catalog.ecommerce.s_pedidos p
JOIN pag ON pag.pedido_id = p.pedido_id
LEFT JOIN cb ON cb.pedido_id = p.pedido_id
JOIN fc_catalog.agentic_teams_sandbox.s_identidade_comprador i
  ON i.comprador_id = p.comprador_id AND i.loja_id = p.loja_id
LEFT JOIN fc_catalog.ecommerce.s_lojas l ON l.loja_id = p.loja_id
WHERE p.status_pedido NOT IN ('cancelado','pendente')
  AND cb.pedido_id IS NULL
  AND p.valor_total > 1.00
  AND coalesce(i.flag_teste, 0) = 0
  AND coalesce(i.sem_chave, false) = false
  AND i.comprador_sk IS NOT NULL;
