# Clientes únicos que compraram no trimestre, por região

**Pergunta do negócio:** Quantos clientes únicos compraram no último trimestre, por região?

**Objetivo:** Mostrar quantos clientes únicos fizeram ao menos uma compra paga no trimestre, por região.

**Grão:** Silver: um pedido pago por linha (pedido_id). Gold: comprador por loja, no trimestre e na região.

## Regras
- Pedido pago: ao menos uma tentativa de pagamento aprovada ou estornada (usar EXISTS, sem JOIN, para não duplicar pedidos).
- status_pedido diferente de cancelado e pendente.
- Excluir pedidos com chargeback perdido. Pedidos devolvidos contam.
- Excluir testes: valor_total <= 1,00 ou nome/e-mail com 'test' ou 'teste' (sem diferenciar maiúsculas). O filtro de nome/e-mail é aplicado sem expor os campos.
- Identidade: usar comprador_hash de s_identidade_comprador. Comprador unificado conta uma vez por loja.
- Janela por data_hora_pedido, com início inclusivo e fim exclusivo. Padrão: 3º trimestre civil de 2026, de 2026-07-01 a 2026-10-01 (a confirmar na p1).
- Premissa: região = região da loja (s_lojas), igual à de g_pedidos. Lojas sem região entram como 'Sem região'.
- Contagem por loja, salvo decisão em contrário na p2. Nesse caso, a soma das lojas na região pode passar do total de clientes distintos.
- LGPD: expor só agregados. Não expor CPF, e-mail, nome, telefone nem comprador_hash nos objetos de saída.

## Decisões do negócio
- Qual período devemos considerar como 'último trimestre'? Hoje é 11/11/2026 e os dados de pedidos vão até 30/10. → **3º trimestre civil de 2026 (jul a set), fechado**
- Como contar um cliente que compra em mais de uma loja da mesma região (ou em regiões diferentes)? → **Por loja (padrão do contrato): conta uma vez em cada loja, e a região soma as lojas**

## Medidas
- **clientes_unicos**: Contagem distinta de compradores (loja_id + comprador_hash) com ao menos um pedido pago na janela.
- **pedidos_pagos**: Contagem distinta de pedido_id pagos na janela. Serve como apoio de conciliação.
