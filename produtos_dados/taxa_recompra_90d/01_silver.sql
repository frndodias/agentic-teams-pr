-- objeto: s_pedidos_pagos_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador AS
WITH ref AS (
  SELECT CAST(max(data_hora_pedido) AS DATE) AS data_referencia
  FROM fc_catalog.ecommerce.s_pedidos
),
comp AS (
  SELECT comprador_id, loja_id,
         nullif(regexp_replace(coalesce(cpf, ''), '[^0-9]', ''), '') AS cpf_digitos,
         nullif(lower(trim(coalesce(email, ''))), '') AS email_norm,
         lower(coalesce(nome, '')) AS nome_norm
  FROM fc_catalog.ecommerce.s_compradores
),
-- Ponte e-mail -> CPF dentro da loja. So vale quando o e-mail tem exatamente 1 CPF na loja.
-- E-mail com 2+ CPFs (compartilhado/homonimo) e ambiguo: nao liga pessoas diferentes.
email_cpf AS (
  SELECT loja_id, email_norm,
         count(DISTINCT cpf_digitos) AS qtd_cpfs,
         min(cpf_digitos) AS cpf_canonico
  FROM comp
  WHERE email_norm IS NOT NULL AND cpf_digitos IS NOT NULL
  GROUP BY loja_id, email_norm
),
pedidos AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, p.valor_total, p.status_pedido,
         CAST(p.data_hora_pedido AS DATE) AS data_pedido, r.data_referencia
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN ref r
  WHERE CAST(p.data_hora_pedido AS DATE) > date_sub(r.data_referencia, 90)
    AND CAST(p.data_hora_pedido AS DATE) <= r.data_referencia
    AND p.status_pedido NOT IN ('cancelado', 'pendente')
    AND p.valor_total > 1.00
),
pagos AS (
  SELECT p.*
  FROM pedidos p
  WHERE EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos g
                WHERE g.pedido_id = p.pedido_id AND g.status IN ('aprovado', 'estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
ident AS (
  SELECT p.pedido_id, p.loja_id, p.data_pedido, p.data_referencia, p.valor_total, p.status_pedido,
         c.cpf_digitos, c.email_norm, c.nome_norm,
         e.qtd_cpfs, e.cpf_canonico
  FROM pagos p
  JOIN comp c ON c.comprador_id = p.comprador_id AND c.loja_id = p.loja_id
  LEFT JOIN email_cpf e ON e.loja_id = c.loja_id AND e.email_norm = c.email_norm
),
chave AS (
  SELECT *,
         CASE
           WHEN cpf_digitos IS NOT NULL THEN concat('cpf|', cpf_digitos)
           WHEN qtd_cpfs = 1 THEN concat('cpf|', cpf_canonico)
           WHEN email_norm IS NOT NULL THEN concat('email|', email_norm)
         END AS chave_texto,
         CASE
           WHEN cpf_digitos IS NOT NULL THEN 'cpf'
           WHEN qtd_cpfs = 1 THEN 'cpf_via_email'
           WHEN email_norm IS NOT NULL THEN 'email'
         END AS tipo_chave
  FROM ident
)
SELECT pedido_id,
       loja_id,
       sha2(chave_texto, 256) AS chave_comprador,
       tipo_chave,
       data_pedido,
       valor_total,
       status_pedido,
       data_referencia
FROM chave
WHERE chave_texto IS NOT NULL
  AND nome_norm NOT LIKE '%test%'
  AND coalesce(email_norm, '') NOT LIKE '%test%';
