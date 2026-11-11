# Taxa de recompra por categoria (90 dias)

**Pergunta do negócio:** Qual a taxa de recompra dos compradores nos últimos 90 dias, por categoria?

**Objetivo:** Mostrar a % de compradores ativos que compraram de novo na janela de 90 dias, por categoria e por loja.

**Grão:** Uma linha por pedido pago, comprador (hash) e categoria na silver. Na gold, o resultado é agregado por loja e categoria.

## Regras
- Taxa de recompra = compradores recorrentes / compradores ativos.
- Ativo: 1 ou mais pedidos pagos na janela. Recorrente: 2 ou mais pedidos pagos na janela.
- Janela de 90 dias terminando na última data com pedidos (2026-10-30), não em hoje (2026-11-11). Assim a janela não fica incompleta. A data de corte é parametrizável.
- Pedido pago: existe pagamento aprovado ou estornado. Pagamentos pendentes não contam.
- Pedido pago: status_pedido diferente de cancelado e pendente. Devolvido conta como pago.
- Excluir pedidos com chargeback perdido.
- Usar EXISTS ou agregar os pagamentos e disputas para não duplicar pedidos com várias tentativas.
- Excluir pedidos de teste: valor_total <= 1, ou nome/e-mail do comprador com 'test' ou 'teste' (sem diferenciar maiúsculas).
- Identidade dentro da loja: CPF só com dígitos. Sem CPF, e-mail em minúsculas e sem espaços nas pontas.
- Sem CPF e sem e-mail utilizáveis, usar comprador_id como fallback. Este fallback precisa ser validado.
- A chave de identidade é sha2 do CPF ou e-mail, combinada com loja_id.
- Categoria vem de s_itens_pedido ligado a s_produtos. Contar pedidos distintos por categoria, não itens.
- As categorias não somam o total, porque um pedido pode ter várias categorias. Não somar categorias.
- LGPD: não expor CPF, e-mail, nome ou telefone. Publicar só agregados e hash.
- Ainda não foram validados a lógica de identidade nem o tratamento de várias categorias. Validar na implementação.

## Decisões do negócio
- Como tratar compradores e pedidos com mais de uma categoria? Isso muda o número, pois cerca de 14,7 mi de 30,1 mi de pedidos têm várias categorias. → **Recompra dentro da categoria: 2 ou mais pedidos pagos contendo a categoria**
- A visão deve ser por loja ou consolidada na plataforma? Um mesmo comprador em lojas diferentes muda o resultado. → **Por loja (padrão do contrato)**

## Medidas
- **compradores_ativos**: Compradores distintos com 1 ou mais pedidos pagos contendo a categoria na janela.
- **compradores_recorrentes**: Compradores distintos com 2 ou mais pedidos pagos distintos contendo a categoria na janela.
- **taxa_recompra**: compradores_recorrentes / compradores_ativos.
