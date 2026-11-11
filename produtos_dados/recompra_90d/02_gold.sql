-- objeto: g_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_recompra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra por loja nos últimos 90 dias (janela termina na última data com pedidos). Recorrente = >= 2 pedidos pagos; ativo = >= 1. Comprador unificado = loja + chave hash; não unifica entre lojas. Sem dados pessoais."
  source: fc_catalog.agentic_teams_sandbox.s_recompra_compradores_90d
  dimensions:
    - name: loja_id
      expr: loja_id
    - name: data_referencia_janela
      expr: data_referencia
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT concat(loja_id, '|', chave_comprador)) FILTER (WHERE qtd_pedidos_pagos >= 1)
      comment: "Compradores unificados (loja + chave) com >= 1 pedido pago na janela de 90 dias"
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT concat(loja_id, '|', chave_comprador)) FILTER (WHERE qtd_pedidos_pagos >= 2)
      comment: "Compradores unificados (loja + chave) com >= 2 pedidos pagos na janela de 90 dias"
    - name: taxa_recompra
      expr: "MEASURE(compradores_recorrentes) * 1.0 / NULLIF(MEASURE(compradores_ativos), 0)"
      comment: "compradores_recorrentes / compradores_ativos"
$$;
