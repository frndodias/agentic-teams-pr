-- objeto: s_identidade_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_identidade_comprador AS
WITH base0 AS (
  SELECT comprador_id, loja_id,
         regexp_replace(COALESCE(cpf, ''), '[^0-9]', '') AS cpf_d,
         NULLIF(lower(trim(COALESCE(email, ''))), '') AS email_n,
         lower(COALESCE(nome, '')) AS nome_norm
  FROM fc_catalog.ecommerce.s_compradores
),
base1 AS (
  SELECT *,
         CASE WHEN length(cpf_d) = 11 THEN
           aggregate(transform(sequence(1,9), i -> int(substr(cpf_d,i,1)) * (11-i)), 0, (a,x) -> a + x) END AS s1,
         CASE WHEN length(cpf_d) = 11 THEN
           aggregate(transform(sequence(1,10), i -> int(substr(cpf_d,i,1)) * (12-i)), 0, (a,x) -> a + x) END AS s2
  FROM base0
),
base AS (
  SELECT comprador_id, loja_id, email_n, nome_norm,
         -- CPF inválido/placeholder vira NULL: comprimento != 11, 11 dígitos iguais, 12345678909 ou dígito verificador inválido
         CASE WHEN length(cpf_d) = 11
                AND cpf_d NOT RLIKE '^(\\d)\\1{10}$'
                AND cpf_d NOT IN ('00000000000','12345678909')
                AND ((s1*10) % 11) % 10 = int(substr(cpf_d,10,1))
                AND ((s2*10) % 11) % 10 = int(substr(cpf_d,11,1))
              THEN cpf_d END AS cpf_n
  FROM base1
)
-- Regra do contrato: CPF válido (só dígitos); sem CPF válido, e-mail normalizado. Sem ponte transitiva CPF<->e-mail
-- (o mesmo e-mail aparece com vários CPFs distintos na mesma loja; unir geraria falsos "super compradores").
SELECT comprador_id, loja_id,
       sha2(concat(loja_id, '|', CASE WHEN cpf_n IS NOT NULL THEN concat('c:', cpf_n) ELSE concat('e:', email_n) END), 256) AS chave_comprador,
       CASE WHEN cpf_n IS NOT NULL THEN 'cpf' ELSE 'email' END AS tipo_chave,
       (cpf_n IS NULL) AS cpf_invalido_ou_ausente,
       (nome_norm LIKE '%test%' OR COALESCE(email_n, '') LIKE '%test%') AS cadastro_teste
FROM base
WHERE cpf_n IS NOT NULL OR email_n IS NOT NULL;

-- objeto: s_pedidos_pagos_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador AS
WITH ref AS (
  SELECT CAST(MAX(data_hora_pedido) AS DATE) AS data_ref FROM fc_catalog.ecommerce.s_pedidos
),
pag AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_pagamentos
  WHERE status IN ('aprovado', 'estornado')
),
cb_perdido AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_disputas
  WHERE tipo = 'chargeback' AND status = 'perdida'
)
SELECT
  p.pedido_id,
  p.loja_id,
  i.chave_comprador,
  i.tipo_chave,
  CAST(p.data_hora_pedido AS DATE) AS data_pedido,
  p.valor_total,
  p.status_pedido,
  r.data_ref AS data_referencia
FROM fc_catalog.ecommerce.s_pedidos p
CROSS JOIN ref r
JOIN pag ON pag.pedido_id = p.pedido_id
JOIN fc_catalog.agentic_teams_sandbox.s_identidade_comprador i ON i.comprador_id = p.comprador_id AND i.loja_id = p.loja_id
LEFT JOIN cb_perdido cb ON cb.pedido_id = p.pedido_id
WHERE cb.pedido_id IS NULL
  AND p.status_pedido NOT IN ('cancelado', 'pendente')
  AND p.valor_total > 1.00
  AND NOT i.cadastro_teste
  AND CAST(p.data_hora_pedido AS DATE) > date_sub(r.data_ref, 90)
  AND CAST(p.data_hora_pedido AS DATE) <= r.data_ref;
