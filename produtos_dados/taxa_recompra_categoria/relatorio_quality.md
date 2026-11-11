# Relatório do Quality Agent (iteração 2)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | 0 duplicatas em (loja_id, categoria, comprador_hash) na tabela silver e 0 em (comprador_id, loja_id) na tabela de identidade. Não há nulos, e todo hash tem 64 caracteres hexadecimais. |
| 2. Identidade (mesma pessoa, mesma loja = mesmo comprador) | passou | Em 22,25 milhões de cadastros mapeados, nenhuma chave (loja, CPF só dígitos) ou (loja, e-mail trim+lower) tem mais de um comprador_hash. Não encontrei contraexemplo. |
| 3. Pedidos de teste excluídos | passou | Meu recálculo independente deu 9.793.577 pares pedido×categoria, igual à soma de qtd_pedidos_pagos da tabela. Os 6.705 pedidos de cadastros de teste na janela, todos com valor<=1, ficaram fora. |
| 4. Só pedidos pagos | passou | O filtro usa pagamento aprovado ou estornado (EXISTS), exclui status cancelado e pendente e exclui chargeback perdido. Minha reimplementação deu 5.786.410 pedidos válidos, sem duplicidade. |
| 5. Sem dados pessoais nas saídas | passou | As colunas das tabelas e da metric view são só loja_id, categoria, comprador_hash, qtd_pedidos_pagos e data_referencia. Não há cpf, e-mail, nome nem telefone. |
| 6. Sanidade e metric view com MEASURE() | passou | A consulta com MEASURE() responde em 33.195 combinações loja×categoria. Há 0 taxas fora de [0,1], 0 grupos com ativos<=0 e 0 grupos com recorrentes>ativos. |

## Resposta da pergunta original (sandbox)

Taxa de recompra por categoria nos 90 dias até 2026-11-10, somada sobre todas as lojas. Mostro as 12 categorias com mais compradores ativos, e a consulta devolveu só essas 12 linhas.

| Categoria | Compradores ativos | Recorrentes | Taxa de recompra |
|---|---|---|---|
| Roupas Femininas | 434.868 | 58.259 | 13,4% |
| Roupas Masculinas | 328.211 | 40.951 | 12,5% |
| Calçados | 305.990 | 37.232 | 12,2% |
| Ração | 296.125 | 172.968 | 58,4% |
| Petiscos | 228.637 | 123.487 | 54,0% |
| Acessórios Pet | 226.526 | 122.208 | 53,9% |
| Moda Íntima | 223.333 | 23.943 | 10,7% |
| Higiene Pet | 203.013 | 103.902 | 51,2% |
| Skincare | 196.527 | 30.540 | 15,5% |
| Plus Size | 191.259 | 19.585 | 10,2% |
| Moda Praia | 191.208 | 19.447 | 10,2% |
| Maquiagem | 189.387 | 29.130 | 15,4% |
