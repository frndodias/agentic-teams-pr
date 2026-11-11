-- objeto: g_ltv_segmento_loja
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_ltv_segmento_loja
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "LTV (receita bruta valor_total acumulada em todo o histórico, pedidos pagos válidos) por comprador e loja, agregado por segmento de loja. Comprador conta uma vez por loja. Inclui lojas inativas. Segmento atual da loja."
  source: fc_catalog.agentic_teams_sandbox.s_ltv_comprador_loja
  dimensions:
    - name: Segmento da Loja
      expr: source.segmento
    - name: Status da Loja
      expr: source.status_loja
  measures:
    - name: Clientes
      expr: COUNT(1)
      comment: "Compradores (por loja) com ao menos um pedido pago válido; cada linha da fonte é um comprador_hash em uma loja."
    - name: Receita Total
      expr: SUM(source.receita_total)
      comment: "Soma de valor_total dos pedidos pagos válidos."
    - name: LTV Medio
      expr: "MEASURE(`Receita Total`) * 1.0 / MEASURE(`Clientes`)"
      comment: "Média da receita bruta acumulada por comprador na loja."
$$;
