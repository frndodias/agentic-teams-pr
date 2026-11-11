# Relatório do Quality Agent (iteração 3)

**Resultado:** ⚠️ reprovado — decisão do revisor humano

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (pedido_id, categoria, comprador_hash) | passou | 10.750.041 linhas e 10.750.041 combinações distintas. Sem duplicatas e sem nulos. Todas as datas dentro da janela de 90 dias (2026-08-02 a 2026-10-30). |
| 2. Identidade: mesmo CPF ou e-mail na mesma loja => mesmo comprador | falhou | CPF + loja: 0 quebras. E-mail (trim+lower) + loja: 91.041 e-mails em 2 ou mais comprador_hash, cerca de 437 mil linhas-pedido. Todos têm 2 a 12 CPFs válidos distintos. A silver só une ao CPF dominante os cadastros sem CPF. Cadastros com CPF próprio ficam em hashes separados. Subestima compradores re |
| 3. Pedidos de teste excluídos | passou | 0 linhas com valor_total <= 1, nome ou e-mail com 'test'. O recálculo independente do universo dá 6.350.179 pedidos, igual à silver. |
| 4. Só pedidos pagos (pagamento aprovado/estornado, status, chargeback perdido) | passou | 0 violações de status, pagamento ou chargeback perdido. O recálculo independente bate exatamente com a silver. |
| 5. Sem dados pessoais nas saídas | passou | Silver e metric view sem cpf, e-mail, nome ou telefone. comprador_hash é sha256 de 64 caracteres, com 0 violações de formato. |
| 6. Sanidade e metric view com MEASURE() | passou | MEASURE() responde por Categoria: 41 categorias, ativos > 0 e taxas entre 0,09 e 0,57 nas 40 linhas retornadas. Os valores batem com o recálculo na silver. Fallback comprador_id não usado. Limitação: a checagem por Loja falhou por erro de nome de coluna (loja_id em vez de `Loja`) e não foi refeita.  |

## Resposta da pergunta original (sandbox)

Resultado provisório, a identidade ainda precisa de correção. Janela de 2026-08-02 a 2026-10-30, recompra dentro da categoria, categorias não somam o total.

| Categoria | Compradores ativos | Recorrentes | Taxa de recompra |
|---|---|---|---|
| Roupas Femininas | 489.035 | 59.331 | 12,1% |
| Roupas Masculinas | 367.958 | 42.285 | 11,5% |
| Calçados | 342.576 | 38.695 | 11,3% |
| Ração | 331.990 | 188.008 | 56,6% |
| Petiscos | 254.571 | 134.101 | 52,7% |
| Acessórios Pet | 251.358 | 132.502 | 52,7% |
| Higiene Pet | 226.009 | 113.240 | 50,1% |
| Moda Íntima | 249.325 | 24.897 | 10,0% |
| Skincare | 220.750 | 31.180 | 14,1% |
