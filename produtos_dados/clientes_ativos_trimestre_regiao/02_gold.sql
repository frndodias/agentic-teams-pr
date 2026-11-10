-- objeto: g_clientes_ativos_regiao
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_clientes_ativos_regiao
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Clientes únicos (comprador por loja) com ao menos 1 pedido pago válido, por região da loja e trimestre. Contrato v2.3; só hash e agregados. O total entre regiões não é a soma das regiões."
  source: |
    SELECT pedido_id, loja_id, comprador_sk, concat(loja_id, '|', comprador_sk) AS comprador_loja, regiao, data_pedido, trimestre,
           CASE WHEN data_pedido >= date_trunc('QUARTER', add_months(current_date(), -3))
                 AND data_pedido < date_trunc('QUARTER', current_date())
                THEN 'Último trimestre civil' ELSE 'Outros períodos' END AS janela
    FROM fc_catalog.agentic_teams_sandbox.s_pedidos_pagos_trimestre
  dimensions:
    - name: Região
      expr: source.regiao
    - name: Trimestre
      expr: source.trimestre
    - name: Janela
      expr: source.janela
    - name: Loja
      expr: source.loja_id
  measures:
    - name: Clientes Únicos
      expr: COUNT(DISTINCT source.comprador_loja)
    - name: Pedidos Pagos
      expr: COUNT(DISTINCT source.pedido_id)
$$;
