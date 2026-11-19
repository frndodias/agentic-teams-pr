# Taxa de recompra dos últimos 90 dias por loja

**Pergunta do negócio:** qual a recorrencia de compra nos ultimos 90 dias?

**Objetivo:** Mostrar quantos compradores ativos nos últimos 90 dias compraram 2 ou mais vezes, por loja.

**Grão:** Silver: 1 linha por pedido pago. Gold: 1 linha por loja na janela de 90 dias.

## Regras
- Pedido pago: pagamento aprovado ou estornado.
- Pedido pago: status_pedido diferente de cancelado e pendente.
- Pedido pago: sem chargeback perdido. Devolvidos contam.
- Excluir pedidos de teste: valor_total <= 1,00 ou nome/e-mail com 'teste' ou 'test' (sem diferenciar maiúsculas).
- Identidade por loja: CPF só com dígitos; sem CPF, e-mail em minúsculas e sem espaços nas pontas.
- Unificar cadastros duplicados (conta e convidado) pela chave de identidade.
- Comprador ativo = 1+ pedido pago na janela. Recorrente = 2+ pedidos pagos.
- Taxa de recompra = recorrentes / ativos.
- Cálculo por loja. Consolidado da plataforma só sob pedido explícito.
- LGPD: chave do comprador em sha2. Não expor CPF, e-mail, nome nem telefone.

## Decisões do negócio
- A recorrência deve ser calculada por loja ou consolidada na plataforma? O consolidado muda o número, porque o mesmo comprador em várias lojas seria contado uma vez só. → **Por loja (padrão do contrato)**
- A janela de 90 dias termina em que data? → **Na última data com dados disponíveis**

## Medidas
- **compradores_ativos**: Compradores distintos com 1+ pedido pago na janela de 90 dias.
- **compradores_recorrentes**: Compradores distintos com 2+ pedidos pagos na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
