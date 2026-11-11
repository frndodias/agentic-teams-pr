-- objeto: s_identidade_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_identidade_comprador
COMMENT 'Resolução de identidade por loja: cada cadastro (não teste) mapeado ao comprador unificado (componente conexo por CPF só dígitos OU e-mail trim+lower). comprador_hash = sha2(loja_id|chave_canônica). Sem PII.'
AS
WITH c AS (
  SELECT comprador_id, loja_id,
         nullif(regexp_replace(coalesce(cpf, ''), '[^0-9]', ''), '') AS k_cpf,
         nullif(lower(trim(coalesce(email, ''))), '') AS k_em
  FROM fc_catalog.ecommerce.s_compradores
  WHERE lower(coalesce(nome, ''))  NOT LIKE '%test%'
    AND lower(coalesce(email, '')) NOT LIKE '%test%'
),
e AS (SELECT DISTINCT loja_id, k_cpf, k_em FROM c WHERE k_cpf IS NOT NULL AND k_em IS NOT NULL),
l0 AS (SELECT loja_id, k_cpf, concat('c:', k_cpf) AS lab FROM e GROUP BY loja_id, k_cpf),
m1 AS (SELECT e.loja_id, e.k_em, min(l0.lab) AS lab FROM e JOIN l0 USING (loja_id, k_cpf) GROUP BY e.loja_id, e.k_em),
l1 AS (SELECT e.loja_id, e.k_cpf, min(m1.lab) AS lab FROM e JOIN m1 USING (loja_id, k_em) GROUP BY e.loja_id, e.k_cpf),
m2 AS (SELECT e.loja_id, e.k_em, min(l1.lab) AS lab FROM e JOIN l1 USING (loja_id, k_cpf) GROUP BY e.loja_id, e.k_em),
l2 AS (SELECT e.loja_id, e.k_cpf, min(m2.lab) AS lab FROM e JOIN m2 USING (loja_id, k_em) GROUP BY e.loja_id, e.k_cpf),
m3 AS (SELECT e.loja_id, e.k_em, min(l2.lab) AS lab FROM e JOIN l2 USING (loja_id, k_cpf) GROUP BY e.loja_id, e.k_em),
l3 AS (SELECT e.loja_id, e.k_cpf, min(m3.lab) AS lab FROM e JOIN m3 USING (loja_id, k_em) GROUP BY e.loja_id, e.k_cpf),
m4 AS (SELECT e.loja_id, e.k_em, min(l3.lab) AS lab FROM e JOIN l3 USING (loja_id, k_cpf) GROUP BY e.loja_id, e.k_em),
l4 AS (SELECT e.loja_id, e.k_cpf, min(m4.lab) AS lab FROM e JOIN m4 USING (loja_id, k_em) GROUP BY e.loja_id, e.k_cpf),
m5 AS (SELECT e.loja_id, e.k_em, min(l4.lab) AS lab FROM e JOIN l4 USING (loja_id, k_cpf) GROUP BY e.loja_id, e.k_em)
SELECT c.comprador_id, c.loja_id,
       sha2(concat(c.loja_id, '|',
            CASE
              WHEN c.k_cpf IS NOT NULL THEN coalesce(l4.lab, concat('c:', c.k_cpf))
              WHEN c.k_em  IS NOT NULL THEN coalesce(m5.lab, concat('e:', c.k_em))
            END), 256) AS comprador_hash
FROM c
LEFT JOIN l4 ON l4.loja_id = c.loja_id AND l4.k_cpf = c.k_cpf
LEFT JOIN m5 ON m5.loja_id = c.loja_id AND m5.k_em  = c.k_em
WHERE c.k_cpf IS NOT NULL OR c.k_em IS NOT NULL;

-- objeto: s_recompra_comprador_categoria
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_comprador_categoria
COMMENT 'Pedidos pagos válidos dos últimos 90 dias, no grão loja x categoria x comprador unificado (hash por componente conexo CPF/e-mail, sem PII). qtd_pedidos_pagos = pedidos pagos do comprador com itens da categoria.'
AS
WITH ped AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id
  FROM fc_catalog.ecommerce.s_pedidos p
  WHERE p.data_hora_pedido >= current_date() - INTERVAL 90 DAYS
    AND p.data_hora_pedido <  current_date() + INTERVAL 1 DAY
    AND p.status_pedido NOT IN ('cancelado', 'pendente')
    AND p.valor_total > 1.00
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos pg
                WHERE pg.pedido_id = p.pedido_id AND pg.status IN ('aprovado', 'estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
ped_id AS (
  SELECT ped.pedido_id, ped.loja_id, i.comprador_hash
  FROM ped
  JOIN fc_catalog.agentic_teams_sandbox.s_identidade_comprador i
    ON i.comprador_id = ped.comprador_id AND i.loja_id = ped.loja_id
),
ped_cat AS (
  SELECT DISTINCT pi.pedido_id, pi.loja_id, pr.categoria, pi.comprador_hash
  FROM ped_id pi
  JOIN fc_catalog.ecommerce.s_itens_pedido it ON it.pedido_id = pi.pedido_id
  JOIN fc_catalog.ecommerce.s_produtos pr ON pr.produto_id = it.produto_id AND pr.loja_id = pi.loja_id
  WHERE pr.categoria IS NOT NULL
)
SELECT loja_id, categoria, comprador_hash,
       COUNT(DISTINCT pedido_id) AS qtd_pedidos_pagos,
       current_date() AS data_referencia
FROM ped_cat
GROUP BY loja_id, categoria, comprador_hash;
