# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | Silver: 6.350.179 linhas = 6.350.179 pedido_id distintos. Metric view: uma linha por Loja × Data de Referência (7.334 lojas, 1 data). Compradores ativos = 3.581.733 = grupos distintos (loja, chave, data_ref). |
| 2. Identidade: mesma pessoa na mesma loja = mesmo comprador | passou | 0 casos de mesmo CPF (só dígitos) em 2+ chaves na mesma loja. 101.180 e-mails (trim+lower) em 2+ chaves, todos com 2+ CPFs distintos na loja (ambíguos, pessoas diferentes). Nenhum e-mail com 1 CPF ficou dividido. Unir os ambíguos mudaria os ativos em cerca de 0,3% e quase nada na taxa. Ressalva baix |
| 3. Pedidos de teste excluídos | passou | 0 pedidos com valor_total <= 1,00 ou nome/e-mail com 'test' na silver. Menor valor = 20,07. |
| 4. Só pedidos pagos | passou | 0 cancelados ou pendentes, 0 sem pagamento aprovado/estornado e 0 com chargeback perdido. Recontagem independente: 0 pedidos elegíveis ficaram de fora. Devolvidos estão incluídos. Janela 02/08 a 30/10/2026. |
| 5. LGPD: nenhum dado pessoal exposto | passou | A metric view tem só Loja, Data de Referência, Loja Atípica e as 3 medidas. A chave_comprador da silver é sha2 (64 caracteres hex) em 100% das linhas. Não há cpf, e-mail, nome nem telefone. |
| 6. Sanidade e resposta com MEASURE() | passou | 7.334 lojas: 0 com taxa fora de [0,1], 0 com ativos <= 0, 0 com recorrentes > ativos. Média das lojas = 15,21%. As 64 lojas atípicas ficam entre 39,2% e 59,3%. L003053 = 55,89% e L009457 = 55,06%, como na spec. A consulta com MEASURE() e GROUP BY Loja responde. |

## Resposta da pergunta original (sandbox)

Data de referência: 30/10/2026 (janela de 90 dias: 02/08 a 30/10/2026). Recorrência por loja (Taxa de Recompra = Recorrentes / Ativos):

| Loja | Loja Atípica | Compradores Ativos | Compradores Recorrentes | Taxa de Recompra |
|---|---|---|---|---|
| L003053 | Sim | 42.580 | 23.798 | 55,89% |
| L009457 | Sim | 36.663 | 20.185 | 55,06% |
| L004774 | Não | 25.313 | 3.840 | 15,17% |
| L007714 | Não | 25.282 | 3.912 | 15,47% |
| L002348 | Não | 25.045 | 3.852 | 15,38% |
| Média das 7.334 lojas | - | - | - | 15,21% |
| Média das 7.270 lojas não atípicas | - | - | - | 14,86% |
