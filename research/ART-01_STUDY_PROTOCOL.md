# Protocolo do Estudo

## Título provisório

Aplicação da metodologia IACDM (via ferramenta Versus) na reconstrução nativa
iOS (Swift/SwiftUI) de uma aplicação Android existente: um estudo de caso
exploratório-descritivo com desenvolvimento assistido por IA.

## Objetivo da pesquisa

Documentar de forma reprodutível o processo de aplicação da metodologia
IACDM ao reconstruir, como aplicação nativa iOS, um aplicativo Android
(Kotlin/Jetpack Compose) já existente e em uso — o app ESJUDAC —,
registrando fases, gates, decisões, achados adversariais, correções
humanas e evidências de verificação (humana e automática) ao longo do
processo.

Este estudo **não** compara IACDM a "direct prompting" nem a qualquer
outra metodologia. Não há condição de controle, grupo de comparação,
nem replicação independente planejada nesta fase. Nenhuma conclusão de
superioridade metodológica deve ser extraída deste registro.

## Perguntas de pesquisa

Adequadas a um estudo de caso único, exploratório/descritivo:

- PQ1: Como a metodologia IACDM estrutura, em fases e gates observáveis,
  a reconstrução de uma aplicação Android existente como aplicativo iOS
  nativo?
- PQ2: Que tipos de decisões de tradução de plataforma (Android → iOS)
  emergem durante o processo, e como são registradas e verificadas?
- PQ3: Que papel desempenham os Verification Agents automáticos
  (compilador Swift, linters, XCTest, execução real do app) e o
  Verification Agent humano na aceitação ou rejeição de artefatos
  gerados pelo Generative Agent (GA)?
- PQ4: Quais achados adversariais (findings), correções e retrabalhos
  ocorrem ao longo das fases, e com que severidade?
- PQ5: Quais desvios, anomalias ou limitações da metodologia são
  observáveis neste caso específico?

## Unidade de análise

Um único caso: o processo de desenvolvimento (fases IACDM, gates,
decisões, artefatos, interações GA/VA) conduzido dentro deste workspace,
do início do registro de pesquisa até a conclusão (ou interrupção) do
estudo.

## Contexto da reconstrução Android → iOS

- **Implementação de referência (baseline):** aplicativo Android nativo
  "ESJUDAC", localizado em `./ESJUDAC android referencia para criar ios/`,
  escrito em Kotlin com Jetpack Compose (MVVM), já funcional e em uso.
- **Produto-alvo:** aplicação nativa iOS em Swift/SwiftUI, a ser
  desenvolvida em `./aplicativo ios/` (vazio no início do estudo).
- **Metodologia de desenvolvimento aplicada:** IACDM, operacionalizada
  neste workspace pela ferramenta Versus (`.versus/`, servidor MCP
  `versus-claude`, diretório `specs/`), que estrutura o trabalho em
  fases numeradas (0 a 7), critérios de saída (exit criteria),
  safeguards e lentes de verificação. O funcionamento interno do Versus
  não é modificado, contornado nem duplicado por este estudo.

## Papéis

- **GA (Generative Agent):** Claude Code, responsável por propor
  artefatos (specs, decisões, arquitetura, código Swift/iOS quando a
  metodologia permitir).
- **VA-human (Verification Agent humano):** o pesquisador/operador,
  responsável por aprovar, corrigir ou rejeitar o que o GA propõe, e
  por decisões que a metodologia reserva a julgamento humano.
- **VA-automatic (Verification Agents automáticos/externos):** quando a
  implementação iOS começar — Xcode, compilador Swift, linters,
  XCTest, testes automatizados e execução real da aplicação. Antes da
  implementação, não há VA-automatic ativo neste estudo.

## Regra de precedência de implementação

Nenhum código Swift/iOS de produção poderá ser implementado antes que a
metodologia IACDM, através do estado do Versus, permita explicitamente
essa fase (implementação ocorre nominalmente a partir da Fase 5, sujeita
aos gates das fases anteriores). Este registro de pesquisa não altera,
antecipa nem contorna essa regra.

## Ameaças à validade conhecidas no início do estudo

- **Caso único, sem grupo de controle:** impossibilita qualquer
  inferência causal ou comparativa sobre a eficácia da IACDM frente a
  outras abordagens.
- **Pesquisador e operador são a mesma pessoa** (dupla função
  VA-human/autor do estudo): risco de viés de confirmação na avaliação
  de gates e na redação de achados.
- **Baseline única e específica de domínio:** o app ESJUDAC atende a um
  domínio institucional específico (ESJUD-AC/TJAC); generalização para
  outras reconstruções Android→iOS é limitada.
- **Dependência de ferramenta proprietária/versionada:** o comportamento
  do GA (Claude Code, modelo ativo) e do Versus pode variar entre
  versões e sessões, afetando a reprodutibilidade estrita do processo
  (embora não dos artefatos e registros).
- **Ambiente de build iOS incompleto no início:** no início do registro,
  não há Xcode instalado (apenas Command Line Tools), o que impede
  VA-automatic reais até que o ambiente seja completado — ver
  `ENVIRONMENT.md`.
- **Registro dependente de disciplina de processo:** a integridade do
  estudo depende da aderência contínua às regras de integridade deste
  protocolo (não fabricar métricas, gates, testes, achados ou
  timestamps).

## Timestamp de início do estudo

2026-08-26T21:52:28Z (UTC), conforme relógio do sistema no momento da
inicialização deste registro de pesquisa (ver `RESEARCH_LOG.md`,
entrada P0001).
