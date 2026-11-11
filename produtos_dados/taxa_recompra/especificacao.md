# Taxa de recompra dos compradores nos últimos 90 dias

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias?

**Objetivo:** Medir quantos compradores ativos voltaram a comprar na janela de 90 dias, por loja, para o negócio acompanhar retenção.

**Grão:** Gold: uma linha por loja na janela de 90 dias. Silver: uma linha por comprador único (chave em hash) por loja.

## Regras
- Taxa de recompra = compradores recorrentes ÷ compradores ativos.
- Ativo: 1 ou mais pedidos pagos na janela. Recorrente: 2 ou mais pedidos pagos na janela.
- Pedido pago: ao menos um pagamento aprovado ou estornado. Deduplicar por pedido antes do join, porque há pedidos com 2 tentativas.
- Status do pedido diferente de cancelado e pendente. Devolvido conta como pago.
- Excluir pedidos com chargeback de status perdida. MED perdido não exclui.
- Excluir pedidos de teste: valor_total <= 1, ou nome ou e-mail com 'test' ou 'teste' (sem diferenciar maiúsculas).
- Identidade dentro da loja: CPF só com dígitos. Sem CPF, e-mail em minúsculas e sem espaços nas pontas. Mesma chave na mesma loja conta como um comprador.
- Chave do comprador sempre em sha2. Não expor CPF, e-mail, nome ou telefone. Publicar só agregados.
- Usar só tabelas silver (s_*). Não usar b_*.
- Dados de pedidos terminam em 2026-10-30. Exibir a data final da janela na saída.

## Decisões do negócio
- Os dados de pedidos terminam em 30/10/2026 e hoje é 11/11/2026. Em que data a janela de 90 dias deve terminar? → **Até a última data com dados (30/10/2026)**
- Como a taxa deve ser apresentada? → **Por loja e consolidada**

## Medidas
- **compradores_ativos**: Compradores únicos com 1 ou mais pedidos pagos válidos na janela.
- **compradores_recorrentes**: Compradores únicos com 2 ou mais pedidos pagos válidos na janela.
- **taxa_recompra**: compradores_recorrentes ÷ compradores_ativos.
