-- objeto: g_recompra_categoria
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_recompra_categoria
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra dos compradores nos últimos 90 dias (2026-08-03 a 2026-11-01), por loja e categoria. Recompra geral (2+ pedidos pagos em qualquer categoria), atribuída à(s) categoria(s) do primeiro pedido. Compradores identificados por sha2 de um componente de identidade por loja (cadastros ligados por CPF válido ou e-mail normalizado; CPF inválido/placeholder tratado como ausente; mesmo e-mail ou CPF na mesma loja = mesmo comprador, conforme contrato). ATENÇÃO: a soma de compradores_ativos entre categorias pode ser maior que o total de compradores únicos, pois um primeiro pedido com várias categorias conta o comprador em cada uma; não some entre categorias. Sem dados pessoais."
  source: fc_catalog.agentic_teams_sandbox.s_compradores_recompra_categoria
  dimensions:
    - name: loja_id
      expr: source.loja_id
    - name: categoria
      expr: source.categoria_primeiro_pedido
  measures:
    - name: compradores_ativos
      expr: COUNT(DISTINCT source.comprador_sk)
      comment: "Compradores distintos com 1+ pedido pago na janela, na categoria do primeiro pedido. Não somar entre categorias."
    - name: compradores_recorrentes
      expr: COUNT(DISTINCT source.comprador_sk) FILTER (WHERE source.total_pedidos >= 2)
      comment: "Compradores distintos com 2+ pedidos pagos distintos na janela (em qualquer categoria), na categoria do primeiro pedido."
    - name: taxa_recompra
      expr: "MEASURE(`compradores_recorrentes`) * 1.0 / NULLIF(MEASURE(`compradores_ativos`), 0)"
      comment: "compradores_recorrentes / compradores_ativos (nulo se ativos = 0). Fica entre 0 e 1."
$$;
