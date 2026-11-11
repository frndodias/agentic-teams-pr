# LTV médio de clientes por segmento de loja

**Pergunta do negócio:** Qual o LTV médio dos clientes por segmento de loja?

**Objetivo:** Medir o valor médio acumulado por comprador em cada segmento de loja, com base em pedidos pagos válidos.

**Grão:** Um comprador unificado (comprador_hash) por loja; a metric view agrega por segmento de loja.

## Regras
- Pedido pago: pagamento aprovado ou estornado, status diferente de cancelado e pendente, e sem chargeback perdido.
- Pedidos devolvidos continuam contando.
- Excluir pedidos de teste: valor_total <= 1,00 ou nome/e-mail com 'teste' ou 'test'.
- Valor do pedido = valor_total (produtos - desconto + frete), alinhado ao GMV Total.
- Identidade por loja: CPF só dígitos; sem CPF, e-mail em minúsculas e sem espaços.
- O comprador unificado conta uma vez por loja. Métricas de comprador são por loja, salvo pedido explícito de visão consolidada.
- Segmento vem de s_lojas (segmento atual, sem histórico de mudança).
- Histórico completo vem de s_pedidos, refazendo as regras de pedido pago e teste. s_pedidos_pagos_comprador cobre só jul a set/2026 e não serve.
- Verificar extensão do histórico e cobertura de comprador_hash em pedidos antigos antes de construir.
- LGPD: usar só comprador_hash e publicar apenas agregados, sem CPF, e-mail, nome ou telefone.
- Objetos criados apenas em fc_catalog.agentic_teams_sandbox.

## Decisões do negócio
- Como definir o LTV e o horizonte? Isso muda o número. → **Receita bruta (valor_total) acumulada em todo o histórico**
- Qual o escopo do cliente e das lojas? Isso muda o número. → **Por loja (comprador conta uma vez por loja), incluindo lojas inativas**

## Medidas
- **ltv_medio**: Média, entre compradores, da soma de valor_total dos pedidos pagos válidos por comprador_hash na loja (receita bruta).
- **clientes**: Contagem distinta de comprador_hash por loja com ao menos um pedido pago válido.
- **receita_total**: Soma de valor_total dos pedidos pagos válidos.
