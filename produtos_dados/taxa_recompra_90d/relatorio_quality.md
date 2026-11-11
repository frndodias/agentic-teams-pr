# Relatório do Quality Agent (iteração 3)

**Resultado:** ⚠️ reprovado — decisão do revisor humano

| Teste | Status | Evidência |
|---|---|---|
| Unicidade do grão | passou | s_pedidos_pagos_comprador: 6.350.179 linhas = 6.350.179 pedido_id distintos. s_identidade_comprador: 22.267.919 linhas = 22.267.919 pares (comprador_id, loja_id) distintos. |
| Identidade: mesma pessoa na mesma loja cai no mesmo comprador unificado | falhou | 1.211.034 pares (loja, e-mail) com mais de uma chave. 320.034 deles têm 1 CPF válido mais cadastros sem CPF, que ficam com chave de e-mail e viram comprador separado. Isso afeta 284.017 chaves e 985.780 pedidos na janela. 891.000 e-mails têm vários CPFs na mesma loja. Exemplo: L003053 / alice.pinto@ |
| Pedidos de teste excluídos | passou | 0 pedidos com valor_total <= 1,00 ou nome/e-mail com 'test' na tabela de saída. O menor valor_total é 20,07. |
| Só pedidos pagos (pagamento aprovado/estornado, status, chargeback perdido) | falhou | Não conclusivo: a consulta de validação cruzando s_pagamentos, s_disputas e status falhou com INTERNAL_ERROR do Spark e o limite de ferramentas foi atingido. Registrado como falhou por falta de evidência. A lógica do SQL parece correta, mas precisa de nova validação. |
| Nenhum dado pessoal exposto | passou | Colunas da tabela de saída: pedido_id, loja_id, chave_comprador (sha2), tipo_chave, data_pedido, valor_total, status_pedido, data_referencia. Dimensões da metric view: Loja e Data de Referência. Verificado só pelos nomes das colunas. |
| Sanidade: taxas entre 0 e 1, contagens > 0, MEASURE() responde | passou | 7.334 lojas. Taxa mínima 0 e máxima 1. Mínimo de compradores ativos por loja = 1. Janela de 2026-08-02 a 2026-10-30. MEASURE() funciona. Os números ainda estão sujeitos à correção de identidade. |

## Resposta da pergunta original (sandbox)

| Janela (90 dias até 30/10/2026) | Compradores ativos | Compradores recorrentes | Taxa de recompra |
|---|---|---|---|
| Soma das 7.334 lojas (visão por loja) | 3.692.128 | 646.380 | ~17,5% (provisório; tende a subir após corrigir a identidade) |

A taxa por loja varia de 0% a 100%. Os números são provisórios porque a identidade ainda tem falhas e só devem ser usados depois da correção.
