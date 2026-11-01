# Relatório do Quality Agent (iteração 3)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | s_pedidos_pagos_categoria tem 10.664.056 linhas, todas distintas em (pedido, loja, categoria). s_compradores_recompra_categoria tem 5.809.074 linhas distintas em (loja, comprador_sk, categoria). s_identidade_comprador tem 22.267.919 linhas distintas em (comprador_id, loja). A soma de total_pedidos ( |
| 2. Identidade: mesma pessoa na mesma loja = mesmo comprador | passou | Por e-mail (trim+lower): 0 chaves divididas em mais de um comprador_sk. Por CPF só com dígitos: 1.727 pares (loja, CPF) estão divididos, todos em CPFs placeholder (917 de 00000000000 e 810 de 12345678909). Entre CPFs válidos, 0 divisões. RESSALVA: tratar placeholder como ausente se afasta da regra l |
| 3. Pedidos de teste excluídos | passou | 0 pedidos com valor_total <= 1,00. 0 pedidos de compradores com 'test' (inclui 'teste') no nome ou e-mail. |
| 4. Só pedidos pagos e válidos | passou | 0 pedidos com status cancelado ou pendente, sem pagamento aprovado ou estornado, ou com chargeback perdido. 0 linhas fora da janela. 0 cadastros sem chave, então nenhum pedido pago válido foi descartado por falta de identidade. |
| 5. Sem dados pessoais nas saídas | passou | As colunas das tabelas e da metric view não incluem cpf, email, nome nem telefone. O comprador_sk é sha2. |
| 6. Sanidade e resposta com MEASURE() | passou | A metric view responde com MEASURE() por loja x categoria (33.438 linhas). A taxa fica entre 0 e 1, sem nulos, e os ativos são >= 1 em todas as linhas. Ração é um outlier (57,7% contra 13-19% nas demais categorias). |

## Resposta da pergunta original (sandbox)

| Categoria | Compradores ativos | Compradores recorrentes | Taxa de recompra |
|---|---|---|---|
| Roupas Femininas | 434.192 | 59.043 | 13,6% |
| Roupas Masculinas | 314.800 | 42.701 | 13,6% |
| Calçados | 290.639 | 39.576 | 13,6% |
| Ração | 243.452 | 140.530 | 57,7% |
| Moda Íntima | 204.209 | 27.588 | 13,5% |
| Skincare | 192.467 | 30.737 | 16,0% |
| Maquiagem | 184.014 | 29.397 | 16,0% |
| Mercearia | 153.789 | 28.911 | 18,8% |

A tabela mostra as 8 categorias com mais compradores ativos, somando todas as lojas. Compradores ativos de lojas diferentes são contados separadamente. A recompra é geral (2+ pedidos pagos em qualquer categoria), atribuída à categoria do primeiro pedido, na janela de 2026-08-03 a 2026-11-01.
