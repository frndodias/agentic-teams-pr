# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (silver: pedido_id) | passou | 5.327.060 linhas e 5.327.060 pedido_id distintos. comprador_hash nulo: 0. A identidade tem 1 linha por (loja, comprador_id), então o JOIN não duplica. |
| 2. Identidade: mesmo CPF (só dígitos) ou mesmo e-mail (trim+lower) na mesma loja = mesmo comprador_hash | passou | Grupos (loja, CPF só dígitos) com mais de 1 hash: 0. Grupos (loja, e-mail trim+lower) com mais de 1 hash: 0. Pedidos pagos do trimestre sem identidade: 0. |
| 3. Pedidos de teste excluídos | passou | Na silver, pedidos com valor_total <= 1,00, ou nome/e-mail com 'test' (cobre 'teste'): 0. Menor valor_total: 20,34. |
| 4. Só pedidos pagos (pagamento aprovado/estornado, status, chargeback perdido) | passou | Pedidos cancelados ou pendentes: 0. Pedidos sem pagamento aprovado/estornado: 0. Pedidos com chargeback perdido: 0. Devolvidos mantidos. Janela de 2026-07-01 a 2026-09-30 23:59:59, um único trimestre ('2026-T3'). |
| 5. Nenhum dado pessoal nas saídas | passou | Colunas da silver e da metric view sem cpf, e-mail, nome nem telefone. O comprador_hash só existe na silver (sandbox) e aparece na metric view apenas dentro de uma medida agregada. Recomendo restringir o acesso à silver. |
| 6. Sanidade e resposta à pergunta com MEASURE() | passou | MEASURE() responde por região e bate com a conta direta na silver. Todas as contagens são > 0 e clientes únicos <= pedidos pagos em todas as regiões. 'Sem região' = 0. Cada pedido tem loja em s_lojas. Não há taxas na entrega. |

## Resposta da pergunta original (sandbox)

Clientes únicos com compra paga no 3º trimestre de 2026 (jul a set), contados por loja. A soma das lojas da região pode passar do total de clientes distintos.

| Região | Clientes únicos | Pedidos pagos |
|---|---:|---:|
| Sudeste | 2.085.460 | 3.354.349 |
| Sul | 668.976 | 1.025.769 |
| Nordeste | 328.039 | 503.037 |
| Centro-Oeste | 228.799 | 336.126 |
| Norte | 68.326 | 107.779 |
