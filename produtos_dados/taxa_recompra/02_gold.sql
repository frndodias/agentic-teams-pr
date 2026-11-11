-- objeto: g_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_recompra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra dos compradores (recorrentes / ativos) na janela de 90 dias terminando na última data com dados de pedidos. Por loja; sem agrupar por loja devolve a visão consolidada (soma dos compradores de cada loja, pois a identidade é por loja). Só agregados, sem dados pessoais."
  source: fc_catalog.agentic_teams_sandbox.s_recompra_compradores
  dimensions:
    - name: loja_id
      expr: source.loja_id
      comment: "Identificador da loja"
    - name: data_fim_janela
      expr: source.data_fim_janela
      comment: "Data final da janela de 90 dias (última data com dados de pedidos)"
    - name: data_inicio_janela
      expr: source.data_inicio_janela
      comment: "Data inicial da janela de 90 dias"
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT source.loja_id, source.comprador_chave)
      comment: "Compradores únicos (por loja) com 1 ou mais pedidos pagos válidos na janela"
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT source.loja_id, source.comprador_chave) FILTER (WHERE source.pedidos_pagos >= 2)
      comment: "Compradores únicos (por loja) com 2 ou mais pedidos pagos válidos na janela"
    - name: taxa_recompra
      expr: "MEASURE(compradores_recorrentes) * 1.0 / NULLIF(MEASURE(compradores_ativos), 0)"
      comment: "compradores_recorrentes ÷ compradores_ativos"
$$;
