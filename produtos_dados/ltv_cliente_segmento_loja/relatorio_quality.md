# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (loja_id, comprador_hash) | passou | 17.272.853 linhas e 17.272.853 pares distintos. Nenhum comprador_hash é nulo. As 10.000 lojas existem em s_lojas e nenhum segmento é nulo. |
| 2. Identidade: mesmo CPF (só dígitos) ou mesmo e-mail (trim+lower) na mesma loja = mesmo comprador_hash | passou | Em 564.011 grupos (loja, CPF) com mais de um cadastro, 0 têm mais de um hash. Em 1.439.251 grupos (loja, e-mail), 0 têm mais de um hash. Ressalva sem reprovação: 890.974 hashes agrupam cadastros com CPFs diferentes (fusão transitiva por e-mail em s_identidade_comprador). |
| 3. Pedidos de teste excluídos | passou | O recálculo a partir de s_pedidos mostra 0 pedidos com valor_total <= 1,00 e 0 de compradores com 'test' no nome ou e-mail. Os totais batem com a tabela entregue. |
| 4. Só pedidos pagos (pagamento aprovado/estornado, status ≠ cancelado/pendente, sem chargeback perdido) | passou | O recálculo independente dá 28.279.420 pedidos e R$ 15.755.838.373,32, idêntico à tabela silver. Todos os pedidos válidos têm hash. Pedidos devolvidos contam. Os dados vão de 2024-10-31 a 2026-10-30. |
| 5. Nenhum dado pessoal nas colunas de saída | passou | As colunas da tabela são loja_id, comprador_hash (sha256), segmento, status_loja, qtd_pedidos, receita_total e datas. A metric view expõe 2 dimensões e 3 medidas, sem CPF, e-mail, nome ou telefone. |
| 6. Sanidade e resposta com MEASURE() | passou | A metric view responde com MEASURE() por `Segmento da Loja`. Os 10 segmentos têm contagens > 0 e o LTV bate com sum(receita)/count(*) da tabela silver. Não há taxas na especificação. A divisão usa 1.0 e não trunca. |

## Resposta da pergunta original (sandbox)

| Segmento da Loja | Clientes | Receita Total (R$) | LTV Médio (R$) |
|---|---|---|---|
| Eletrônicos | 1.262.546 | 5.789.088.417,89 | 4.585,25 |
| Pet Shop | 1.202.312 | 1.998.165.340,17 | 1.661,94 |
| Casa & Decoração | 1.595.916 | 1.306.295.674,01 | 818,52 |
| Acessórios | 1.351.391 | 1.031.503.288,93 | 763,29 |
| Esporte & Fitness | 1.576.206 | 1.112.386.479,73 | 705,74 |
| Moda | 4.841.038 | 2.457.026.755,75 | 507,54 |
| Infantil | 1.269.465 | 583.727.079,12 | 459,82 |
| Beleza & Cosméticos | 2.098.487 | 923.067.294,81 | 439,87 |
| Saúde & Bem-estar | 734.543 | 219.658.657,83 | 299,04 |
| Alimentos & Bebidas | 1.340.949 | 334.919.385,08 | 249,76 |
