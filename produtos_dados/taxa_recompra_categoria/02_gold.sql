-- objeto: g_taxa_recompra_categoria
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra_categoria
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra de compradores (unificados por loja) nos últimos 90 dias, por loja e categoria. Comprador conta em cada categoria comprada; a soma das categorias não fecha com o total."
  source: fc_catalog.agentic_teams_sandbox.s_recompra_comprador_categoria
  dimensions:
    - name: loja_id
      expr: loja_id
    - name: categoria
      expr: categoria
    - name: data_referencia
      expr: data_referencia
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT comprador_hash)
      comment: "Compradores unificados distintos com 1 ou mais pedidos pagos na janela de 90 dias."
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT comprador_hash) FILTER (WHERE qtd_pedidos_pagos >= 2)
      comment: "Compradores unificados distintos com 2 ou mais pedidos pagos na janela de 90 dias."
    - name: taxa_recompra
      expr: "MEASURE(compradores_recorrentes) * 1.0 / NULLIF(MEASURE(compradores_ativos), 0)"
      comment: "compradores_recorrentes / compradores_ativos."
$$;
