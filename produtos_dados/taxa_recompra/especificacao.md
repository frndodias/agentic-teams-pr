# Taxa de recompra em 90 dias por loja

**Pergunta do negócio:** qual a recorrencia de compra nos ultimos 90 dias?

**Objetivo:** Mostrar quantos compradores ativos compraram 2 ou mais vezes nos últimos 90 dias, em cada loja.

**Grão:** Uma linha por loja e data de referência (janela móvel de 90 dias).

## Regras
- Pedido pago: pagamento aprovado ou estornado, status diferente de cancelado e pendente, sem chargeback perdido. Devolvidos contam como pagos.
- Excluir pedidos de teste: valor_total <= 1,00 ou nome ou e-mail com 'teste' ou 'test'.
- Identidade por loja: CPF só dígitos. Sem CPF, e-mail normalizado. A mesma chave na mesma loja é o mesmo comprador.
- Comprador ativo: pelo menos 1 pedido pago na janela de 90 dias.
- Comprador recorrente: 2 ou mais pedidos pagos na janela de 90 dias, na mesma loja.
- Taxa de recompra = recorrentes / ativos.
- Métricas de comprador são por loja. Consolidado da plataforma só sob pedido explícito.
- A taxa agregada de várias lojas só vale como média das lojas, nunca como soma, por causa da dupla contagem de pessoas.
- LGPD: não expor CPF, e-mail, nome nem telefone. Usar só hash sha2 como chave.
- A janela atual termina em 30/10/2026, não em 24/11/2026. Informar a data de referência junto do número.

## Decisões do negócio
- Como você quer ver a recorrência: por loja ou consolidada da plataforma? O consolidado muda o número, porque a mesma pessoa que compra em mais de uma loja é contada mais de uma vez. → **Por loja (padrão do contrato)**
- As lojas L003053 (55,9%) e L009457 (55,1%) têm recompra muito acima do padrão e podem ter testes ou fraude não filtrados. Como tratá-las? → **Manter no resultado e sinalizar como atípicas**

## Medidas
- **Compradores Ativos**: Compradores distintos por loja com 1 ou mais pedidos pagos na janela de 90 dias.
- **Compradores Recorrentes**: Compradores distintos por loja com 2 ou mais pedidos pagos na janela de 90 dias.
- **Taxa de Recompra**: Compradores Recorrentes / Compradores Ativos.
