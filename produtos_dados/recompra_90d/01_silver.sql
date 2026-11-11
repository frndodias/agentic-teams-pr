-- objeto: s_recompra_compradores_90d
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_compradores_90d AS
WITH ref AS (
  SELECT CAST(MAX(data_hora_pedido) AS DATE) AS data_referencia
  FROM fc_catalog.ecommerce.s_pedidos
),
pag AS (
  SELECT pedido_id,
         MAX(CASE WHEN status IN ('aprovado','estornado') THEN 1 ELSE 0 END) AS pago
  FROM fc_catalog.ecommerce.s_pagamentos
  GROUP BY pedido_id
),
perdida AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_disputas
  WHERE tipo = 'chargeback' AND status = 'perdida'
),
comp AS (
  SELECT comprador_id, loja_id,
         lower(nome) AS nome_l,
         lower(trim(email)) AS email_n,
         regexp_replace(cpf, '[^0-9]', '') AS cpf_n
  FROM fc_catalog.ecommerce.s_compradores
),
base AS (
  SELECT p.pedido_id, p.loja_id, r.data_referencia,
         CASE WHEN c.cpf_n IS NOT NULL AND c.cpf_n <> '' THEN sha2(c.cpf_n, 256)
              WHEN c.email_n IS NOT NULL AND c.email_n <> '' THEN sha2(c.email_n, 256)
         END AS chave_comprador
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN ref r
  JOIN pag ON pag.pedido_id = p.pedido_id AND pag.pago = 1
  LEFT JOIN perdida pe ON pe.pedido_id = p.pedido_id
  LEFT JOIN comp c ON c.comprador_id = p.comprador_id AND c.loja_id = p.loja_id
  WHERE CAST(p.data_hora_pedido AS DATE) BETWEEN date_sub(r.data_referencia, 89) AND r.data_referencia
    AND p.status_pedido NOT IN ('cancelado','pendente')
    AND pe.pedido_id IS NULL
    AND p.valor_total > 1.00
    AND COALESCE(c.nome_l,'') NOT LIKE '%test%'
    AND COALESCE(c.email_n,'') NOT LIKE '%test%'
)
SELECT loja_id, data_referencia, chave_comprador,
       COUNT(DISTINCT pedido_id) AS qtd_pedidos_pagos
FROM base
WHERE chave_comprador IS NOT NULL
GROUP BY loja_id, data_referencia, chave_comprador;
