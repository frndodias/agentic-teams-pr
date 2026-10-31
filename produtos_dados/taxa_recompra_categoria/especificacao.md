# Taxa de recompra por categoria (90 dias)

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias, por categoria?

**Objetivo:** Mostrar a % de compradores ativos que fizeram 2 ou mais pedidos pagos nos últimos 90 dias, por categoria.

**Grão:** Loja x categoria x comprador (hash), com a contagem de pedidos pagos na janela. A metric view agrega por loja e categoria.

## Regras
- Janela padrão: últimos 90 dias até hoje (2026-10-31). Filtrar data_hora_pedido cedo, pois s_pedidos tem 30 milhões de linhas.
- Pedido pago: pagamento aprovado ou estornado, com deduplicação por pedido.
- Pedido pago: status_pedido diferente de cancelado e pendente.
- Pedido pago: sem chargeback com status perdida. Devolvido conta como pago.
- Excluir pedidos de teste: valor_total <= 1, ou nome/e-mail com 'teste' ou 'test' (sem diferenciar maiúsculas).
- Identidade por loja: CPF só com dígitos; sem CPF, e-mail em minúsculas e sem espaços. Mesma chave na mesma loja é o mesmo comprador.
- Chave do comprador sempre como sha2. Não expor CPF, e-mail, nome nem telefone, e publicar só agregados.
- Cálculo por loja, salvo pedido explícito de visão consolidada da plataforma.
- Categoria vem de s_produtos via s_itens_pedido. Um pedido com várias categorias conta uma vez por categoria.
- Linha de total da plataforma ou da loja usa compradores distintos, não a soma das categorias.
- Antes de publicar, checar pedidos sem pagamento, itens órfãos e produto_id sem produto.

## Decisões do negócio
- Como atribuir a recompra à categoria? → **Recompra na categoria: 2 ou mais pedidos pagos que contenham a categoria. O comprador conta em cada categoria comprada, então a soma das categorias não fecha com o total.**
- Qual visão você quer ver? → **Por loja, com a mesma identidade de comprador só dentro da loja (padrão do contrato).**

## Medidas
- **compradores_ativos**: Compradores distintos (hash) com 1 ou mais pedidos pagos na janela.
- **compradores_recorrentes**: Compradores distintos (hash) com 2 ou mais pedidos pagos na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
