# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (loja_id, comprador_hash, categoria) | passou | 4.762.540 linhas e 4.762.540 combinações distintas, sem nulos. Recomputei de forma independente a 1ª e a 2ª compra por categoria, e todas as 4.762.540 linhas casam em pedido_id. Não há intervalos negativos (mín. 0, máx. 729). |
| 2. Identidade: mesmo CPF ou e-mail na mesma loja = mesmo comprador_hash | passou | Nenhum contraexemplo: 0 grupos (loja, CPF só dígitos) e 0 grupos (loja, e-mail trim+lower) com mais de 1 hash. Os 16.711 cadastros sem hash são de teste (tipo 'conta' com 'test' no nome ou e-mail). |
| 3. Pedidos de teste excluídos | passou | Dos 6.848.028 pedidos usados, 0 têm valor_total <= 1,00 e 0 pertencem a comprador com 'test' no nome ou e-mail. |
| 4. Só pedidos pagos | passou | Nos pedidos usados: 0 cancelados ou pendentes, 0 sem pagamento aprovado ou estornado, 0 com chargeback perdido. |
| 5. Sem dados pessoais nas saídas | passou | Nenhuma coluna com nome parecido com cpf, mail, nome ou telefone. comprador_hash é sha256 de 64 caracteres hex. A metric view expõe só Loja, Categoria e Mês da Primeira Compra. |
| 6. Sanidade e MEASURE() | passou | MEASURE() responde por 40 categorias. Os valores são positivos e a mediana fica abaixo da média. Ração tem a menor média (51,4 dias) e Roupas Infantis a maior (129,5 dias). |

## Resposta da pergunta original (sandbox)

Tempo médio entre a 1ª e a 2ª compra paga, por categoria (histórico completo, só quem recomprou). Mostro as 5 categorias mais rápidas e as 3 mais lentas, de 40 no total.

| Categoria | Tempo médio (dias) | Mediana (dias) | Compradores com recompra |
|---|---|---|---|
| Ração | 51,4 | 23 | 447.782 |
| Acessórios Pet | 56,7 | 30 | 347.382 |
| Petiscos | 56,8 | 30 | 349.922 |
| Higiene Pet | 58,9 | 33 | 307.007 |
| Móveis | 109,4 | 64 | 47.754 |
| ... | ... | ... | ... |
| Bebê | 128,5 | 78 | 70.253 |
| Roupas Infantis | 129,5 | 78 | 96.017 |

As categorias pet recompram mais rápido, em 51 a 59 dias. A maioria das outras fica entre 110 e 130 dias.
