# Taxa de recompra de compradores em 90 dias

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias?

**Objetivo:** Medir a parcela de compradores ativos que fizeram 2 ou mais pedidos pagos na janela de 90 dias, por loja.

**Grão:** Uma linha por loja (agregado). A base intermediária tem uma linha por comprador unificado dentro da loja, identificado só por hash.

## Regras
- Pedido pago: ao menos 1 pagamento aprovado ou estornado, status_pedido diferente de cancelado e pendente, e sem chargeback perdido. Devolvido conta como pago.
- Excluir pedidos de teste: valor_total <= 1,00, ou nome ou e-mail com 'teste' ou 'test' (case-insensitive).
- Identidade na loja: CPF só com dígitos; sem CPF, e-mail em minúsculas e sem espaços. A mesma chave na mesma loja é o mesmo comprador.
- Comprador ativo: 1 ou mais pedidos pagos na janela, por loja.
- Comprador recorrente: 2 ou mais pedidos pagos na janela, por loja.
- Taxa de recompra = recorrentes / ativos.
- Usar EXISTS ou agregação em pagamentos e disputas para não duplicar pedidos.
- Descartar CPFs placeholder ou inválidos e cair para o e-mail, para não juntar pessoas diferentes.
- LGPD: chave só com sha2 e saída só com agregados. Criar objetos apenas em fc_catalog.agentic_teams_sandbox.

## Decisões do negócio
- A taxa deve ser calculada por loja ou consolidada na plataforma? Isso muda o número: na visão consolidada, quem compra em várias lojas conta uma vez só. → **Por loja (padrão do contrato)**
- Os dados vão até 30/10/2026 e hoje é 11/11/2026. Qual deve ser o fim da janela de 90 dias? → **Última data com dados (30/10/2026)**

## Medidas
- **compradores_ativos**: Compradores unificados com 1 ou mais pedidos pagos na janela.
- **compradores_recorrentes**: Compradores unificados com 2 ou mais pedidos pagos na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
