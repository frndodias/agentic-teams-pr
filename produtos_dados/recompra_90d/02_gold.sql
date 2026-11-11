-- objeto: g_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_recompra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra em 90 dias por loja: compradores unificados (CPF válido, senão e-mail) com 2+ pedidos pagos / compradores com 1+ pedidos pagos. Janela termina na última data com dados. Comprador é contado por loja (mesma pessoa em duas lojas conta 2 vezes no total)."
  source: fc_catalog.agentic_teams_sandbox.s_recompra_compradores
  dimensions:
    - name: loja_id
      expr: source.loja_id
    - name: janela_inicio
      expr: source.janela_inicio
    - name: janela_fim
      expr: source.janela_fim
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT concat(source.loja_id, ':', source.comprador_hash))
      comment: "Compradores unificados por loja com 1+ pedidos pagos na janela"
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT concat(source.loja_id, ':', source.comprador_hash)) FILTER (WHERE source.qtd_pedidos_pagos >= 2)
      comment: "Compradores unificados por loja com 2+ pedidos pagos na janela"
    - name: taxa_recompra
      expr: "MEASURE(`compradores_recorrentes`) * 1.0 / NULLIF(MEASURE(`compradores_ativos`), 0)"
      comment: "compradores_recorrentes / compradores_ativos"
$$;
