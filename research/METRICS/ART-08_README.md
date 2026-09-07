# Métricas

Este diretório é reservado para métricas objetivamente coletadas ao
longo do estudo (por exemplo: contagem de iterações por fase, número de
achados adversariais por severidade e por lente, resultados reais de
build/lint/teste, tempo entre gates, taxa de correção humana sobre
propostas do GA).

No momento da inicialização deste registro (P0001), **nenhuma métrica
foi coletada ainda**, porque a Fase 0 do IACDM não foi iniciada e
nenhuma atividade de desenvolvimento ocorreu. Nenhum arquivo de dados
deve ser criado aqui com valores fictícios, projetados ou estimados.

Regras para uso futuro deste diretório:

- Cada arquivo de métrica deve indicar a fonte do dado (ferramenta MCP,
  saída de compilador/linter/teste, ou contagem manual do VA-human) e o
  timestamp real da coleta.
- Nenhum valor deve ser preenchido antes de o evento correspondente
  ocorrer de fato.
- Métricas agregadas (ex.: totais por fase) devem ser recalculadas a
  partir de `RESEARCH_LOG.md` e `GATES.md`, nunca declaradas
  independentemente deles.
