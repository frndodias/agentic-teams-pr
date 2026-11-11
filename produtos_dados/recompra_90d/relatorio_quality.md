# Relatório do Quality Agent (iteração 2)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | s_recompra_compradores tem 3.436.845 linhas e 3.436.845 chaves distintas (loja_id, comprador_hash). s_recompra_identidade tem 22.251.208 linhas e 22.251.208 pares (loja_id, comprador_id) distintos. |
| 2. Identidade (mesma pessoa na mesma loja = mesmo comprador) | passou | Encontrei 0 contraexemplos. Nenhum par (loja, CPF válido só com dígitos) tem mais de 1 comprador_hash, e nenhum par (loja, e-mail com trim+lower) tem mais de 1 hash. Nenhum cadastro que não seja de teste ficou fora da identidade. Alerta: 1.211.008 compradores unificados têm mais de 1 CPF distinto (m |
| 3. Pedidos de teste excluídos | passou | Recalculei os pedidos pagos da janela excluindo valor_total <= 1,00 e nome ou e-mail com 'test'. O resultado foi 6.350.179, igual a SUM(qtd_pedidos_pagos) da saída. |
| 4. Só pedidos pagos | passou | O filtro usa EXISTS de pagamento aprovado ou estornado, status diferente de cancelado e pendente, e NOT EXISTS de chargeback perdido. Os domínios de status batem com o contrato. A contagem usa COUNT DISTINCT de pedidos, então não há duplicação. A janela vai de 2026-08-02 a 2026-10-30, que são 90 dia |
| 5. Sem dados pessoais nas saídas | passou | As tabelas de saída só têm loja_id, comprador_hash (sha2-256), comprador_id (apenas na tabela de identidade), janela_inicio, janela_fim e qtd_pedidos_pagos. A metric view expõe loja_id, janela_inicio, janela_fim e as 3 medidas. Não há cpf, e-mail, nome nem telefone. Todos os objetos estão no sandbox |
| 6. Sanidade e MEASURE() | passou | MEASURE() retorna ativos = 3.436.845, recorrentes = 667.288 e taxa = 0,1942. A taxa está entre 0 e 1, as contagens são maiores que 0 e recorrentes <= ativos. SELECT * sem MEASURE() é bloqueado, como esperado em metric view. |

## Resposta da pergunta original (sandbox)

| Janela início | Janela fim | Compradores ativos | Compradores recorrentes | Taxa de recompra |
|---|---|---|---|---|
| 2026-08-02 | 2026-10-30 | 3.436.845 | 667.288 | 19,42% |
