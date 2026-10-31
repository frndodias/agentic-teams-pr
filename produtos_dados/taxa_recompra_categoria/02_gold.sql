-- objeto: g_recompra_categoria
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_recompra_categoria
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra por loja e categoria nos últimos 90 dias (recompra na categoria: 2+ pedidos pagos contendo a categoria). Identidade do comprador por loja (hash). A soma das categorias não fecha com o total da loja; sem categoria, compradores_ativos é distinto na loja."
  source: |
    SELECT loja_id, categoria, comprador_hash, qtd_pedidos_pagos
    FROM fc_catalog.agentic_teams_sandbox.s_recompra_categoria_base
  dimensions:
    - name: loja_id
      expr: source.loja_id
    - name: categoria
      expr: source.categoria
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT source.comprador_hash)
      comment: "Compradores distintos com 1+ pedidos pagos na janela"
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT source.comprador_hash) FILTER (WHERE source.qtd_pedidos_pagos >= 2)
      comment: "Compradores distintos com 2+ pedidos pagos na categoria na janela"
    - name: taxa_recompra
      expr: "MEASURE(`compradores_recorrentes`) * 1.0 / MEASURE(`compradores_ativos`)"
      comment: "compradores_recorrentes / compradores_ativos"
$$;
