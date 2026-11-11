-- objeto: g_taxa_recompra_categoria
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra_categoria
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra por loja e categoria nos 90 dias até a última data com dados de pedidos (ver dimensão Fim da Janela; hoje 30/10/2026). Recorrente = 2+ pedidos pagos na mesma categoria. Categoria atual de s_produtos. Comprador conta em cada categoria em que comprou: não somar compradores nem taxas entre categorias. Visão por loja; consolidada só sob pedido explícito. Sem PII."
  source: fc_catalog.agentic_teams_sandbox.s_recompra_comprador_categoria_90d
  dimensions:
    - name: Loja
      expr: loja_id
    - name: Categoria
      expr: categoria
    - name: Inicio da Janela
      expr: data_inicio_janela
    - name: Fim da Janela
      expr: data_fim_janela
  measures:
    - name: Compradores Ativos
      expr: COUNT(DISTINCT comprador_hash)
      comment: "Compradores distintos com 1+ pedido pago na categoria na janela."
    - name: Compradores Recorrentes
      expr: COUNT(DISTINCT comprador_hash) FILTER (WHERE qtd_pedidos_pagos >= 2)
      comment: "Compradores distintos com 2+ pedidos pagos na mesma categoria na janela."
    - name: Taxa de Recompra
      expr: "MEASURE(`Compradores Recorrentes`) * 1.0 / NULLIF(MEASURE(`Compradores Ativos`), 0)"
      comment: "Compradores recorrentes / compradores ativos."
$$;
