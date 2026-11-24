-- objeto: g_taxa_recompra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_taxa_recompra
WITH METRICS LANGUAGE YAML AS $$
version: 1.1
comment: "Taxa de recompra nos 90 dias que terminam na Data de Referência (última data com dados, não necessariamente hoje), POR LOJA: compradores com 2+ pedidos pagos / compradores com 1+ pedido pago. USO OBRIGATÓRIO: consultar sempre com GROUP BY Loja (ou filtro por uma loja) e informar a Data de Referência junto do número. Sem Loja a view soma as lojas e conta a mesma pessoa uma vez por loja; consolidado da plataforma só sob pedido explícito. A taxa agregada de várias lojas só vale como média das lojas. Pedido pago exclui cancelado, pendente, chargeback perdido e pedidos de teste. Identidade dentro da loja: CPF só dígitos; sem CPF herda o CPF do e-mail quando o e-mail tem exatamente 1 CPF na loja; e-mail com 2+ CPFs é ambíguo e não une pessoas. Chave em sha2, sem dado pessoal. Lojas atípicas (Loja Atípica = Sim) têm 1000+ compradores ativos e 3+ pedidos por comprador, muito acima do padrão (cerca de 1,7); mantidas no resultado, mas sinalizadas por possível teste ou fraude não filtrados."
source: |
  SELECT loja_id,
         concat(loja_id, '|', chave_comprador) AS chave_loja_comprador,
         data_referencia,
         qtd_pedidos,
         CASE WHEN COUNT(*) OVER (PARTITION BY loja_id, data_referencia) >= 1000
                   AND SUM(qtd_pedidos) OVER (PARTITION BY loja_id, data_referencia) * 1.0
                       / COUNT(*) OVER (PARTITION BY loja_id, data_referencia) >= 3
              THEN 'Sim' ELSE 'Não' END AS loja_atipica
  FROM (
    SELECT loja_id, chave_comprador, data_referencia, COUNT(*) AS qtd_pedidos
    FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador
    GROUP BY loja_id, chave_comprador, data_referencia
  )
dimensions:
  - name: Loja
    expr: source.loja_id
  - name: Data de Referência
    expr: source.data_referencia
  - name: Loja Atípica
    expr: source.loja_atipica
    comment: "Sim quando a loja tem 1000+ compradores ativos e média de 3+ pedidos por comprador (ex.: L003053, L009457). Possível teste ou fraude não filtrados; validar antes de usar como referência."
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
