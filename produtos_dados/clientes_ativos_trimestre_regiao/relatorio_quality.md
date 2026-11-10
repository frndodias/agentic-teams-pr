# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão | passou | s_pedidos_pagos_trimestre: 28.279.420 linhas = 28.279.420 pedido_id distintos. s_identidade_comprador: 22.267.919 linhas = 22.267.919 pares (comprador_id, loja_id) distintos. Nenhum comprador_sk em mais de uma loja. |
| 2. Identidade (mesmo CPF/e-mail na mesma loja → mesmo comprador_sk) | passou | 0 grupos loja+e-mail com mais de um comprador_sk. 1.727 grupos loja+CPF com mais de um sk, todos nos CPFs placeholder 00000000000 e 12345678909, que não devem ser unificados. 0 contraexemplos para CPFs reais. Ressalva: 890.974 sks reúnem mais de um CPF real distinto na mesma loja, via e-mail compart |
| 3. Pedidos de teste excluídos | passou | 0 pedidos com valor_total <= 1,00 e 0 com 'test' no nome ou e-mail na saída. Os 16.711 cadastros de teste de s_compradores coincidem com flag_teste. |
| 4. Só pedidos pagos | passou | 0 pedidos sem pagamento aprovado/estornado, 0 com chargeback perdido, 0 cancelados ou pendentes. status_pedido igual ao de s_pedidos (0 divergências). |
| 5. LGPD: sem dados pessoais nas saídas | passou | 0 colunas cpf/email/nome/telefone nas saídas. A metric view expõe só Região, Trimestre, Janela e Loja, mais medidas agregadas. A única chave de pessoa é comprador_sk (hash). |
| 6. Sanidade e MEASURE() na pergunta original | passou | MEASURE() por região na janela 'Último trimestre civil' (01/07 a 30/09/2026) retorna 5 regiões com contagens > 0 e clientes_unicos < pedidos_pagos. Pedidos por região batem com a tabela de saída. Não há taxas na entrega. |

## Resposta da pergunta original (sandbox)

| Região | Clientes únicos (por loja) | Pedidos pagos |
|---|---|---|
| Sudeste | 2.085.460 | 3.354.349 |
| Sul | 668.976 | 1.025.769 |
| Nordeste | 328.039 | 503.037 |
| Centro-Oeste | 228.799 | 336.126 |
| Norte | 68.326 | 107.779 |

Período: 01/07 a 30/09/2026. Cada cliente conta uma vez por loja, então a soma das regiões não é o total consolidado.
