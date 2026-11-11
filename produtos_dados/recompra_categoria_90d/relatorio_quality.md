# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (loja × comprador_hash × categoria) | passou | 0 chaves duplicadas em 6.967.085 linhas. O recálculo independente bate em nº de linhas e na soma de qtd_pedidos_pagos (10.750.041), com 0 divergências. |
| 2. Identidade: mesma pessoa na mesma loja = mesmo comprador_hash | passou | 0 grupos (loja, CPF só dígitos) e 0 grupos (loja, e-mail trim+lower) com mais de 1 hash. Nenhum hash aparece em mais de uma loja. Os 7.660 pedidos da janela sem hash são todos de teste. |
| 3. Pedidos de teste excluídos | passou | 0 pedidos pagos da janela com 'test' no nome ou e-mail. O filtro valor_total > 1 está aplicado. |
| 4. Só pedidos pagos | passou | Pagamento aprovado ou estornado, status diferente de cancelado e pendente, e sem chargeback perdido. A reimplementação independente bate com a silver (0 divergências). Janela de 02/08 a 30/10/2026. |
| 5. Sem PII nas saídas | passou | Silver e metric view só expõem loja_id, comprador_hash, categoria, qtd_pedidos_pagos e as datas da janela. |
| 6. Sanidade e consulta com MEASURE() | passou | Em 33.500 combinações loja × categoria, a taxa fica entre 0 e 1, os ativos são sempre > 0 e os recorrentes nunca passam dos ativos. MEASURE() responde por categoria. |

## Resposta da pergunta original (sandbox)

Janela: 02/08/2026 a 30/10/2026 (90 dias até a última data com dados). Top 12 categorias por compradores ativos, somando todas as lojas só para ilustrar:

| Categoria | Compradores ativos | Recorrentes | Taxa de recompra |
|---|---|---|---|
| Roupas Femininas | 481.748 | 64.065 | 13,3% |
| Roupas Masculinas | 363.514 | 45.245 | 12,4% |
| Calçados | 338.779 | 41.233 | 12,2% |
| Ração | 314.311 | 182.970 | 58,2% |
| Moda Íntima | 247.328 | 26.374 | 10,7% |
| Petiscos | 242.920 | 131.879 | 54,3% |
| Acessórios Pet | 240.473 | 130.481 | 54,3% |
| Skincare | 216.896 | 33.546 | 15,5% |
| Higiene Pet | 215.702 | 111.400 | 51,6% |
| Moda Praia | 211.802 | 21.462 | 10,1% |
| Plus Size | 211.762 | 21.668 | 10,2% |
| Maquiagem | 208.637 | 31.956 | 15,3% |
