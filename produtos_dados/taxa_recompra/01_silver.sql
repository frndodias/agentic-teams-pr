-- objeto: s_recompra_identidade
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_identidade AS
WITH cad AS (
  SELECT loja_id, comprador_id,
         regexp_replace(coalesce(cpf, ''), '[^0-9]', '') AS cpf_n,
         lower(trim(coalesce(email, ''))) AS email_n
  FROM fc_catalog.ecommerce.s_compradores
),
-- arestas CPF-e-mail por loja, sobre TODO o cadastro (não só a janela)
e AS (
  SELECT DISTINCT loja_id, cpf_n AS cpf, email_n AS em
  FROM cad
  WHERE cpf_n <> '' AND email_n <> ''
),
-- propagação de rótulo (menor CPF) para fechar componentes conectados CPF/e-mail
em1 AS (SELECT loja_id, em, MIN(cpf) AS l FROM e GROUP BY loja_id, em),
cp1 AS (SELECT e.loja_id, e.cpf, MIN(em1.l) AS l FROM e JOIN em1 ON em1.loja_id = e.loja_id AND em1.em = e.em GROUP BY e.loja_id, e.cpf),
em2 AS (SELECT e.loja_id, e.em, MIN(cp1.l) AS l FROM e JOIN cp1 ON cp1.loja_id = e.loja_id AND cp1.cpf = e.cpf GROUP BY e.loja_id, e.em),
cp2 AS (SELECT e.loja_id, e.cpf, MIN(em2.l) AS l FROM e JOIN em2 ON em2.loja_id = e.loja_id AND em2.em = e.em GROUP BY e.loja_id, e.cpf),
em3 AS (SELECT e.loja_id, e.em, MIN(cp2.l) AS l FROM e JOIN cp2 ON cp2.loja_id = e.loja_id AND cp2.cpf = e.cpf GROUP BY e.loja_id, e.em),
cp3 AS (SELECT e.loja_id, e.cpf, MIN(em3.l) AS l FROM e JOIN em3 ON em3.loja_id = e.loja_id AND em3.em = e.em GROUP BY e.loja_id, e.cpf),
em4 AS (SELECT e.loja_id, e.em, MIN(cp3.l) AS l FROM e JOIN cp3 ON cp3.loja_id = e.loja_id AND cp3.cpf = e.cpf GROUP BY e.loja_id, e.em),
cp4 AS (SELECT e.loja_id, e.cpf, MIN(em4.l) AS l FROM e JOIN em4 ON em4.loja_id = e.loja_id AND em4.em = e.em GROUP BY e.loja_id, e.cpf)
SELECT c.loja_id,
       c.comprador_id,
       sha2(
         CASE
           WHEN c.cpf_n <> '' THEN concat('cpf:', coalesce(cp4.l, c.cpf_n))
           WHEN em4.l IS NOT NULL THEN concat('cpf:', em4.l)
           ELSE concat('email:', c.email_n)
         END, 256) AS comprador_chave
FROM cad c
LEFT JOIN cp4 ON c.cpf_n <> '' AND cp4.loja_id = c.loja_id AND cp4.cpf = c.cpf_n
LEFT JOIN em4 ON c.cpf_n = '' AND em4.loja_id = c.loja_id AND em4.em = c.email_n;

-- objeto: s_recompra_compradores
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_recompra_compradores AS
WITH janela AS (
  SELECT CAST(MAX(data_hora_pedido) AS DATE) AS data_fim_janela,
         CAST(MAX(data_hora_pedido) AS DATE) - INTERVAL 89 DAYS AS data_inicio_janela
  FROM fc_catalog.ecommerce.s_pedidos
),
pagos AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_pagamentos
  WHERE status IN ('aprovado', 'estornado')
),
perdidos AS (
  SELECT DISTINCT pedido_id
  FROM fc_catalog.ecommerce.s_disputas
  WHERE tipo = 'chargeback' AND status = 'perdida'
),
pedidos_validos AS (
  SELECT p.pedido_id, p.loja_id, i.comprador_chave
  FROM fc_catalog.ecommerce.s_pedidos p
  CROSS JOIN janela j
  JOIN pagos pg ON pg.pedido_id = p.pedido_id
  JOIN fc_catalog.ecommerce.s_compradores c
    ON c.comprador_id = p.comprador_id AND c.loja_id = p.loja_id
  JOIN fc_catalog.agentic_teams_sandbox.s_recompra_identidade i
    ON i.comprador_id = p.comprador_id AND i.loja_id = p.loja_id
  LEFT ANTI JOIN perdidos d ON d.pedido_id = p.pedido_id
  WHERE CAST(p.data_hora_pedido AS DATE) BETWEEN j.data_inicio_janela AND j.data_fim_janela
    AND p.status_pedido NOT IN ('cancelado', 'pendente')
    AND NOT coalesce(p.valor_total <= 1, false)
    AND NOT (lower(coalesce(c.nome, '')) LIKE '%test%' OR lower(coalesce(c.email, '')) LIKE '%test%')
    AND (length(regexp_replace(coalesce(c.cpf, ''), '[^0-9]', '')) > 0 OR length(trim(coalesce(c.email, ''))) > 0)
)
SELECT pv.loja_id,
       pv.comprador_chave,
       COUNT(DISTINCT pv.pedido_id) AS pedidos_pagos,
       MAX(j.data_inicio_janela) AS data_inicio_janela,
       MAX(j.data_fim_janela) AS data_fim_janela
FROM pedidos_validos pv
CROSS JOIN janela j
GROUP BY pv.loja_id, pv.comprador_chave;
