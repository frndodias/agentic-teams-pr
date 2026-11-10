# Clientes únicos que compraram no trimestre, por região

**Pergunta do negócio:** Quantos clientes únicos compraram no último trimestre, por região?

**Objetivo:** Medir quantos compradores únicos tiveram ao menos 1 pedido pago no trimestre, com quebra por região da loja.

**Grão:** Comprador unificado (comprador_sk) por loja, com ao menos 1 pedido pago na janela. Publicação agregada por região.

## Regras
- Pedido pago: ao menos um pagamento aprovado ou estornado, deduplicado por pedido.
- status_pedido diferente de cancelado e pendente; devolvido continua contando.
- Excluir pedido com chargeback perdido.
- Excluir pedido de teste: valor_total <= 1,00 ou nome/e-mail com 'teste' ou 'test' (sem diferenciar maiúsculas).
- Identidade por loja: CPF normalizado e, sem CPF, e-mail normalizado; mesma chave na mesma loja é o mesmo comprador.
- Cadastro sem chave (sem_chave) fica fora da contagem e é reportado à parte.
- Região vem de s_lojas.regiao; região nula aparece como 'Não informada'.
- LGPD: usar só comprador_sk (hash) e publicar apenas agregados.
- Classificação do pedido deve usar o estado atual de s_pedidos, conforme o contrato.
- O total entre regiões não é a soma das regiões se o mesmo cliente comprar em lojas de regiões diferentes.

## Decisões do negócio
- Qual período vale como 'último trimestre'? → **Trimestre civil anterior (01/07 a 30/09/2026)**
- Como contar um 'cliente único' que compra em lojas diferentes? → **Por loja: o mesmo cliente conta uma vez em cada loja (padrão do contrato)**

## Medidas
- **clientes_unicos**: Contagem distinta de comprador_sk com ao menos 1 pedido pago na janela, conforme a visão escolhida.
- **pedidos_pagos**: Contagem distinta de pedidos pagos válidos na janela, usada como apoio de reconciliação.
