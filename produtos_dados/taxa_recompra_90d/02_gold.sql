-- objeto: g_taxa_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra nos 90 dias até a última data com dados: compradores com 2+ pedidos pagos / compradores com 1+ pedido pago. Comprador = CPF (só dígitos) ou e-mail normalizado dentro da loja (a mesma pessoa em duas lojas conta uma vez em cada)."
  source: |
    SELECT loja_id,
           concat(loja_id, '|', chave_comprador) AS chave_loja_comprador,
           data_referencia,
           COUNT(*) AS qtd_pedidos
    FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador
    GROUP BY loja_id, chave_comprador, data_referencia
  dimensions:
    - name: Loja
      expr: source.loja_id
    - name: Data de Referência
      expr: source.data_referencia
  measures:
    - name: Compradores Ativos
      expr: COUNT(DISTINCT source.chave_loja_comprador)
      comment: "Compradores únicos por loja com 1+ pedido pago na janela de 90 dias."
    - name: Compradores Recorrentes
      expr: COUNT(DISTINCT source.chave_loja_comprador) FILTER (WHERE source.qtd_pedidos >= 2)
      comment: "Compradores únicos por loja com 2+ pedidos pagos na janela de 90 dias."
    - name: Taxa de Recompra
      expr: "MEASURE(`Compradores Recorrentes`) * 1.0 / NULLIF(MEASURE(`Compradores Ativos`), 0)"
      comment: "Compradores recorrentes / compradores ativos."
$$;
