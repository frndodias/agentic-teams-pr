-- objeto: s_pedidos_pagos_comprador
CREATE OR REPLACE TABLE fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador AS
SELECT
  p.pedido_id,
  p.loja_id,
  i.comprador_hash,
  coalesce(l.regiao, 'Sem região') AS regiao_loja,
  p.data_hora_pedido,
  CAST(p.data_hora_pedido AS DATE) AS data_pedido,
  concat(year(p.data_hora_pedido), '-T', quarter(p.data_hora_pedido)) AS trimestre,
  p.valor_total
FROM fc_catalog.ecommerce.s_pedidos p
JOIN fc_catalog.ecommerce.s_identidade_comprador i
  ON i.loja_id = p.loja_id AND i.comprador_id = p.comprador_id
LEFT JOIN fc_catalog.ecommerce.s_lojas l
  ON l.loja_id = p.loja_id
WHERE p.data_hora_pedido >= add_months(date_trunc('quarter', current_date()), -3)
  AND p.data_hora_pedido <  date_trunc('quarter', current_date())
  AND p.status_pedido NOT IN ('cancelado', 'pendente')
  AND p.valor_total > 1.00
  AND EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_pagamentos pg
              WHERE pg.pedido_id = p.pedido_id AND pg.status IN ('aprovado', 'estornado'))
  AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_disputas d
                  WHERE d.pedido_id = p.pedido_id AND d.tipo = 'chargeback' AND d.status = 'perdida')
  AND NOT EXISTS (SELECT 1 FROM fc_catalog.ecommerce.s_compradores c
                  WHERE c.loja_id = p.loja_id AND c.comprador_id = p.comprador_id
                    AND (lower(c.nome) LIKE '%test%' OR lower(c.email) LIKE '%test%'));
