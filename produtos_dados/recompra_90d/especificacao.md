# Taxa de recompra de compradores nos últimos 90 dias

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias?

**Objetivo:** Medir a parcela de compradores ativos que fizeram 2 ou mais pedidos pagos em 90 dias, por loja.

**Grão:** Gold: uma linha por loja e data de referência da janela. Silver: uma linha por comprador unificado (loja + chave hash) na janela.

## Regras
- Pedido pago: ao menos 1 pagamento aprovado ou estornado, status_pedido diferente de cancelado e pendente, e sem chargeback com status perdida. Devolvido continua contando como pago.
- Excluir pedidos de teste: valor_total <= 1,00, ou nome ou e-mail do comprador com 'test' ou 'teste' (sem diferenciar maiúsculas).
- Identidade por loja: sha2 do CPF só com dígitos. Sem CPF, usar sha2 do e-mail em minúsculas e sem espaços nas pontas. Não unificar entre lojas.
- Ativo: comprador unificado com >= 1 pedido pago na janela, na mesma loja.
- Recorrente: comprador unificado com >= 2 pedidos pagos na janela, na mesma loja.
- Taxa de recompra = recorrentes / ativos.
- Deduplicar pagamentos por pedido_id antes do join, porque há até 2 tentativas por pedido.
- LGPD: não expor CPF, e-mail, nome nem telefone. Publicar só agregados. Não usar tabelas b_*.

## Decisões do negócio
- A taxa de recompra deve ser vista por loja ou consolidada na plataforma? Isso muda o número, porque o mesmo comprador em lojas diferentes conta como pessoas distintas. → **Por loja (padrão do contrato)**
- Onde termina a janela de 90 dias? Os pedidos vão só até 30/10/2026 e hoje é 11/11/2026. → **Última data com dados (30/10/2026)**

## Medidas
- **compradores_ativos**: Compradores unificados com >= 1 pedido pago na janela de 90 dias.
- **compradores_recorrentes**: Compradores unificados com >= 2 pedidos pagos na janela de 90 dias.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
