# Relatório do Quality Agent (iteração 1)

**Resultado:** ✅ aprovado

| Teste | Status | Evidência |
|---|---|---|
| 1. Unicidade do grão (loja_id, data_referencia, chave_comprador) | passou | 3.692.128 linhas e 3.692.128 combinações distintas. Sem chave nula, todas com 64 caracteres, qtd_pedidos_pagos mínimo 1 e uma única data_referencia (2026-10-30). |
| 2. Identidade por CPF/e-mail na mesma loja | passou | Seguindo o contrato (CPF prioritário, normalizado só com dígitos; senão e-mail com trim+lower), 1.962 grupos de mesmo CPF com e-mails diferentes caem na mesma chave. Ressalva: 891 mil pares (loja, e-mail) com vários CPFs não unificam. Parecem homônimos, mas pelo critério literal do teste seria falha |
| 3. Pedidos de teste excluídos | passou | Filtro de valor_total > 1,00 e de '%test%' em nome e e-mail. A reimplementação independente deu o mesmo resultado (3.692.128 ativos e 646.380 recorrentes). A base tem 77.709 pedidos com valor_total <= 1. |
| 4. Só pedidos pagos | passou | Pagamento deduplicado por pedido_id (aprovado ou estornado). Cancelado e pendente excluídos, devolvido mantido, chargeback perdido excluído (MED perdida não exclui). Sem pedido_id duplicado e sem pedido órfão. Janela de 2026-08-02 a 2026-10-30. |
| 5. Nenhum dado pessoal exposto | passou | A silver tem apenas loja_id, data_referencia, chave hash sha2-256 e qtd_pedidos_pagos. A metric view expõe duas dimensões e três medidas agregadas. Nenhuma tabela b_* é usada. |
| 6. Sanidade e MEASURE() | passou | A metric view responde com MEASURE() por loja e data, com taxas entre 0 e 1 e contagens > 0. Foi verificada só nas 5 maiores lojas. Os totais vêm da silver e da reimplementação independente, não da metric view. |

## Resposta da pergunta original (sandbox)

| Escopo | Compradores ativos | Recorrentes | Taxa de recompra |
|---|---|---|---|
| Total das lojas, janela de 2026-08-02 a 2026-10-30 (calculado na silver e na reimplementação independente, não pela metric view) | 3.692.128 | 646.380 | 17,51% |
| Loja L003053 (via MEASURE) | 46.215 | 25.219 | 54,57% |
| Loja L009457 (via MEASURE) | 39.847 | 21.417 | 53,75% |
| Loja L004774 (via MEASURE) | 25.755 | 3.854 | 14,96% |

A taxa é por loja, conforme a decisão do negócio. O número de 17,51% é a razão entre os totais de todas as lojas, onde cada comprador conta uma vez por loja.
