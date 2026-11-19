-- objeto: g_taxa_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra
WITH METRICS LANGUAGE YAML AS $$
version: 1.1
comment: "Taxa de recompra nos 90 dias até a última data com dados, POR LOJA: compradores com 2+ pedidos pagos / compradores com 1+ pedido pago. USO OBRIGATÓRIO: consultar sempre com GROUP BY Loja (ou filtro por uma loja). Sem Loja a view soma as lojas e conta a mesma pessoa uma vez por loja; consolidado da plataforma só sob pedido explícito. Identidade dentro da loja: CPF só dígitos; cadastro sem CPF herda o CPF do e-mail quando o e-mail tem exatamente 1 CPF na loja (une conta e convidado); e-mail com 2+ CPFs é ambíguo e não une pessoas diferentes (pedidos sem CPF ficam com chave de e-mail). Chave em sha2, sem dado pessoal. Exclui testes e chargebacks perdidos."
source: |
  SELECT loja_id,
         concat(loja_id, '|', chave_comprador) AS chave_loja_comprador,
         data_referencia,
         COUNT(*) AS qtd_pedidos
  FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador
  GROUP BY loja_id, chave_comprador, data_referencia
dimensions:
  - name: Loja
    expr: source.loja_id
  - name: Data de Referência
    expr: source.data_referencia
measures:
  - name: Compradores Ativos
    expr: COUNT(DISTINCT source.chave_loja_comprador)
    comment: Compradores únicos com 1+ pedido pago na janela de 90 dias. Usar por Loja.
  - name: Compradores Recorrentes
    expr: COUNT(DISTINCT source.chave_loja_comprador) FILTER (WHERE source.qtd_pedidos >= 2)
    comment: Compradores únicos com 2+ pedidos pagos na janela de 90 dias. Usar por Loja.
  - name: Taxa de Recompra
    expr: "MEASURE(`Compradores Recorrentes`) * 1.0 / NULLIF(MEASURE(`Compradores Ativos`), 0)"
    comment: Compradores recorrentes / compradores ativos. Usar por Loja.
$$;
