-- objeto: g_tempo_primeira_segunda_compra
CREATE OR REPLACE VIEW fc_catalog.agentic_teams_sandbox.g_tempo_primeira_segunda_compra
WITH METRICS LANGUAGE YAML AS $$
  version: 1.1
  comment: "Tempo entre a 1ª e a 2ª compra paga, em dias, por loja, categoria e coorte (mês da 1ª compra). 1ª e 2ª compra são dentro da categoria (um comprador pode aparecer em várias categorias). Comprador por loja. Só entram compradores com 2ª compra (viés de sobrevivência; coortes recentes têm menos tempo para recomprar). Categoria é a atual de s_produtos, não a da data da compra. Histórico completo, sem PII."
  source: fc_catalog.agentic_teams_sandbox.s_intervalo_compras_comprador_categoria
  dimensions:
    - name: Loja
      expr: source.loja_id
    - name: Categoria
      expr: source.categoria
    - name: Mês da Primeira Compra
      expr: source.mes_primeira_compra
  measures:
    - name: Tempo Médio Dias
      expr: AVG(source.dias_entre_compras)
      comment: "Média do intervalo em dias entre a 1ª e a 2ª compra paga."
    - name: Mediana Dias
      expr: PERCENTILE(source.dias_entre_compras, 0.5)
      comment: "Mediana do intervalo em dias, menos sensível a outliers."
    - name: Compradores com Recompra
      expr: COUNT(DISTINCT CONCAT(source.loja_id, '|', source.comprador_hash))
      comment: "Compradores (loja + hash) distintos com 2ª compra; indica o tamanho da amostra. Um comprador em várias categorias conta em cada uma delas."
$$;
