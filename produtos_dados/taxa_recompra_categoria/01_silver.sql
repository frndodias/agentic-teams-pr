-- objeto: s_compradores_unificados
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_compradores_unificados AS
WITH base AS (
  SELECT comprador_id, loja_id,
    nullif(regexp_replace(coalesce(cpf,''), '[^0-9]', ''), '') AS cpf_n,
    nullif(lower(regexp_replace(coalesce(email,''), '\\s', '')), '') AS email_n,
    (lower(coalesce(nome,'')) LIKE '%teste%' OR lower(coalesce(nome,'')) LIKE '%test%'
     OR lower(coalesce(email,'')) LIKE '%teste%' OR lower(coalesce(email,'')) LIKE '%test%') AS flag_teste
  FROM fc_catalog.ecommerce.s_compradores
),
r0 AS (SELECT *, comprador_id AS c FROM base),
r1 AS (SELECT * EXCEPT (c), CASE WHEN cpf_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, cpf_n) ELSE c END AS c FROM r0),
r2 AS (SELECT * EXCEPT (c), CASE WHEN email_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, email_n) ELSE c END AS c FROM r1),
r3 AS (SELECT * EXCEPT (c), CASE WHEN cpf_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, cpf_n) ELSE c END AS c FROM r2),
r4 AS (SELECT * EXCEPT (c), CASE WHEN email_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, email_n) ELSE c END AS c FROM r3),
r5 AS (SELECT * EXCEPT (c), CASE WHEN cpf_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, cpf_n) ELSE c END AS c FROM r4),
r6 AS (SELECT * EXCEPT (c), CASE WHEN email_n IS NOT NULL THEN min(c) OVER (PARTITION BY loja_id, email_n) ELSE c END AS c FROM r5),
comp AS (
  SELECT *, min(cpf_n) OVER (PARTITION BY loja_id, c) AS cpf_rep,
            min(email_n) OVER (PARTITION BY loja_id, c) AS email_rep
  FROM r6
)
SELECT comprador_id, loja_id,
  CASE WHEN cpf_rep IS NOT NULL THEN sha2(concat(loja_id,'|cpf|',cpf_rep),256)
       WHEN email_rep IS NOT NULL THEN sha2(concat(loja_id,'|email|',email_rep),256) END AS comprador_hash,
  flag_teste
FROM comp;

-- objeto: s_recompra_categoria_base
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_categoria_base AS
WITH ped AS (
  SELECT p.pedido_id, p.loja_id, u.comprador_hash
  FROM fc_catalog.ecommerce.s_pedidos p
  JOIN fc_catalog.agentic_teams_sandbox.s_compradores_unificados u
    ON u.comprador_id = p.comprador_id AND u.loja_id = p.loja_id
  WHERE p.data_hora_pedido >= date_sub(current_date(), 90)
    AND p.data_hora_pedido < date_add(current_date(), 1)
    AND p.valor_total > 1
    AND p.status_pedido NOT IN ('cancelado','pendente')
    AND u.flag_teste = false
    AND u.comprador_hash IS NOT NULL
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos g
                WHERE g.pedido_id = p.pedido_id AND g.status IN ('aprovado','estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
),
ped_cat AS (
  SELECT DISTINCT p.pedido_id, p.loja_id, p.comprador_hash, pr.categoria
  FROM ped p
  JOIN fc_catalog.ecommerce.s_itens_pedido i ON i.pedido_id = p.pedido_id
  JOIN fc_catalog.ecommerce.s_produtos pr ON pr.produto_id = i.produto_id AND pr.loja_id = p.loja_id
  WHERE pr.categoria IS NOT NULL
),
tot AS (
  SELECT loja_id, comprador_hash, COUNT(DISTINCT pedido_id) AS qtd_pedidos_pagos_loja
  FROM ped GROUP BY loja_id, comprador_hash
)
SELECT c.loja_id, c.categoria, c.comprador_hash,
       COUNT(DISTINCT c.pedido_id) AS qtd_pedidos_pagos,
       MAX(t.qtd_pedidos_pagos_loja) AS qtd_pedidos_pagos_loja
FROM ped_cat c
JOIN tot t ON t.loja_id = c.loja_id AND t.comprador_hash = c.comprador_hash
GROUP BY c.loja_id, c.categoria, c.comprador_hash;
