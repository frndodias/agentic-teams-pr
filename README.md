# agentic-teams-pr

Repositório onde o **time agêntico de engenharia de dados** abre Pull Requests.

- Cada PR adiciona um produto de dados em `produtos_dados/<nome>/`:
  - `silver.sql` — tabela(s) `s_*` (ex.: resolução de identidade)
  - `gold.yaml` — metric view `g_*`
  - `testes.sql` — testes de qualidade executados pelo Quality Agent
  - `relatorio_quality.md` — resultado dos testes por iteração
- Os PRs são abertos pelo bot `agentic-teams-bot[bot]` (GitHub App).
- A `main` é protegida: merge só com **1 aprovação humana**. Depois do merge, o job de deploy promove os objetos do
  sandbox (`agentic_teams_sandbox`) para `ecommerce`.

Código do gerador, pipeline, app e agentes: [frndodias/agentic-teams](https://github.com/frndodias/agentic-teams).
