-- objeto: g_clientes_unicos_regiao
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_clientes_unicos_regiao
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Clientes únicos com ao menos um pedido pago no último trimestre civil fechado, por região da loja. Contagem por loja (comprador unificado conta uma vez em cada loja); a soma das lojas da região pode superar o total de clientes distintos."
  source: fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_comprador
  dimensions:
    - name: Região da Loja
      expr: source.regiao_loja
    - name: Loja
      expr: source.loja_id
    - name: Trimestre
      expr: source.trimestre
  measures:
    - name: Clientes Únicos
      expr: COUNT(DISTINCT concat(source.loja_id, '|', source.comprador_hash))
      comment: "Compradores distintos (loja + comprador unificado) com ao menos um pedido pago na janela"
    - name: Pedidos Pagos
      expr: COUNT(DISTINCT source.pedido_id)
      comment: "Pedidos pagos distintos na janela, apoio de conciliação"
$$;
