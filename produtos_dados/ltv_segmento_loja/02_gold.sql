-- objeto: g_ltv_segmento
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_ltv_segmento
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "LTV realizado (receita valor_total de pedidos pagos válidos, todo o histórico) por comprador unificado e loja, agregado por segmento. Lojas ativas e inativas. Segmento atual da loja."
  source: fc_catalog.agentic_teams_sandbox.s_ltv_comprador_loja
  dimensions:
    - name: Segmento
      expr: source.segmento
    - name: Loja
      expr: source.loja_id
    - name: Status da Loja
      expr: source.status_loja
    - name: Mes da Primeira Compra
      expr: source.mes_primeira_compra
  measures:
    - name: Receita Total
      expr: SUM(source.receita_total)
      comment: "Soma de valor_total dos pedidos pagos válidos"
    - name: Compradores
      expr: COUNT(DISTINCT concat(source.loja_id, '|', source.comprador_sk))
      comment: "Compradores unificados distintos por loja"
    - name: Pedidos Pagos
      expr: SUM(source.pedidos_pagos)
    - name: LTV Medio
      expr: "MEASURE(`Receita Total`) * 1.0 / MEASURE(`Compradores`)"
      comment: "Receita total / compradores distintos (não é média das médias das lojas)"
    - name: Pedidos por Comprador
      expr: "MEASURE(`Pedidos Pagos`) * 1.0 / MEASURE(`Compradores`)"
$$;
