# Taxa de recompra de compradores por categoria (90 dias)

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias, por categoria?

**Objetivo:** Medir a proporção de compradores ativos que fizeram 2+ pedidos pagos na janela de 90 dias, por categoria.

**Grão:** Loja x categoria x janela de 90 dias (2026-08-03 a 2026-11-01). Um comprador único por loja e categoria.

## Regras
- Pedido pago: ao menos 1 pagamento aprovado ou estornado, deduplicando tentativas por pedido.
- Status do pedido diferente de cancelado e pendente. Devolvidos contam como pagos.
- Excluir pedidos com chargeback de status perdida.
- Excluir pedidos de teste: valor_total <= 1,00 ou nome/e-mail contendo 'teste' ou 'test' (sem diferenciar maiúsculas).
- Identidade por loja: CPF só com dígitos; sem CPF, e-mail em minúsculas e sem espaços. Mesma chave na mesma loja = mesmo comprador.
- Chave do comprador exposta apenas como sha2. Publicar somente agregados (sem CPF, e-mail, nome ou telefone).
- Categoria via s_itens_pedido e s_produtos. Garantir unicidade de produto_id (por loja) antes do join para não duplicar pedidos.
- Pedido com várias categorias conta uma vez em cada categoria presente, sem duplicar dentro da mesma categoria.
- Métrica por loja. Visão consolidada só se o negócio pedir.
- Objetos criados apenas em fc_catalog.agentic_teams_sandbox.

## Decisões do negócio
- A recompra deve ser medida dentro da mesma categoria ou como compra geral atribuída a uma categoria? → **Geral: 2+ pedidos pagos em qualquer categoria, atribuído à categoria do primeiro pedido**
- A visão deve ser por loja ou consolidada da plataforma? → **Por loja (padrão do contrato)**

## Medidas
- **compradores_ativos**: Compradores distintos com 1+ pedido pago na janela, na categoria.
- **compradores_recorrentes**: Compradores distintos com 2+ pedidos pagos distintos na janela, na categoria.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos (nulo se ativos = 0).
