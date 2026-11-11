# Taxa de Recompra – últimos 90 dias

**Pergunta do negócio:** qual a recorrencia de compra nos ultimos 90 dias?

**Objetivo:** Medir quantos compradores ativos na janela de 90 dias compraram 2 ou mais vezes, por loja.

**Grão:** Uma linha por loja e janela de referência (compradores únicos por loja, identificados por CPF ou e-mail normalizado).

## Regras
- Taxa de Recompra = compradores recorrentes / compradores ativos.
- Ativo: 1+ pedido pago na janela. Recorrente: 2+ pedidos pagos na janela.
- Janela padrão: 90 dias. Visão por loja, salvo pedido explícito de consolidação.
- Pedido pago: pagamento aprovado ou estornado, deduplicado por pedido.
- status_pedido diferente de cancelado e pendente.
- Excluir pedidos com chargeback perdido. MED perdido não exclui.
- Devolvidos contam como pagos.
- Excluir testes: valor_total <= 1,00 ou nome/e-mail com 'test'/'teste' (case-insensitive).
- Identidade por loja: CPF só dígitos; sem CPF, e-mail em minúsculas e trim. Mesma chave na mesma loja conta como um comprador.
- LGPD: sem CPF, e-mail, nome ou telefone na saída. Usar apenas agregados ou chave com sha2.
- Dados de pedidos vão até 2026-10-30. A data de referência da janela precisa ser definida.

## Decisões do negócio
- Qual data de referência da janela de 90 dias? Os dados vão só até 30/10/2026, então a janela a partir de hoje teria cerca de 78 dias de dados. → **90 dias terminando na última data com dados (30/10/2026)**
- A taxa deve ser vista por loja (padrão do contrato) ou consolidada na plataforma? Isso muda o número, pois o mesmo comprador em várias lojas conta como um em cada loja ou como um só. → **Por loja (padrão do contrato)**

## Medidas
- **compradores_ativos**: Compradores únicos por loja com 1+ pedido pago na janela.
- **compradores_recorrentes**: Compradores únicos por loja com 2+ pedidos pagos na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
