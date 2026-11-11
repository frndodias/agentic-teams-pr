# Taxa de recompra de compradores por categoria (90 dias)

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias, por categoria?

**Objetivo:** Mostrar quanto dos compradores ativos dos últimos 90 dias voltou a comprar, por categoria, para apoiar decisões de retenção.

**Grão:** Loja × categoria × comprador unificado (tabela silver, só hash). A metric view agrega em loja × categoria.

## Regras
- Janela: últimos 90 dias até 2026-11-10. Filtrar a janela antes dos joins.
- Pedido pago: pagamento aprovado ou estornado (EXISTS, pois há até 2 tentativas).
- Pedido pago: status_pedido diferente de cancelado e pendente. Devolvido conta como pago.
- Pedido pago: sem chargeback com status perdida.
- Excluir testes: valor_total <= 1,00, ou nome/e-mail contendo 'teste' ou 'test' (sem diferenciar maiúsculas).
- Identidade por loja: CPF só com dígitos, com hash sha2. Sem CPF, e-mail em minúsculas e sem espaços nas pontas, também com hash.
- Mesma chave na mesma loja = mesmo comprador (unifica conta e convidado).
- Comprador ativo: 1 ou mais pedidos pagos. Recorrente: 2 ou mais pedidos pagos.
- Taxa de recompra = recorrentes / ativos (divisão segura, sem erro com zero).
- LGPD: não expor CPF, e-mail, nome ou telefone. Só hash e agregados.
- Criar objetos apenas em fc_catalog.agentic_teams_sandbox.

## Decisões do negócio
- Como atribuir o comprador à categoria, já que um pedido pode ter itens de várias categorias? → **Por categoria comprada: o comprador conta em cada categoria em que comprou e é recorrente na categoria com 2 ou mais pedidos pagos com ela. A soma das categorias não fecha com o total.**
- Qual visão o negócio quer: por loja ou consolidada da plataforma? O número muda, pois o mesmo comprador em lojas diferentes conta como compradores distintos na visão por loja. → **Por loja (padrão do contrato)**

## Medidas
- **compradores_ativos**: Compradores unificados distintos com 1 ou mais pedidos pagos na janela.
- **compradores_recorrentes**: Compradores unificados distintos com 2 ou mais pedidos pagos na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
