# LTV médio de compradores por segmento de loja

**Pergunta do negócio:** Qual o LTV médio dos clientes por segmento de loja?

**Objetivo:** Mostrar quanto um comprador gera de receita realizada, em média, por segmento de loja.

**Grão:** Um comprador unificado por loja (loja_id + comprador_sk), com receita acumulada de pedidos pagos válidos.

## Regras
- Pedido pago: ao menos uma tentativa aprovada ou estornada em s_pagamentos.
- Pedido pago: status_pedido diferente de cancelado e pendente.
- Pedido pago: sem chargeback com status perdida. Pedidos devolvidos contam.
- Excluir testes: valor_total <= 1,00, nome ou e-mail com 'teste' ou 'test', ou flag_teste = true.
- Identidade por loja via comprador_sk (CPF normalizado, senão e-mail normalizado). Cadastros duplicados contam uma vez.
- Só entram compradores com ao menos um pedido pago válido.
- LTV médio do segmento = receita total ÷ compradores distintos do segmento. Não é média das médias das lojas.
- Horizonte: todo o histórico disponível (2024-10-31 a 2026-10-30). É LTV realizado, não projetado.
- Lojas ativas e inativas entram no cálculo, para evitar viés de sobrevivência. Expor status da loja como dimensão.
- Segmento vem de s_lojas (valor atual). Mudanças de segmento reclassificam o histórico.
- Antes de publicar, validar a construção de s_identidade_comprador e a sobreposição entre flag_teste e valor <= 1.
- LGPD: publicar só agregados e comprador_sk com hash. Não usar nem expor s_compradores.

## Decisões do negócio
- O LTV deve ser por loja ou consolidado na plataforma? Um cliente que compra em duas lojas conta como dois compradores ou como um? → **Por loja (o mesmo cliente conta uma vez em cada loja)**
- O que entra no LTV e em qual período? → **Receita (valor_total, com frete e desconto) de todo o histórico**

## Medidas
- **ltv_medio**: Receita total dos pedidos pagos válidos ÷ compradores unificados distintos.
- **receita_total**: Soma de valor_total dos pedidos pagos válidos.
- **compradores**: Contagem distinta de compradores unificados por loja (loja_id + comprador_sk).
- **pedidos_por_comprador**: Pedidos pagos válidos ÷ compradores.
