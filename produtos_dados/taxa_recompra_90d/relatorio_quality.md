# Relatório do Quality Agent (iteração 2)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (silver: 1 linha por pedido pago) | passou | 6.350.179 linhas e 6.350.179 pedido_id distintos. Janela de 2026-08-02 a 2026-10-30, que são 90 dias terminando no último dado. |
| 2. Identidade: mesmo CPF ou mesmo e-mail na mesma loja caem no mesmo comprador | passou | Mesmo CPF na mesma loja: 0 contraexemplos. Mesmo e-mail com chaves diferentes: 101.180 casos. Todos têm e-mail compartilhado por 2+ CPFs, tratado de propósito como ambíguo. Unificar esses e-mails tornaria recorrentes só cerca de 1.905 compradores, de 3,58 milhões de ativos. |
| 3. Pedidos de teste excluídos | passou | 0 pedidos com valor_total <= 1,00 ou com 'test' no nome ou e-mail. |
| 4. Só pedidos pagos | passou | 0 pedidos cancelados ou pendentes, 0 sem pagamento aprovado ou estornado, 0 com chargeback perdido. |
| 5. LGPD: nenhum dado pessoal exposto | passou | A chave do comprador é sha2-256. A silver e a metric view não têm CPF, e-mail, nome nem telefone. |
| 6. Sanidade e resposta à pergunta com MEASURE() | passou | 7.334 lojas, nenhuma com taxa fora de [0,1], nenhuma com ativos <= 0, nenhuma com recorrentes > ativos. Alerta para L003053 (55,9%) e L009457 (55,1%), muito acima das demais lojas, que ficam em 11% a 15%. |

## Resposta da pergunta original (sandbox)

| Loja | Compradores ativos | Compradores recorrentes | Taxa de recompra (90d até 2026-10-30) |
|---|---|---|---|
| L003053 | 42.580 | 23.798 | 55,9% |
| L009457 | 36.663 | 20.185 | 55,1% |
| L004774 | 25.313 | 3.840 | 15,2% |
| L007714 | 25.282 | 3.912 | 15,5% |
| L002348 | 25.045 | 3.852 | 15,4% |
| (top 5 lojas por ativos; 7.334 lojas no total) | | | |

A soma das lojas dá 3.581.733 ativos e 624.725 recorrentes. Isso é só soma de lojas, não consolidado da plataforma.
