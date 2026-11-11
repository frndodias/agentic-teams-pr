# Relatório do Quality Agent (iteração 2)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | s_recompra_compradores: 3.436.845 linhas = 3.436.845 pares (loja_id, comprador_chave) distintos. s_recompra_identidade: 22.267.919 linhas, uma por (loja_id, comprador_id), igual ao s_compradores. |
| 2. Identidade (mesmo CPF/e-mail na mesma loja = mesmo comprador) | passou | 0 pares (loja, CPF só dígitos) com mais de uma chave e 0 pares (loja, e-mail trim+lower) com mais de uma chave. Há 891.000 e-mails com mais de um CPF e 1.962 CPFs com mais de um e-mail, unidos em componentes conectados. Nenhum cadastro sem CPF e sem e-mail. |
| 3. Pedidos de teste excluídos | passou | 7.513 pedidos pagos na janela são de teste (valor_total<=1 ou 'test' no nome/e-mail). O recálculo independente deu 3.436.845 ativos e 667.288 recorrentes, idêntico à tabela entregue. |
| 4. Só pedidos pagos (pagamento aprovado/estornado, status, chargeback perdido) | passou | Valores de status conferidos. Pagamento aprovado/estornado, pedidos cancelado/pendente excluídos, devolvido incluído, chargeback perdida excluído e MED perdida mantida. Deduplicação por pedido_id. Recálculo independente coincide (taxa 0,19416). |
| 5. Sem dados pessoais nas saídas | passou | As tabelas de saída têm só loja_id, comprador_chave (sha2), pedidos_pagos, datas da janela e, na identidade, comprador_id. A metric view expõe só loja_id, data_fim_janela, data_inicio_janela e medidas agregadas. |
| 6. Sanidade e resposta com MEASURE() | passou | MEASURE() responde. Consolidado em 2026-10-30: 3.436.845 ativos, 667.288 recorrentes, taxa 0,1942. 7.334 lojas, taxa entre 0 e 1, nenhuma com ativos<=0. Janela de 2026-08-02 a 2026-10-30 (90 dias). |

## Resposta da pergunta original (sandbox)

| Data fim da janela | Compradores ativos | Compradores recorrentes | Taxa de recompra |
|---|---|---|---|
| 2026-10-30 (janela de 02/08 a 30/10/2026) | 3.436.845 | 667.288 | 19,42% |

Por loja, as maiores são: L003053 com 61,3% (32.564 ativos), L009457 com 60,9% (28.612), L004774 com 24,1% (21.212), L007714 com 24,6% (21.144) e L002348 com 24,4% (21.033).
