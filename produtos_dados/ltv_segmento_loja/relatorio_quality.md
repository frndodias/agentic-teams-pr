# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (loja_id + comprador_sk) | passou | 17.272.853 linhas e 17.272.853 chaves distintas. Sem chaves nulas e sem receita ou pedidos <= 0. |
| 2. Identidade: mesma pessoa na mesma loja = mesmo comprador_sk | passou | Entre cadastros não-teste, 0 grupos de CPF normalizado e 0 grupos de e-mail (trim+lower) com mais de 1 comprador_sk. Nenhum sk aparece em mais de 1 loja. Os 1.727 grupos de CPF quebrados envolvem só cadastros flag_teste=1, que são excluídos do LTV. |
| 3. Pedidos de teste excluídos | passou | Todos os 77.709 pedidos de compradores de teste têm valor <= 1,00, e não há pedido com valor <= 1 entre os não-teste. Nenhum pedido restante vem de comprador com 'test' no nome ou e-mail. |
| 4. Só pedidos pagos válidos | passou | A linha de base independente dá 28.279.420 pedidos e R$ 15.755.838.373,32, idênticos à tabela silver. |
| 5. Sem dado pessoal nas saídas | passou | As colunas da tabela e as dimensões da metric view não contêm cpf, e-mail, nome nem telefone. O comprador_sk é um hash. |
| 6. Sanidade e MEASURE() | passou | MEASURE() responde nos 10 segmentos com valores > 0, e o LTV bate com o cálculo direto na silver. Lojas ativas e inativas entram. |

## Resposta da pergunta original (sandbox)

| Segmento | LTV médio (R$) | Receita total (R$) | Compradores | Pedidos por comprador |
|---|---|---|---|---|
| Eletrônicos | 4.585,25 | 5.789.088.417,89 | 1.262.546 | 1,33 |
| Pet Shop | 1.661,94 | 1.998.165.340,17 | 1.202.312 | 5,16 |
| Casa & Decoração | 818,52 | 1.306.295.674,01 | 1.595.916 | 1,32 |
| Acessórios | 763,29 | 1.031.503.288,93 | 1.351.391 | 1,33 |
| Esporte & Fitness | 705,74 | 1.112.386.479,73 | 1.576.206 | 1,39 |
| Moda | 507,54 | 2.457.026.755,75 | 4.841.038 | 1,34 |
| Infantil | 459,82 | 583.727.079,12 | 1.269.465 | 1,40 |
| Beleza & Cosméticos | 439,87 | 923.067.294,81 | 2.098.487 | 1,41 |
| Saúde & Bem-estar | 299,04 | 219.658.657,83 | 734.543 | 1,43 |
| Alimentos & Bebidas | 249,76 | 334.919.385,08 | 1.340.949 | 1,52 |
