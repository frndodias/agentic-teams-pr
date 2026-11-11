# Relatório do Quality Agent (iteração 3)

**Resultado:** ⚠️ reprovado — decisão do revisor humano

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (pedido_id, comprador_hash, categoria) | passou | 10.750.041 linhas e 10.750.041 combinações distintas. qtd_pedidos_comprador é consistente com a contagem por categoria (0 inconsistências em 7,12 mi de pares comprador × categoria). |
| 2a. Identidade: mesmo CPF (só dígitos) na mesma loja → mesmo comprador | passou | 0 pares (loja, CPF) com mais de um comprador_hash. |
| 2b. Identidade: mesmo e-mail (trim+lower) na mesma loja → mesmo comprador | falhou | 91.041 e-mails por loja caem em 2+ comprador_hash (216.462 hashes no total). Todos têm 2+ CPFs distintos, e 22.408 têm mais de 2 CPFs. A silver só liga por e-mail os cadastros sem CPF. Cadastros com CPFs diferentes e o mesmo e-mail continuam separados. Em 9.309 e-mails, o cadastro sem CPF é atribuíd |
| 3. Pedidos de teste excluídos | passou | Na silver há 0 pedidos com valor_total <= 1 e 0 com 'test' no nome ou e-mail do comprador. |
| 4. Só pedidos pagos | passou | Há 0 pedidos cancelados ou pendentes, 0 sem pagamento aprovado ou estornado e 0 com chargeback perdido. Reconstrução independente do filtro: 6.350.179 pedidos, igual à silver. Janela de 2026-08-02 a 2026-10-30. |
| 5. LGPD: sem dados pessoais nas colunas de saída | passou | A silver e a metric view não têm cpf, e-mail, nome nem telefone. Só há hash, loja, categoria e datas. Observação: sha2 sem salt sobre CPF de 11 dígitos pode ser revertido por força bruta. |
| 6. Sanidade e MEASURE() | passou | Não há nenhuma linha (loja × categoria) com taxa fora de [0,1] ou com Compradores Ativos <= 0. A consulta com MEASURE() por categoria responde, com taxas entre 9,6% e 56,6%. |

## Resposta da pergunta original (sandbox)

Resultado PRELIMINAR (não aprovado, pois a identidade ainda divide compradores). Janela de 90 dias até 2026-10-30, recompra dentro da categoria, por categoria (as categorias não somam o total):

| Categoria | Compradores ativos | Recorrentes | Taxa de recompra |
|---|---|---|---|
| Ração | 331.990 | 188.008 | 56,6% |
| Acessórios Pet | 251.358 | 132.502 | 52,7% |
| Petiscos | 254.571 | 134.101 | 52,7% |
| Higiene Pet | 226.009 | 113.240 | 50,1% |
| Mercearia | 180.152 | 27.705 | 15,4% |
| Roupas Femininas | 489.035 | 59.331 | 12,1% |
| Plus Size (menor) | 213.513 | 20.393 | 9,6% |

As demais categorias ficam entre 9,6% e 15,4%.
