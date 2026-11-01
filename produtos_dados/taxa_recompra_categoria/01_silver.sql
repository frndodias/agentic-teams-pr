-- objeto: s_identidade_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_identidade_comprador AS
-- Identidade por loja via componentes conectados (propagação do menor comprador_id, 10 passes; convergência validada em consulta).
-- Elos: CPF válido (11 dígitos, não placeholder/dígitos repetidos/12345678909) e e-mail normalizado (trim+lower, sem espaços).
-- CPF inválido/placeholder = ausente. Chaves nulas NÃO formam elo (cada cadastro vira partição própria).
-- E-mail normalizado é SEMPRE elo dentro da loja, inclusive quando aparece com 2+ CPFs (contrato: mesma chave na mesma loja = mesmo comprador).
-- Sem dados pessoais na saída: apenas flags e hash.
WITH base AS (
  SELECT comprador_id, loja_id,
         CASE WHEN length(regexp_replace(coalesce(cpf,''),'[^0-9]','')) = 11
               AND NOT regexp_replace(cpf,'[^0-9]','') RLIKE '^(\\d)\\1{10}$'
               AND regexp_replace(cpf,'[^0-9]','') <> '12345678909'
              THEN regexp_replace(cpf,'[^0-9]','') END AS cpf_n,
         CASE WHEN trim(coalesce(email,'')) <> '' THEN lower(regexp_replace(email,'\\s','')) END AS email_n,
         CASE WHEN lower(coalesce(nome,'')) LIKE '%test%' OR lower(coalesce(email,'')) LIKE '%test%' THEN 1 ELSE 0 END AS flag_teste
  FROM fc_catalog.ecommerce.s_compradores
),
l0 AS (
  SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n,
         coalesce(cpf_n, concat('#', comprador_id)) AS k_cpf,
         coalesce(email_n, concat('#', comprador_id)) AS k_email,
         comprador_id AS lbl
  FROM base
),
l1 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l0),
l2 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l1),
l3 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l2),
l4 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l3),
l5 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l4),
l6 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l5),
l7 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l6),
l8 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l7),
l9 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l8),
l10 AS (SELECT comprador_id, loja_id, flag_teste, cpf_n, email_n, k_cpf, k_email,
         least(min(lbl) OVER (PARTITION BY loja_id, k_cpf), min(lbl) OVER (PARTITION BY loja_id, k_email)) AS lbl FROM l9)
SELECT comprador_id, loja_id, flag_teste,
       (cpf_n IS NULL AND email_n IS NULL) AS sem_chave,
       lbl AS componente_id,
       sha2(concat(loja_id, '|', CAST(lbl AS STRING)), 256) AS comprador_sk
FROM l10;

-- objeto: s_pedidos_pagos_categoria
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_categoria AS
WITH pag AS (
  SELECT DISTINCT pedido_id FROM fc_catalog.ecommerce.s_pagamentos WHERE status IN ('aprovado','estornado')
),
cb AS (
  SELECT DISTINCT pedido_id FROM fc_catalog.ecommerce.s_disputas WHERE tipo = 'chargeback' AND status = 'perdida'
),
ped AS (
  SELECT p.pedido_id, p.loja_id, p.data_hora_pedido, i.comprador_sk
  FROM fc_catalog.ecommerce.s_pedidos p
  JOIN fc_catalog.agentic_teams_sandbox.s_identidade_comprador i
    ON i.comprador_id = p.comprador_id AND i.loja_id = p.loja_id
  JOIN pag ON pag.pedido_id = p.pedido_id
  LEFT ANTI JOIN cb ON cb.pedido_id = p.pedido_id
  WHERE to_date(p.data_hora_pedido) BETWEEN DATE'2026-08-03' AND DATE'2026-11-01'
    AND p.status_pedido NOT IN ('cancelado','pendente')
    AND p.valor_total > 1.00
    AND i.flag_teste = 0
    AND i.sem_chave = false
),
prod AS (
  SELECT loja_id, produto_id, max(CASE WHEN categoria IS NOT NULL AND trim(categoria) <> '' THEN trim(categoria) END) AS categoria
  FROM fc_catalog.ecommerce.s_produtos
  GROUP BY loja_id, produto_id
),
cat AS (
  SELECT DISTINCT it.pedido_id, pr.loja_id, coalesce(pr.categoria, 'Sem categoria') AS categoria
  FROM fc_catalog.ecommerce.s_itens_pedido it
  JOIN prod pr ON pr.produto_id = it.produto_id
)
SELECT ped.pedido_id, ped.loja_id, ped.comprador_sk,
       coalesce(cat.categoria, 'Sem categoria') AS categoria, ped.data_hora_pedido
FROM ped
LEFT JOIN cat ON cat.pedido_id = ped.pedido_id AND cat.loja_id = ped.loja_id;

-- objeto: s_compradores_recompra_categoria
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_compradores_recompra_categoria AS
WITH pedidos AS (
  SELECT loja_id, comprador_sk, pedido_id, min(data_hora_pedido) AS data_hora_pedido
  FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_categoria
  GROUP BY loja_id, comprador_sk, pedido_id
),
tot AS (
  SELECT loja_id, comprador_sk, count(*) AS total_pedidos,
         min_by(pedido_id, struct(data_hora_pedido, pedido_id)) AS primeiro_pedido_id
  FROM pedidos
  GROUP BY loja_id, comprador_sk
)
SELECT t.loja_id, t.comprador_sk, c.categoria AS categoria_primeiro_pedido,
       t.total_pedidos, CASE WHEN t.total_pedidos >= 2 THEN 1 ELSE 0 END AS recorrente
FROM tot t
JOIN (SELECT DISTINCT pedido_id, loja_id, categoria FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_categoria) c
  ON c.pedido_id = t.primeiro_pedido_id AND c.loja_id = t.loja_id;
