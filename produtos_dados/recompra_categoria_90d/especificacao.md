# Taxa de recompra dos compradores nos últimos 90 dias, por categoria

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias, por categoria?

**Objetivo:** Medir a parcela de compradores ativos que compraram de novo, por loja e categoria, na janela de 90 dias.

**Grão:** Silver: loja × comprador_hash × categoria (com a quantidade de pedidos pagos na janela). Gold: loja × categoria.

## Regras
- Taxa de recompra = compradores recorrentes (2 ou mais pedidos pagos) / compradores ativos (1 ou mais pedidos pagos), na janela.
- Pedido pago: pagamento aprovado ou estornado, status diferente de cancelado e pendente, sem chargeback perdido. Devolvidos contam.
- Excluir pedidos de teste: valor_total <= 1, ou nome ou e-mail com 'teste' ou 'test'. O filtro por nome ou e-mail usa s_compradores sem expor PII.
- Identidade por loja: CPF só dígitos, senão e-mail trim e minúsculas. O comprador unificado conta uma vez por loja, via comprador_hash de s_identidade_comprador.
- Visão por loja. A consolidada só com pedido explícito.
- Um pedido com vários itens da mesma categoria conta uma vez nessa categoria (distinct pedido_id).
- Um pedido com itens de várias categorias entra em cada categoria. O comprador conta em cada categoria em que comprou.
- As categorias não somam o total. Não somar a taxa entre categorias.
- Categoria é a atual de s_produtos, não a da data da compra.
- Não reutilizar g_tempo_primeira_segunda_compra nem s_intervalo_compras_comprador_categoria (viés de sobrevivência, sem denominador).
- Sem PII na saída. Usar só comprador_hash e agregados.
- Dados de s_pedidos vão só até 30/10/2026. Documentar a data final real da janela no produto.

## Decisões do negócio
- Como contar a recompra por categoria? → **2 ou mais pedidos pagos na mesma categoria (o comprador conta em cada categoria em que comprou)**
- Qual o fim da janela de 90 dias, já que os dados vão só até 30/10/2026? → **90 dias até a última data com dados (30/10/2026)**

## Medidas
- **compradores_ativos**: Compradores distintos (comprador_hash) com 1 ou mais pedidos pagos na categoria e na janela.
- **compradores_recorrentes**: Compradores distintos com 2 ou mais pedidos pagos na mesma categoria e na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
