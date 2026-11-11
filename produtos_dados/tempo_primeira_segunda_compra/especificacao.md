# Tempo médio entre a 1ª e a 2ª compra por categoria

**Pergunta do negócio:** Qual o tempo médio entre a 1ª e a 2ª compra dos clientes, por categoria?

**Objetivo:** Mostrar em quantos dias, em média, o comprador faz a 2ª compra após a 1ª, por categoria, para apoiar ações de recompra.

**Grão:** Silver: um comprador (loja_id + comprador_hash) por categoria, com datas da 1ª e da 2ª compra e intervalo em dias. Gold: média agregada por loja e categoria.

## Regras
- Base: histórico completo de s_pedidos. Não usar s_pedidos_pagos_comprador (só Q3/2026) nem s_recompra_comprador_categoria (só 90 dias).
- Pedido pago: ao menos uma tentativa aprovada ou estornada em s_pagamentos (usar EXISTS, sem duplicar pedido).
- Pedido pago: status_pedido diferente de cancelado e pendente. Devolvido conta como pago.
- Pedido pago: sem chargeback com status perdida em s_disputas.
- Excluir pedidos de teste: valor_total <= 1,00 ou nome/e-mail com 'teste' ou 'test'. O cadastro de teste já sai em s_identidade_comprador.
- Identidade por loja via comprador_hash (CPF só dígitos, senão e-mail trim+lower). Nenhum CPF, e-mail, nome ou telefone na saída.
- Ordenar pedidos por data_hora_pedido, com desempate por pedido_id.
- Intervalo = datediff, em dias inteiros, entre as datas do 2º e do 1º pedido pago.
- Compradores com só 1 pedido ficam fora da média. Informar a contagem de compradores para dar leitura de amostra.
- Agregar itens por pedido e categoria antes do join, por causa do volume (66 mi de itens).
- Categoria vem de s_produtos (categoria atual, não a da data da compra). Documentar essa limitação.
- Criar objetos apenas em fc_catalog.agentic_teams_sandbox.

## Decisões do negócio
- Como definir a 1ª e a 2ª compra de cada categoria? → **Dentro da categoria: 1ª e 2ª compra que contêm aquela categoria (o comprador pode aparecer em várias categorias)**
- A visão deve ser por loja ou consolidada na plataforma? → **Por loja: o comprador é a pessoa dentro de cada loja (padrão do contrato)**

## Medidas
- **tempo_medio_dias**: Média do intervalo em dias entre a 1ª e a 2ª compra paga.
- **mediana_dias**: Mediana do intervalo em dias, menos sensível a outliers.
- **compradores_com_recompra**: Contagem distinta de comprador_hash com 2ª compra.
