-- objeto: s_recompra_pedido_categoria
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_pedido_categoria AS
WITH corte AS (
  -- Data de corte parametrizável: por padrão, a última data com pedidos (não "hoje")
  SELECT CAST(max(data_hora_pedido) AS DATE) AS data_corte FROM fc_catalog.ecommerce.s_pedidos
),
pedidos AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, CAST(p.data_hora_pedido AS DATE) AS data_pedido, c.data_corte
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN corte c
  WHERE CAST(p.data_hora_pedido AS DATE) > date_sub(c.data_corte, 90)
    AND CAST(p.data_hora_pedido AS DATE) <= c.data_corte
    AND p.status_pedido NOT IN ('cancelado','pendente')
    AND p.valor_total > 1
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos g
                WHERE g.pedido_id = p.pedido_id AND g.status IN ('aprovado','estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
-- Cadastros normalizados: CPF só dígitos (válido = 11 dígitos, não todos iguais); e-mail trim+lower (válido = formato estrito)
cad AS (
  SELECT comprador_id, loja_id, nome,
    CASE WHEN length(regexp_replace(coalesce(cpf,''), '\\D', '')) = 11
              AND NOT regexp_replace(cpf, '\\D', '') RLIKE '^(\\d)\\1{10}$'
         THEN regexp_replace(cpf, '\\D', '') END AS cpf_n,
    CASE WHEN lower(trim(coalesce(email,''))) RLIKE '^[a-z0-9._%+-]+@[a-z0-9-]+(\\.[a-z0-9-]+)+$'
         THEN lower(trim(email)) END AS email_n,
    lower(coalesce(email,'')) AS email_raw
  FROM fc_catalog.ecommerce.s_compradores
),
-- Pedidos da janela com cadastro normalizado, já sem compradores de teste (nome/e-mail com 'test')
ped_cad AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, p.data_pedido, p.data_corte, cp.cpf_n, cp.email_n
  FROM pedidos p
  JOIN cad cp ON cp.comprador_id = p.comprador_id AND cp.loja_id = p.loja_id
  WHERE NOT (lower(coalesce(cp.nome,'')) LIKE '%test%' OR cp.email_raw LIKE '%test%')
),
-- Mapa e-mail -> CPF por loja, calculado SÓ com compradores da janela (cadastros com CPF e e-mail válidos).
-- Se o e-mail tem 1 CPF: usa esse CPF. Se tem 2+ CPFs: atribui o CPF dominante
-- (mais cadastros na janela; empate -> pedido mais recente; empate -> menor CPF), de forma determinística.
mapa_cpf_email AS (
  SELECT loja_id, email_n, cpf_n, count(DISTINCT comprador_id) AS qtd_cad, max(data_pedido) AS ultimo_pedido
  FROM ped_cad
  WHERE cpf_n IS NOT NULL AND email_n IS NOT NULL
  GROUP BY loja_id, email_n, cpf_n
),
mapa_email AS (
  SELECT loja_id, email_n, cpf_n AS cpf_dominante, qtd_cpf
  FROM (
    SELECT m.*, count(*) OVER (PARTITION BY loja_id, email_n) AS qtd_cpf,
           row_number() OVER (PARTITION BY loja_id, email_n ORDER BY qtd_cad DESC, ultimo_pedido DESC, cpf_n) AS rn
    FROM mapa_cpf_email m
  ) WHERE rn = 1
),
identidade AS (
  SELECT p.pedido_id, p.loja_id, p.data_pedido, p.data_corte,
    CASE
      WHEN p.cpf_n IS NOT NULL THEN concat('cpf:', p.cpf_n)
      WHEN p.email_n IS NOT NULL AND m.cpf_dominante IS NOT NULL THEN concat('cpf:', m.cpf_dominante)
      WHEN p.email_n IS NOT NULL THEN concat('email:', p.email_n)
      ELSE concat('id:', CAST(p.comprador_id AS STRING))
    END AS ident,
    CASE
      WHEN p.cpf_n IS NOT NULL THEN 'cpf'
      WHEN p.email_n IS NOT NULL AND m.qtd_cpf = 1 THEN 'cpf_via_email'
      WHEN p.email_n IS NOT NULL AND m.qtd_cpf > 1 THEN 'cpf_via_email_dominante'
      WHEN p.email_n IS NOT NULL THEN 'email'
      ELSE 'comprador_id'
    END AS origem_identidade
  FROM ped_cad p
  LEFT JOIN mapa_email m ON m.loja_id = p.loja_id AND m.email_n = p.email_n AND p.cpf_n IS NULL
),
cat AS (
  SELECT DISTINCT i.pedido_id, pr.categoria
  FROM fc_catalog.ecommerce.s_itens_pedido i
  JOIN fc_catalog.ecommerce.s_produtos pr ON pr.produto_id = i.produto_id
  WHERE pr.categoria IS NOT NULL
),
base AS (
  SELECT i.pedido_id, i.loja_id,
         sha2(concat_ws('|', i.loja_id, i.ident), 256) AS comprador_hash,
         i.origem_identidade, c.categoria, i.data_pedido, i.data_corte
  FROM identidade i
  JOIN cat c ON c.pedido_id = i.pedido_id
),
totais AS (
  -- pedidos pagos distintos do comprador na loja, independente de categoria
  SELECT comprador_hash, count(DISTINCT pedido_id) AS qtd_pedidos_comprador
  FROM base GROUP BY comprador_hash
)
SELECT b.pedido_id, b.loja_id, b.comprador_hash, b.origem_identidade, b.categoria,
       b.data_pedido, b.data_corte, t.qtd_pedidos_comprador
FROM base b
JOIN totais t ON t.comprador_hash = b.comprador_hash;
