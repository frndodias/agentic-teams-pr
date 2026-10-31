# Relatório do Quality Agent (iteração 2)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | s_compradores_unificados tem 22.267.919 linhas, o mesmo número de s_compradores, sem comprador_id duplicado e sem hash nulo. s_recompra_categoria_base tem 6.967.085 linhas e nenhuma duplicata em (loja, categoria, comprador_hash). Nenhum qtd_pedidos_pagos é nulo ou menor que 1, nem maior que qtd_pedi |
| 2. Identidade (mesmo CPF/e-mail na mesma loja => mesmo comprador) | passou | Não achei contraexemplos. Há 0 pares (loja, CPF só com dígitos) com mais de 1 hash e 0 pares (loja, e-mail com trim e lower) com mais de 1 hash. Os dados têm 5,0M CPFs formatados e 721 mil e-mails com maiúsculas, e todos foram normalizados. Nenhum cadastro ficou sem CPF e sem e-mail. |
| 3. Pedidos de teste excluídos | passou | flag_teste bate com a regra independente (nome ou e-mail com 'test', sem diferenciar maiúsculas), com 0 divergências nos dois sentidos. Há 0 hashes de teste na base. Nenhum hash mistura teste e não teste. A base filtra valor_total > 1. |
| 4. Só pedidos pagos | passou | Reimplementei o filtro de pedido pago com IN / NOT IN e achei 6.350.179 pedidos. A soma de qtd_pedidos_pagos_loja na base dá o mesmo valor. A regra cobre pagamento aprovado ou estornado, status diferente de cancelado e pendente (devolvido conta como pago) e exclui só chargeback perdido. Antes de pub |
| 5. Sem dados pessoais nas saídas | passou | As tabelas e a metric view só expõem loja_id, categoria, comprador_hash (sha2 com salt de loja), contagens e flag_teste. Não há cpf, email, nome nem telefone. |
| 6. Sanidade e MEASURE() | passou | A metric view responde com MEASURE() por loja e categoria (7.334 lojas, 41 categorias). A taxa vai de 0 a 1, e nenhuma linha tem taxa fora de [0,1] ou ativos <= 0. Sem dimensão, compradores_ativos = 3.436.845, igual ao distinto por loja na base. Ressalva não bloqueante: compradores_recorrentes sem d |

## Resposta da pergunta original (sandbox)

Taxa de recompra (compradores com 2+ pedidos pagos na categoria nos últimos 90 dias, até 2026-10-31). Identidade por loja, agrupada por categoria; mostro as 8 categorias com mais compradores ativos de 41.

| Categoria | Compradores ativos | Compradores recorrentes | Taxa de recompra |
|---|---|---|---|
| Roupas Femininas | 481.748 | 64.065 | 13,3% |
| Roupas Masculinas | 363.514 | 45.245 | 12,5% |
| Calçados | 338.779 | 41.233 | 12,2% |
| Ração | 314.311 | 182.970 | 58,2% |
| Moda Íntima | 247.328 | 26.374 | 10,7% |
| Petiscos | 242.920 | 131.879 | 54,3% |
| Acessórios Pet | 240.473 | 130.481 | 54,3% |
| Skincare | 216.896 | 33.546 | 15,5% |

As categorias pet (Ração, Petiscos, Acessórios Pet) recompram muito mais que as demais. Sem categoria, a taxa total é 16,8% (577.428 de 3.436.845 compradores).
