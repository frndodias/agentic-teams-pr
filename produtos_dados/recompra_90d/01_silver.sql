-- objeto: s_recompra_identidade
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_identidade AS
WITH n0 AS (
  SELECT c.loja_id, c.comprador_id,
         CASE WHEN length(regexp_replace(COALESCE(c.cpf, ''), '[^0-9]', '')) = 11
                   AND regexp_replace(COALESCE(c.cpf, ''), '[^0-9]', '') NOT RLIKE '^(\\d)\\1{10}$'
                   AND regexp_replace(COALESCE(c.cpf, ''), '[^0-9]', '') NOT IN ('12345678909', '01234567890')
              THEN regexp_replace(c.cpf, '[^0-9]', '') END AS cpf_k,
         NULLIF(lower(trim(COALESCE(c.email, ''))), '') AS email_k,
         lower(COALESCE(c.nome, '')) AS nome_n,
         CAST(c.comprador_id AS STRING) AS lab
  FROM fc_catalog.ecommerce.s_compradores c
),
n1 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k, lab
  FROM n0
  WHERE nome_n NOT LIKE '%test%' AND COALESCE(email_k, '') NOT LIKE '%test%'
    AND (cpf_k IS NOT NULL OR email_k IS NOT NULL)
),
s1 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM n1
),
s2 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM s1
),
s3 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM s2
),
s4 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM s3
),
s5 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM s4
),
s6 AS (
  SELECT loja_id, comprador_id, cpf_k, email_k,
         LEAST(lab,
               CASE WHEN cpf_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, cpf_k) END,
               CASE WHEN email_k IS NOT NULL THEN MIN(lab) OVER (PARTITION BY loja_id, email_k) END) AS lab
  FROM s5
)
SELECT loja_id, comprador_id,
       sha2(concat(CAST(loja_id AS STRING), ':', lab), 256) AS comprador_hash
FROM s6;

-- objeto: s_recompra_compradores
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_compradores AS
WITH ref AS (
  SELECT CAST(MAX(data_hora_pedido) AS DATE) AS janela_fim
  FROM fc_catalog.ecommerce.s_pedidos
),
janela AS (
  SELECT janela_fim, DATE_SUB(janela_fim, 89) AS janela_inicio FROM ref
),
ped AS (
  SELECT p.pedido_id, p.loja_id, p.comprador_id, j.janela_inicio, j.janela_fim
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN janela j
  WHERE CAST(p.data_hora_pedido AS DATE) BETWEEN j.janela_inicio AND j.janela_fim
    AND p.status_pedido NOT IN ('cancelado', 'pendente')
    AND p.valor_total > 1.00
    AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos pg
                WHERE pg.pedido_id = p.pedido_id AND pg.status IN ('aprovado', 'estornado'))
    AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                    WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
)
SELECT p.loja_id, i.comprador_hash, p.janela_inicio, p.janela_fim,
       COUNT(DISTINCT p.pedido_id) AS qtd_pedidos_pagos
FROM ped p
JOIN fc_catalog.agentic_teams_sandbox.s_recompra_identidade i
  ON i.comprador_id = p.comprador_id AND i.loja_id = p.loja_id
GROUP BY p.loja_id, i.comprador_hash, p.janela_inicio, p.janela_fim;
