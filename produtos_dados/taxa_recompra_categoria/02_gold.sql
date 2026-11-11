-- objeto: g_taxa_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Taxa de recompra por loja e categoria na janela de 90 dias terminando na última data com pedidos (não hoje). Regra (decisão do negócio): recompra DENTRO da categoria = 2+ pedidos pagos distintos contendo a categoria. Identidade por loja: CPF (só dígitos); cadastro sem CPF herda o CPF do mesmo e-mail na loja (se o e-mail tem 2+ CPFs, usa o CPF dominante: mais cadastros na janela, depois pedido mais recente); e-mail normalizado só quando nenhum CPF está associado; comprador_id é fallback final (não usado hoje). Categorias NÃO somam o total: um pedido com várias categorias conta em cada uma; não some compradores entre categorias."
  source: |
    SELECT loja_id, categoria, comprador_hash,
           COUNT(DISTINCT pedido_id) AS qtd_pedidos,
           MAX(data_corte) AS data_corte
    FROM fc_catalog.agentic_teams_sandbox.s_recompra_pedido_categoria
    GROUP BY loja_id, categoria, comprador_hash
  dimensions:
    - name: Loja
      expr: source.loja_id
    - name: Categoria
      expr: source.categoria
    - name: Fim da Janela
      expr: source.data_corte
  measures:
    - name: Compradores Ativos
      expr: COUNT(DISTINCT source.comprador_hash)
      comment: "Compradores distintos (hash por loja) com 1+ pedido pago contendo a categoria na janela"
    - name: Compradores Recorrentes
      expr: COUNT(DISTINCT source.comprador_hash) FILTER (WHERE source.qtd_pedidos >= 2)
      comment: "Compradores com 2+ pedidos pagos distintos contendo a categoria na janela"
    - name: Taxa de Recompra
      expr: "MEASURE(`Compradores Recorrentes`) * 1.0 / NULLIF(MEASURE(`Compradores Ativos`), 0)"
      comment: "Compradores Recorrentes / Compradores Ativos (recompra dentro da categoria). Não some entre categorias."
$$;
