# Resumo Parcial do Estudo IACDM — Reconstrução iOS do ESJUDAC

> Consolidação **parcial**, feita em 2026-09-02 (P0036), a partir
> exclusivamente de registros persistidos (`research/`, `specs/`,
> estado do Versus, saídas reais de build/teste). Relatório técnico
> completo e rastreável: `PARTIAL_RESULTS_CURRENT.md`. Este é o resumo
> de 1–2 páginas.
>
> **Este NÃO é um estudo comparativo.** Caso único, sem grupo de
> controle, pesquisador = operador. Nenhuma conclusão de efetividade ou
> superioridade da metodologia IACDM é feita aqui — apenas o que
> aconteceu, com evidência.

## Onde o estudo está

Fase **6 de 7 (Tests)**, iteração 1, **aberta**. As Fases 0–5 cruzaram
seus gates de saída com 100% dos exit criteria atendidos em cada uma
(10/10, 8/8, 5/5, 4/4, 2/2, 4/4). A Fase 6 tem **1 de 3** critérios
atendidos: a suíte automatizada está verde (`tests_passing`), mas
**`manual_testing` e `edge_cases` seguem pendentes** — a passada
exploratória manual está em curso e encontrou um defeito ainda aberto.

## Números-chave (todos com fonte em `PARTIAL_RESULTS_TABLE.csv`)

- **Decisões registradas no Versus:** 75 · **Prompts com ID:** 35
  (P0001–P0035; um, P0014, sem arquivo de prompt persistido).
- **Arquitetura:** proposta inicial rejeitada (11 módulos) → V(1)
  aprovada (22 módulos) → V(2) corrente (23, +M-23 diagnostics),
  mudança estrutural V(1)→V(2) ≈ 4,3%.
- **Fase 2 (crítica adversarial):** 35 achados (8 críticos / 21
  importantes / 6 sugestões); todos os 8 críticos resolvidos na Fase 3.
- **Implementação (Fase 5):** 23/23 módulos implementados e compilando
  (`BUILD SUCCEEDED` real); **11 defeitos funcionais reais** encontrados
  — **todos com o código já compilando**, revelados só por execução
  humana (smoke test); todos corrigidos e reconfirmados PASS por
  execução real (D0073).
- **Testes automatizados (Fase 6):** suíte criada do zero → **78
  testes, 0 falhas**, execução verde testemunhada pelo engine do
  Versus. Evoluiu 67 → 74 → 78 ao longo de 3 ciclos de "rodada
  vermelha → correção → rodada verde".
- **Teste manual exploratório (Fase 6):** em curso, parcial. **Nenhum
  caso de uso marcado PASS manual ainda.** Um defeito real (inscrição
  em curso) está aberto após duas rodadas de reteste.

## O padrão mais relevante encontrado até aqui

Em **todos os 11 defeitos funcionais da Fase 5** e no defeito ainda
aberto da Fase 6, **o código compilava** (`BUILD SUCCEEDED`) e — no caso
da Fase 6 — a **suíte automatizada estava verde**. Nenhum desses
defeitos foi pego por compilador ou por teste automatizado; todos só
apareceram em **execução humana real** (smoke test com credenciais
reais, ou passada exploratória manual). Isso é uma *observação deste
caso específico*, consistente com o motivo declarado da metodologia
para exigir verificação humana em cada gate (S4) — não é, por si só,
prova de que a exigência é necessária ou suficiente em geral.

## Achados técnicos mais significativos (produto)

1. **mTLS:** um diagnóstico inicial (certificado com criptografia
   legada) foi **refutado por experimento controlado** — a causa real
   era o certificado ter senha vazia.
2. **HTTP/2 connection coalescing** entre hosts com o mesmo certificado
   wildcard causava HTTP 421 em dois fluxos — corrigido isolando a
   sessão por host.
3. Dois modelos de dados (Certificados, formulário de inscrição)
   exigiam campos que a API real não garante — o mesmo padrão existe na
   baseline Android (modelo desatualizado em relação ao contrato real).
4. Sessão do usuário não persistia entre reaberturas do app, e o
   `logout()` nunca era de fato chamado — ambos corrigidos e validados.
5. **Achado em aberto (Fase 6):** o formulário de inscrição em curso
   não carrega. Primeira causa (CPF nunca capturado pelo app) foi
   corrigida, mas o reteste manual revelou uma segunda falha
   persistente — diagnóstico aponta para o timeout do cliente iOS (30 s)
   muito abaixo do timeout equivalente da baseline Android (120 s) para
   o mesmo endpoint. Só a melhoria de observabilidade foi aplicada até
   agora; a correção causal ainda não.

## Achados metodológicos

- A verificação humana da metodologia **capturou** desvios reais antes
  de cruzar gates (uma síntese de Fase 0 com "vazamento" de decisões de
  solução foi rejeitada; uma decomposição de arquitetura foi devolvida
  por granularidade insuficiente).
- Um módulo de infraestrutura (M-23, diagnósticos) foi introduzido sem
  um passo de aprovação humana isolada dedicada, dentro de um lote maior
  de resoluções — a lacuna foi identificada pelo próprio agente e fechada
  com aprovação humana **tardia** (não retroativa).
- A ferramenta de teste do Versus não reconhecia o comando de teste do
  iOS nativamente; foi necessário um encaminhador (`npm test →
  xcodebuild test`) só para o mecanismo de verificação do engine
  registrar a execução real.
- **Limitações de mensuração já identificadas:** o estudo não
  instrumentou tempo de esforço por atividade (só timestamps por
  evento), então durações de "quanto tempo levou implementar/corrigir/
  testar" **não são calculáveis** com o que existe hoje. A contagem de
  builds e de critérios de validação automaticamente cobertos também
  tem lacunas de atualização, documentadas no relatório completo.

## O que falta para fechar esta fase

1. Diagnosticar e corrigir o defeito aberto de inscrição em curso.
2. Concluir a passada exploratória manual — todos os 12 casos de uso da
   Fase 0 + edge cases, com resultado PASS/FAIL registrado.
3. Reemitir a contagem de cobertura de critérios de validação (VAL) com
   os 78 testes atuais (hoje há uma contagem desatualizada de uma
   rodada anterior de 67 testes).
4. Reconciliar `research/DECISIONS.md` (hoje termina antes da Fase 6) e
   `research/PROMPT_LOG/` (um identificador sem arquivo) com o estado
   real do Versus.

*Relatório técnico completo, com toda métrica e todo achado
rastreados até sua fonte: `research/METRICS/PARTIAL_RESULTS_CURRENT.md`.*
