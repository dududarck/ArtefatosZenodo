# Consolidação PARCIAL dos Resultados — Estudo IACDM / Reconstrução iOS do ESJUDAC

> **Natureza:** consolidação **parcial**, auditável e quantitativa, do
> estado do estudo até **2026-09-02T14:42:49Z**, produzida em P0036.
> **Fonte:** exclusivamente evidências persistidas (`research/*`,
> `specs/*`, estado do Versus via ferramentas MCP, saídas reais de
> build/teste, registros de smoke test e validações do VA-human).
> Nenhuma métrica foi estimada, completada por memória ou fabricada.
>
> **Restrições declaradas (STUDY_PROTOCOL.md):** estudo de caso único,
> exploratório-descritivo, **sem grupo de controle e sem condição de
> comparação**. Este documento **não** declara efetividade nem
> superioridade da metodologia IACDM. Distingue: *aplicabilidade* (o que
> a metodologia permitiu fazer), *observação do caso* (o que aconteceu
> neste caso específico) e *evidência causal* (que **não existe** aqui,
> por desenho).
>
> **Arquivos irmãos:**
> `PARTIAL_RESULTS_SUMMARY.md` (resumo 1–2 páginas),
> `PARTIAL_RESULTS_TABLE.csv` (uma linha por métrica, com fonte),
> `FINDINGS_CURRENT.csv` (uma linha por achado).
> Toda métrica numérica abaixo tem um `M###` correspondente no CSV com a
> fonte rastreável; todo achado tem um `F-###` no CSV de achados.

---

## 0. Identificação do estudo e do ambiente

| Item | Valor | Fonte |
|---|---|---|
| Título provisório | Aplicação da metodologia IACDM (via Versus) na reconstrução nativa iOS de um app Android existente — estudo de caso exploratório-descritivo com desenvolvimento assistido por IA | `research/STUDY_PROTOCOL.md` |
| Baseline (referência) | App Android nativo "ESJUDAC" (Kotlin/Jetpack Compose, MVVM), funcional e em uso | `research/STUDY_PROTOCOL.md`, `research/BASELINE.md`, `research/BASELINE_MANIFEST.md` |
| Produto-alvo | App nativo iOS (Swift/SwiftUI), iOS 17+ | D0010; `specs/technical/architecture.md` |
| Início do registro | 2026-08-26T21:52:28Z | `research/STUDY_PROTOCOL.md`; `RESEARCH_LOG.md` P0001 |
| Modelo do GA | "Sonnet 5" (`claude-sonnet-5`) — **autodeclarado pelo harness**, não medido por fonte externa | `research/ENVIRONMENT.md` |
| Versus | server.js 0.16.4 (string lida, sem execução) | `research/ENVIRONMENT.md` |
| Ambiente de build (início) | Apenas Command Line Tools — **sem Xcode** | `research/ENVIRONMENT.md` |
| Ambiente de build (após 2026-08-29T21:40:49Z) | Xcode 26.6 (Build 17F113); Swift 6.3.3; SDK iOS 26.5 (device + simulador) | `research/ENVIRONMENT.md` atualização P0007; D0030 |

---

## 1. STATUS METODOLÓGICO

### 1.1 Fase atual e fases concluídas

- **Fase atual:** 6 (Tests), **iteração 1** [M001, M002] — `get_phase_state`.
- **Fases com gate de saída cruzado (concluídas):** 0, 1, 2, 3, 4, 5 [M003] —
  `GATES.md`: G0-03 (2026-08-26T23:36:39Z), G1-02 (2026-08-29T16:39:59Z),
  G2-02 (2026-08-29T16:54:06Z), G3-02 (2026-08-29T16:54:06Z),
  G4-04 (2026-08-29T16:56:14Z), "Fase 5 → Fase 6" (2026-08-31T17:11:05Z).
- **Fase 7 (Post-Review):** não iniciada.

### 1.2 Gates aprovados / reprovados

| Gate | Resultado | Tipo de evidência | Observação |
|---|---|---|---|
| G0 (score + 10 exit criteria + advance_phase 1) | Aprovado | Automática (MCP) + julgamento do GA nas notas | Precedido do achado F-PROC-01 (Teach-Back rejeitado), corrigido **antes** do gate |
| G1 (8 exit criteria + advance_phase 2) | Aprovado | Automática (MCP) | Precedido de F-PROC-02 (11→22 módulos) |
| G2 (5 exit criteria + advance_phase 3) | Aprovado | Automática (MCP) | — |
| G3 (4 exit criteria + advance_phase 4) | Aprovado | Automática (MCP) | Registrado no mesmo timestamp de G2 |
| G4 (relatório de convergência + 2 exit criteria + advance_phase 5) | Aprovado **após correção** | Automática (MCP) | **1ª tentativa de `advance_phase(5)` FALHOU** (`missingCriteria`: exit criteria não marcados apesar de verificados em chat) — F-PROC-04 |
| Saída Fase 5 → Fase 6 (4/4 exit criteria + advance_phase 6) | Aprovado | Automática (MCP) | — |
| Fase 6 — critério `tests_passing` | Atendido | Hook `test-outcome.js` (engine testemunhou run verde) | Ver §4 |

- **Gates de fase reprovados:** **0** [M013]. A única "reprovação" foi a
  1ª tentativa de `advance_phase(5)` por critérios não marcados
  (corrigida em segundos).

### 1.3 Score(s) por fase

- **Fase 0: 96/100** [M004] — `GATES.md` G0-01 / `get_phase_state` `phase0Score`.
  Breakdown: clarezaProblema 10, casosDeUso 14, vocabulario 10,
  ambiguidades 13, foraDeEscopo 10, criteriosSucesso 9, premissas 10,
  documentacao 5, usuarioConfirmou 10, iaConfiante 5.
- **Fases 1–6: sem score numérico** [M005] — essas fases usam apenas
  *exit criteria* booleanos no Versus; não há campo de pontuação.

### 1.4 Critérios de saída atendidos

| Fase | Atendidos | Fonte | Nota |
|---|---|---|---|
| 0 | **10/10** [M006] | `get_exit_criteria(0)` | `ambiguities_zero` marcado "aceito" (5 ambiguidades técnicas menores documentadas, não escondidas) |
| 1 | **8/8** [M007] | `get_exit_criteria(1)` | — |
| 2 | **5/5** [M008] | `get_exit_criteria(2)` | — |
| 3 | **4/4** [M009] | `get_exit_criteria(3)` | — |
| 4 | **2/2** [M010] | `get_exit_criteria(4)` | `check_all_safeguards` retornou apenas S2/S4 como aplicáveis |
| 5 | **4/4** [M011] | `get_exit_criteria(5)` | `ui_runnable` atendido via smoke tests P0021–P0031 (D0073); push FCM tratado à parte (D0051) |
| 6 | **1/3** [M012] | `get_exit_criteria(6)` | `tests_passing` met=true; **`manual_testing` e `edge_cases` met=false** |

### 1.5 Ciclos / reiterações por fase

- **Todas as fases em iteração 1** [M002] — `get_phase_state`
  `currentIteration = 1`.
- **Loop 2↔3 executado 1 vez** [M014], sem retorno à Fase 2 — a mudança
  estrutural (4,3%) e os críticos remanescentes (0) ficaram abaixo do
  limiar de nova iteração; decisão aceita pelo VA-human (D0028;
  `GATES.md` linha 113–116).

### 1.6 Mudança estrutural entre versões de arquitetura

- **V(1) → V(2): ~4,3%** [M018] — **1 módulo adicionado (M-23
  diagnostics)**, 0 removidos, 0 fronteiras/dependências redesenhadas
  (`architecture.md`, "Mudança estrutural V(1)→V(2)"; D0027). Os demais
  33 dos 35 achados foram resolvidos por refinamento de interface dentro
  de módulos existentes.

### 1.7 Número total de módulos por versão

| Versão | Módulos | Fonte | Observação |
|---|---|---|---|
| Proposta inicial (chat, **rejeitada**) | **11** [M015] | D0022; `GATES.md` nota G1 | Nunca escrita em arquivo — só exibida em chat |
| **V(1)** aprovada | **22** [M016] | D0023; `architecture.md` tabela V(1) | 12 domínio/infra + 10 apresentação |
| **V(2)** corrente | **23** [M017] | D0027; `architecture.md` tabela V(2) | V(1) + M-23 |

### 1.8 Achados críticos / importantes / sugestões (Fase 2) e sua resolução (Fase 3)

| Métrica | Valor | Fonte |
|---|---|---|
| Achados adversariais totais (Fase 2) | **35** [M020] | D0026; `get_exit_criteria(2)` `coverage_matrix`; `specs/design/coverage-matrix.md` |
| 🔴 Críticos | **8** [M021] | AS-02, AR-03, SE-01, SE-02, RS-01, RS-03, OB-01, LG-01 — `specs/validation/critical-coverage.md` |
| 🟡 Importantes | **21** [M022] | D0026; `get_exit_criteria(3)` |
| 🟢 Sugestões | **6** [M023] | D0026; D0027 |
| 🔴 resolvidos (Fase 3) | **8/8** [M024] | `get_exit_criteria(3)` `criticals_addressed` |
| 🟡 resolvidos por refinamento de interface | **13** [M025] | D0027; `get_exit_criteria(3)` `important_decided` |
| 🟡 aceitos com justificativa | **8** [M026] | D0027 (13+8 = 21) |
| 🟢 adiados para v2.0 (fora deste ciclo) | **6** [M027] | D0027 |

Concentração (D0026): `cert-ext` concentrou achados em **6 lentes**
distintas; `networking` e `push-transport` em **5 lentes** cada; nenhuma
lente encontrou achados em todos os 22 módulos (sem falha sistêmica
generalizada).

---

## 2. INTERAÇÕES E DECISÕES

### 2.1 Prompts registrados

- **35 identificadores de prompt atribuídos** (P0001–P0035) + **P0036**
  (este relatório) [M028].
- **34 arquivos** em `research/PROMPT_LOG/` antes de P0036 [M029].
- **Anomalia de rastreabilidade (F-PROC-07):** `P0014.md` **está
  ausente** — a entrada P0014 existe em `RESEARCH_LOG.md` (linha 1649,
  "Análise da alternativa 'XCFrameworks manuais' para Firebase") mas não
  há arquivo de prompt correspondente.

### 2.2 Decisões registradas

- **No Versus: 75 decisões** [M030] — `get_decisions` (última:
  2026-08-31T22:50:22Z / P0035).
- **Em `research/DECISIONS.md`: 73 entradas** (D0001–D0073) [M031].
  - **`D0049` está ausente da tabela** (é referenciada em D0050 —
    "plano já aprovado em D0049/P0015").
  - **`DECISIONS.md` não espelha as decisões da Fase 6** (D0074+):
    para em D0073/P0031. As 9 decisões da Fase 6 estão apenas no Versus
    e no `RESEARCH_LOG.md`. (F-PROC-07)

### 2.3 Decisões por fase (Versus) [M032–M038]

| Fase | Decisões |
|---|---|
| 0 | 14 |
| 1 | 4 |
| 2 | 1 |
| 3 | 1 |
| 4 | 1 |
| 5 | **45** |
| 6 | 9 |
| **Total** | **75** |

### 2.4 Decisões por categoria (Versus) [M039–M048]

| Categoria | Total | Onde se concentra |
|---|---|---|
| `diagnosis` | **26** | 25 na Fase 5, 1 na Fase 6 |
| `architecture` | 14 | Fase 5 (9), Fases 0–3 (5) |
| `testing` | 9 | Fase 6 (7), Fase 5 (2) |
| `process` | 8 | Fase 5 (6), Fases 0/4 (2) |
| `scope` | 5 | Fase 5 (3), Fase 0 (2) |
| `requirement` | 4 | Fase 0 |
| `constraint` | 4 | Fase 0 |
| `technology` | 2 | Fases 0/1 |
| `pattern` | 2 | Fase 1 |
| `spec-coverage` | 1 | Fase 6 |

### 2.5 Decisões por (fase × categoria) — Versus

- **P0:** architecture 2, constraint 4, process 1, requirement 4, scope 2, technology 1
- **P1:** architecture 1, pattern 2, technology 1
- **P2:** architecture 1 · **P3:** architecture 1 · **P4:** process 1
- **P5:** architecture 9, **diagnosis 25**, process 6, scope 3, testing 2
- **P6:** diagnosis 1, spec-coverage 1, testing 7

### 2.6 Intervenções do VA-human

Não existe um contador único de "intervenções do VA-human". Proxies
rastreáveis:

- **31 linhas** de `DECISIONS.md` com autor "VA-human" na coluna de autor
  [M049].
- **17 menções** a `AskUserQuestion` em `RESEARCH_LOG.md` [M050] (perguntas
  estruturadas ao humano).
- **8 rodadas de smoke test P0** executadas pelo próprio VA-human com
  credenciais reais [M080] (P0017, P0018, P0019, P0020, P0021, P0023,
  P0025, P0031) + validação manual parcial em P0030.
- **1 passada exploratória manual da Fase 6** em curso (parcial) [M081].
- Pausas/decisões de processo explícitas do VA-human: D0029 (pausa
  ambiente), D0032 (pausa checkpoint 7/23), D0047 (pausa Firebase
  manual), P0027 (pedido de refinamento visual), P0032 (3 decisões de
  plano de teste), P0035 (aprovação parcial).

### 2.7 Rejeições / ajustes explícitos de proposta do GA pelo VA-human

**3 eventos** com contagem conservadora [M051]:

1. **D0020 / P0004** — Teach-Back da Iteração 1 da Fase 0 **rejeitado**
   ("Quase — pequenos ajustes"), por *phase-boundary leakage*.
2. **D0022 / P0005** — decomposição inicial de **11 módulos rejeitada**
   por granularidade insuficiente.
3. **P0035** — das 4 partes propostas para corrigir o UC-3 (A/B/C/D), o
   VA-human aprovou **somente a mudança A** (observabilidade),
   adiando B/C/D.

*Não contabilizadas aqui:* as ~11–13 **refutações empíricas** em que a
execução humana (smoke test) mostrou que um fluxo que o GA havia
implementado/considerado pronto **falhava** (ver §3 e §8).

### 2.8 Aprovações post-hoc

**1** [M052]: **M-23** (diagnostics) — introduzido na Fase 3 dentro do
lote de 35 resoluções, **sem aprovação humana isolada dedicada**;
aprovado isoladamente apenas na Fase 5 (D0033 / P0009). O registro
mantém M-23 como introduzido na Fase 3 (não reescreve o histórico).

### 2.9 Anomalias / desvios de processo registrados

**≥10 itens** [M053], enumerados em `FINDINGS_CURRENT.csv` (F-PROC-01 a
F-PROC-07, F-META-03, F-META-06 a F-META-08). Principais:

1. Phase-boundary leakage no Teach-Back da Fase 0 (F-PROC-01).
2. Rejeição da granularidade 11→22 módulos (F-PROC-02).
3. M-23 sem aprovação isolada dedicada → post-hoc (F-PROC-03).
4. `advance_phase(5)` 1ª tentativa falhou por critérios não marcados (F-PROC-04).
5. Fase 5 pausada antes de qualquer módulo por falta de Xcode (F-PROC-05).
6. Hook `test-outcome.js` não reconhece `xcodebuild test` → alias `npm test` (F-PROC-06).
7. `P0014.md` ausente; `D0049` ausente de `DECISIONS.md`; `DECISIONS.md` não atualizada para a Fase 6 (F-PROC-07).
8. `check_all_safeguards` mostra só safeguards "aplicáveis à fase" — comportamento da ferramenta, registrado para não confundir com omissão (F-META-03).
9. Métricas de esforço/tempo não instrumentadas (F-META-06).
10. Contagem total de builds/execuções não auditável; contador de VAL cobertos desatualizado (F-META-07, F-META-08).

Nota adicional: o prompt de P0005 tem timestamp de recebimento em
2026-08-26 mas foi executado/registrado em 2026-08-29 — registrado
honestamente, sem retroação.

---

## 3. IMPLEMENTAÇÃO

### 3.1 Módulos

- **Implementados: 23/23** (M-01…M-22 + M-23) [M054] —
  `get_exit_criteria(5)` `all_modules`; D0042.
- **Compilados: 23/23** — Package completo `BUILD SUCCEEDED` real
  + App target `ESJUDApp.xcodeproj` `BUILD SUCCEEDED` [M055] —
  D0040/D0042; `RESEARCH_LOG.md`.

### 3.2 Builds

- **`BUILD SUCCEEDED` mencionado 70×** em `RESEARCH_LOG.md` [M056] —
  **não** é contagem de builds distintos (muitas menções referenciam o
  mesmo build; frases como "Package + App" contam 2).
- **`BUILD FAILED` real: 1 evento** [M057] — M-07 cert-ext,
  `CertExtRepository.swift:168`: *"method cannot be declared public
  because its result uses an internal type"* (`PessoaExtData` sem
  `public`). Corrigido → `BUILD SUCCEEDED` (F-PROD-16).
- **Crashes reproduzíveis da ferramenta: 3** [M058] — `IDESwiftPackageCore`,
  `NSInvalidArgumentException`, ao integrar o Firebase SDK via SPM
  (D0045/D0046 — F-PROD-02).
- **Contagem total exata de invocações de build: NÃO auditável** [M058b].
  Um checkpoint (`RESEARCH_LOG.md` ~linha 1012) enumera `xcodebuild
  build` ×7 (um por módulo de domínio) + `xcodebuild -list` ×3 +
  `xcodebuild -scheme ESJUDApp build` ×2 — mas não há total consolidado.

### 3.3 Falhas reais e correções

| Métrica | Valor | Fonte |
|---|---|---|
| Defeitos funcionais reais encontrados na Fase 5 | **11** [M059] | D0052, D0053, D0054/D0055, D0057, D0061 (×3), D0065 (×2), D0053 (nome), D0070 (×2) |
| Correções aplicadas na Fase 5 | **12** [M060] | D0052, D0053, D0055, D0058, D0062, D0063, D0064, D0066, D0067, D0068 (visual), D0069, D0070 |
| Correções aplicadas na Fase 6 | **3** [M061] | P0032 (AAABootstrap + 2 erros de compilação de teste); P0033 (captura de CPF + `extractMessage`); P0035 (observabilidade) |
| Regressões de **produto** confirmadas | **0** [M062] | D0073 (todos os fluxos P0 PASS reais após D0057–D0072) |

Os 11 defeitos funcionais da Fase 5 (F-PROD-01 a F-PROD-14): Firebase
crash no lançamento; delegate mTLS insuficiente; PKCS12 senha vazia;
HTTP/2 connection coalescing; PDF de Certidão descartado; wiring ausente
de `listar()` no Certificado Externo; fallback ausente no AVA/Moodle;
campo `pessoa` inexistente no modelo de Certificados; CPF sem máscara no
Certificado Externo; nome errado na Home; sessão não persiste + `logout()`
nunca chamado. **Todos com o código compilando (`BUILD SUCCEEDED`)** — ver §8.

Além disso: **1 falha encontrada por autorrevisão do GA antes de
compilar** [M084] — placeholder de token do Moodle + CPFs hardcoded
(D0041 / F-PROD-15); e **1 achado de micro-check S7** — timeout de 15 s
uniforme em M-04 (F-PROD-17).

### 3.4 Mudanças arquiteturais após o gate de convergência (G4)

- **Módulos adicionados/removidos após G4: 0** [M063]. O grafo de 23
  módulos V(2) permanece inalterado.
- **M-23 foi adicionado na Fase 3** (antes de G4), com aprovação isolada
  apenas *post-hoc* (F-PROC-03).
- Alterações pós-G4, todas registradas, todas **dentro de módulos
  existentes**:
  - Integração do Firebase via **XCFrameworks no app target** (não no
    Package); M-11 `push-transport` mantido agnóstico de SDK (D0050).
  - Ampliações de superfície de API pública: `AuthRepository.currentSession()`/
    `logout()` (D0070); visibilidade de `CertExtViewModel.nomePessoa`
    (D0068); captura de CPF em `EnrollmentViewModel` (P0033); seam de
    teste `sessionConfiguration` em M-01 (P0032); `transportSummary` /
    mensagens de erro diferenciadas em M-01/M-04 (P0035).
  - `Assets.xcassets` no app target — "infraestrutura padrão de projeto
    Xcode, não mudança arquitetural" (D0068).

---

## 4. TESTES

### 4.1 Evolução da suíte automatizada por rodada

| Momento | Testes | Falhas na 1ª rodada | Resultado após correção | Fonte |
|---|---|---|---|---|
| Antes da Fase 6 | **0** [M064] | — | — | `STUDY_PROTOCOL.md`; `RESEARCH_LOG.md` |
| P0032 | **67** [M065] | **8** (todas `AdminFeedTests`) | 67/67 verde, **testemunhado pelo engine** 2026-08-31T17:49:41Z | `RESEARCH_LOG.md` P0032; Versus decisão #69/#70; `get_exit_criteria(6)` |
| Após P0033 | **74** [M066] | **2** (testes que exigiam atualização após mudança de comportamento) | 74/74 verde | `RESEARCH_LOG.md` "P0033 (cont.)" |
| Após P0035 (**atual**) | **78** [M067] | **1** (idem) | **78/78 verde**, `** TEST SUCCEEDED **` | `RESEARCH_LOG.md` P0035; saída `xcodebuild test` |

- **Total atual: 78 testes, 0 falhas** [M067, M068].
- **Reruns documentados na Fase 6: 3 ciclos** [M069] — cada um "1ª rodada
  vermelha → correção → 2ª rodada verde" (P0032, P0033, P0035).

### 4.2 PASS/FAIL por execução registrada

| Execução | Executados | Falhas |
|---|---|---|
| P0032 rodada 1 | 66 | 8 (`AdminFeedTests`) |
| P0032 rodada 2 | 67 | 0 (engine-witnessed) |
| P0033 rodada 1 | — | 2 (`CoursesTests.test_fetchForm_400_...`, `EnrollmentViewModelTests.test_loadForm_backend_reject_...`) |
| P0033 rodada 2 | 74 | 0 |
| P0035 rodada 1 | — | 1 (`EnrollmentViewModelTests.test_loadForm_backend_reject_does_not_persist`) |
| P0035 rodada 2 | 78 | 0 |

### 4.3 Testes positivos / negativos

- Snapshot de **67 testes** (decisão `spec-coverage`, 2026-08-31T17:50):
  **positivos ≈ 40, negativos ≈ 27** (razão ≈ 1:1,5, acima do mínimo
  1:2 do protocolo) [M070, M071]. **Não recalculado** para 74/78 —
  lacuna de mensuração (F-META-08).

### 4.4 Fixtures / datasets

- **16 arquivos JSON** em `specs/datasets/` (+ `README.md`) [M072].
- **4 marcados REAL** (corpo de resposta real de produção capturado em
  D0065–D0067 e P0033): `certificados-producao-real.json`,
  `cert-ext-obter-pessoa-nao-encontrada.json`,
  `cert-ext-obter-pessoa-encontrada.json`, `inscricao-formulario-400.json`
  [M073].
- **12 sintéticos** (fiéis ao contrato de `integracao-apis.md`) [M074].

### 4.5 Critérios de validação (VAL)

- **43 critérios VAL definidos** [M075] em `specs/validation/criterios-de-validacao.md`
  (VAL-1…VAL-43; VAL-41/42/43 acrescentados em P0033/P0035).
- **Cobertos automaticamente: 34/40** [M077] — **snapshot** da decisão
  `spec-coverage` (67 testes). **Contradição aparente documentada
  (F-META-08):** o total é 43, mas a cobertura registrada é "34/40";
  VAL-41/42/43 têm testes (P0033/P0035) mas nenhuma contagem formal
  atualizada foi emitida.
- **Marcados como manuais / GAP: 5** [M078] — VAL-4 (login→fechar→reabrir
  com Keychain real), VAL-5 (metade Keychain do logout), VAL-35
  (`shouldNotify`, `private`), VAL-36 (5 variações de texto do lembrete,
  `private`), VAL-40 (`kSecAttrAccessible`, não relido pela API de
  teste) — `specs/validation/criterios-de-validacao.md` §"Fora de
  cobertura".
- **8 críticos com linha em `critical-coverage.md`** [M079] — SE-01 e
  SE-02/A-11 sem teste de regressão, com motivo declarado.

### 4.6 Gaps de cobertura declarados

VAL-35/VAL-36 (métodos `private`), VAL-40 (atributo de Keychain),
handshake mTLS real, push FCM real (D0051), renderização visual SwiftUI,
abertura/visualização de PDF real. Todos endereçados (ou a endereçar)
por teste manual — `criterios-de-validacao.md` §"Fora de cobertura".

### 4.7 Falhas por método de descoberta

| Descoberta por | Nº | Fonte |
|---|---|---|
| Só teste manual / execução humana | **13** [M082] | 8 rodadas de smoke P0 (F-PROD-01/05/06/07/08/09/10/11/12/13/14) + UC-3 P0033 (F-PROD-19) + UC-3 persistente P0034 (F-PROD-20) |
| Só teste automatizado | **4** [M083] | `AdminFeedTests` 8 falhas = 1 causa (F-PROD-18) + 2 atualizações de expectativa em P0033 (F-PROD-21) + 1 em P0035 |
| Autorrevisão do GA antes de compilar | **1** [M084] | D0041 (F-PROD-15) |

### 4.8 Smoke tests e passadas exploratórias

- **Rodadas de smoke test P0 (execução humana): 8** [M080] — P0017,
  P0018, P0019, P0020, P0021, P0023, P0025, P0031 (+ validação manual
  parcial em P0030).
- **Passadas exploratórias manuais dedicadas (Fase 6): 1, EM CURSO e
  PARCIAL** [M081] — nenhum caso de uso (UC-1…UC-12) marcado PASS
  manual; **2 relatos de FAIL no UC-3** (P0033 e P0034).

---

## 5. ACHADOS TÉCNICOS

Tabela completa (todos os campos, todos os achados) em
`FINDINGS_CURRENT.csv`. Resumo:

| ID | Fase | Achado (curto) | Evidência | Causa raiz | Correção | Validação | Status |
|---|---|---|---|---|---|---|---|
| F-PROC-01 | 0 | Phase-boundary leakage no Teach-Back | P0004; D0020; GATES nota G0 | Síntese do GA antecipou soluções | VA-human rejeitou; síntese revisada; D0021 | Síntese revisada aprovada; score refere-se a ela | resolvido |
| F-PROC-02 | 1 | Granularização 11→22 módulos | D0022/D0023; P0005 | Decomposição do GA não separava responsabilidades | VA-human pediu ajuste; GA reapresentou 22 | Versão de 22 aprovada e persistida | resolvido |
| F-PROC-03 | 3 | M-23 sem aprovação isolada dedicada | P0008; D0027/D0033 | Lote de 35 resoluções sem passo de aprovação por módulo novo | Revisão isolada de 11 pontos na Fase 5 | Aprovação **post-hoc** (D0033) | resolvido (tardio) |
| F-PROC-04 | 4 | `advance_phase(5)` falhou (missingCriteria) | GATES G4-04 | Exit criteria verificados em chat, não marcados via MCP | `mark_exit_criterion` + retry | `advance_phase(5)` sucesso | resolvido |
| F-PROC-05 | 5 | Fase 5 pausada — sem Xcode | GATES; D0029; ENVIRONMENT.md | Pré-requisito de ambiente não satisfeito | VA-human pausou; instalou Xcode | Ambiente reverificado (D0030) | resolvido |
| F-PROC-06 | 6 | Hook não reconhece `xcodebuild test` | P0032; `.versus/test-outcome.js` | `isTestCommand()` cobre npm/pytest/cargo/go, não xcodebuild | `package.json` alias `npm test` (runner não modificado) | `lastTestOutcome` pass registrado | resolvido (alias) |
| F-PROC-07 | 6 | Lacunas de rastreabilidade nos registros | `ls PROMPT_LOG`; `DECISIONS.md` | Disciplina de espelhamento não mantida | Documentado neste relatório | — | **aberto** |
| F-PROD-01 | 5 | `FirebaseApp.configure()` crasha o app todo | P0017; D0052 | Sem checagem prévia de config válida | Degradação graciosa | Rebuild OK; PID sem crash; smoke tests | resolvido |
| F-PROD-02 | 5 | Firebase via SPM crasha Xcode (IDESwiftPackageCore) | P0011; D0045/D0046 | Bug do Xcode 26.6 com grafo transitivo do Firebase | Via SPM abandonada; reversão total | BUILD SUCCEEDED pós-reversão | resolvido (contornado) |
| F-PROD-03 | 5 | Firebase via XCFrameworks manuais | P0015/P0016; D0050 | Necessidade de manter push no escopo evitando o code path do SPM | 8 xcframeworks + bridge; `@preconcurrency` | `xcodebuild build` → BUILD SUCCEEDED | resolvido (compila/linka) |
| F-PROD-04 | 5 | `GoogleService-Info.plist` real ausente | D0051; `get_exit_criteria(5)` | Dependência externa (console Firebase do TJAC) | Registrado como dívida técnica; critério mantido PENDENTE | Push real **NÃO validado** | **aberto** |
| F-PROD-05 | 5 | Correção mTLS (task-delegate) insuficiente | D0053/D0054 | Delegate de sessão sozinho não respondia ao desafio | Mantida (robustez), diagnóstico continuou | Smoke #3 ainda FAIL | resolvido parcial |
| F-PROD-06 | 5 | mTLS: `SecPKCS12Import` falha — **diagnóstico [cifra legada] refutado**, causa real = **senha vazia** | D0054→D0055 | `.p12` da baseline usa senha vazia; política do Security.framework rejeita | Experimento controlado; `.p12` reencodado (mesmo par chave/cert) com senha forte + cripto moderna | mTLS ponta-a-ponta HTTP 200 real; BUILD SUCCEEDED; smoke tests | resolvido |
| F-PROD-07 | 5 | HTTP/2 connection coalescing entre hosts com cert wildcard → HTTP 421 | D0057/D0058; P0021/P0022 | Coalescência de conexão do URLSession com `*.tjac.jus.br` | `URLSession` isolada por host mTLS (`sessionsByHost`) | Smoke #6 (P0023): Certidão/CertExt HTTP 200, sem 421 | resolvido |
| F-PROD-08 | 5 | Certidão: PDF gerado descartado | D0061/D0062 | Etapa de persistência/apresentação ausente | Salvar em `Documents/`; QuickLook + ShareLink | Smoke #7 PASS; D0073 | resolvido |
| F-PROD-09 | 5 | Certificado Externo: `listar()` nunca chamado pela UI | D0061/D0063 | Wiring ausente domínio→apresentação | `buscarPessoa()` encadeia `carregarCertificados()`; nova seção na UI | D0073 PASS real | resolvido |
| F-PROD-10 | 5 | AVA/Moodle: sem fallback (Android tem) | D0061/D0064 | Erro lógico do Moodle em HTTP 200; decoding falha; fallback ausente | `loginPageURL()` + fallback | Smoke #7 PASS | resolvido |
| F-PROD-11 | 5 | Certificado Externo: CPF sem máscara `000.000.000-00` | D0065/D0067 | `formatarCpf` do Android não portado | `formattedCPF()` em M-07, nos 4 pontos | curl real HTTP 200; D0073 PASS real | resolvido |
| F-PROD-12 | 5 | Certificados: modelo exige campo `pessoa` inexistente na API real | D0065/D0066 | Modelo derivado de fonte desatualizada — **Android tem a mesma expectativa divergente** | Campo removido de `Certificate` (zero usos) | 15/15 decodificados contra resposta real; D0073 PASS | resolvido |
| F-PROD-13 | 5 | Home: nome exibido = texto bruto do campo de login | D0053 | Wiring de apresentação | `session.fullName → username → "bem-vindo(a)"` | Smoke tests seguintes | resolvido |
| F-PROD-14 | 5 | Sessão não persiste; `logout()` nunca chamado | D0070; P0029 | Estado 100% em memória no AppShell; `onLogout` só resetava memória | `PersistedSessionMeta` + chave de conta; `currentSession()`/`logout()`; restauração no startup | Passos A-D PASS (D0071); E-G PASS (D0073) | resolvido |
| F-PROD-15 | 5 | Placeholder de token + CPFs hardcoded (achado por autorrevisão) | D0041 | `LoginViewModel` não expunha `Session`; CPF `let` sem campo de UI | Session capturada; CPF editável; `ESJUDApp.swift` corrigido | Recompilação → BUILD SUCCEEDED (código incorreto nunca compilado) | resolvido |
| F-PROD-16 | 5 | Erro de compilação M-07 (`PessoaExtData` sem `public`) | RESEARCH_LOG ~553/1020 | DTO com visibilidade padrão exposto por método público | `public` adicionado | Recompilação → BUILD SUCCEEDED (não ativou S6) | resolvido |
| F-PROD-17 | 5 | Drift de timeout em M-04 (15 s uniforme) | RESEARCH_LOG ~1028 | Micro-check S7 pegou timeout menor que o padrão | `list`/`enroll` voltam a 30 s; `fetchForm` explícito 30 s | Corrigido antes do módulo seguinte | resolvido |
| F-PROD-18 | 6 | Suíte 1ª rodada: 8 falhas (`AdminFeedTests`) — requisições saindo à rede real | P0032; GATES nota | Quirk de 1º uso de `URLProtocol` com `protocolClasses` no processo | Suíte de aquecimento `AAABootstrapTests` | 67/67 verde (engine-witnessed) | resolvido |
| F-PROD-19 | 6 | **UC-3: formulário de inscrição não carrega** — fluxo iOS nunca obtém o CPF (sem tela/campo de CPF; `session.cpf` sempre vazio; Android tem `CpfInputDialog`) | P0033; curl mTLS real (HTTP 400 "parâmetros obrigatórios") | Wiring ausente + `loadForm()` não validava CPF | Captura/validação/persistência de CPF; `extractMessage` decodifica JSON; +7 testes de regressão | Compila; 74 testes verdes. **Reteste manual: AINDA FALHA** → F-PROD-20 | **parcial** |
| F-PROD-20 | 6 | **UC-3 continua falhando** ("Erro ao carregar formulário") | P0034; `NetworkModule.kt` Android (`readTimeout 120 s`) | **Sub-orçamento de timeout do cliente iOS (30 s vs 120 s Android)** para endpoint Puppeteer-backed; secundário: modelo `FormularioInscricao` mais estrito que a baseline | **Só a mudança A (observabilidade) aplicada (P0035)** — erro não colapsa mais; sem CPF/PII nos logs. **Correção causal (timeout/modelo) NÃO aplicada** | Mudança A compila; 78 testes verdes. **Reteste manual PENDENTE** | **aberto** |
| F-PROD-21 | 6 | `extractMessage` regex trunca em aspas escapadas (Android tem a mesma limitação) | P0033 (cont.); decisão #72 | Regex ingênua para campo de JSON | Decodifica JSON de verdade antes do fallback | 2 falhas na 1ª rodada por isso; corrigido; verde | resolvido |
| F-PROD-22 | 5 | Divergência estrutural AVA/Moodle vs Android (`.sheet` vs Custom Tabs+onBack) | D0060; P0022 | Tradução de plataforma | **Só instrumentado**, não acionado | Falha AVA/Moodle real resolvida por F-PROD-10 | registrado |

---

## 6. ACHADOS METODOLÓGICOS

> Para cada um: a **evidência concreta** que o sustenta. Nenhum destes é
> *evidência causal* sobre a metodologia — são *observações deste caso*.

### 6.1 Achados técnicos do produto

Ver §5 e `FINDINGS_CURRENT.csv` (F-PROD-01 a F-PROD-22). Padrão
observável (não causal): **todos os 11 defeitos funcionais da Fase 5 e o
defeito da Fase 6 passaram pela compilação (`BUILD SUCCEEDED`) e só foram
revelados por execução real** — humana (smoke test) ou manual
exploratória. Evidência: §8; D0052–D0070; P0033/P0034.

### 6.2 Achados sobre o comportamento do agente (GA)

- **F-META-01 — o GA antecipou repetidamente conclusões que a
  verificação posterior refutou ou refinou.** Evidência concreta:
  - *phase-boundary leakage* no Teach-Back (D0020/P0004);
  - diagnóstico "[cifra legada]" **refutado por experimento controlado**
    (D0054 → D0055 — a causa real era senha vazia);
  - "Certificados: causa NÃO CONFIRMADA" (D0057) **depois confirmada**
    como campo `pessoa` (D0065);
  - correção de wiring de CPF (P0033) **correta mas insuficiente**
    (P0034);
  - o GA também **refutou o relato do próprio VA-human** de que o
    Firebase estava "OK" (D0048 — verificação objetiva: pacote resolve
    mas produto não linkado).
  - Contraponto observável: em vários pontos o VA-human **impôs
    explicitamente** "diagnostique antes de corrigir" e "pare e
    apresente" (P0019, P0020, P0021, P0034) — e o GA seguiu (25
    decisões `diagnosis` na Fase 5; `s6_applied` = met).

### 6.3 Achados sobre o funcionamento do Versus / IACDM

- **F-PROC-01/02/03/04** — os mecanismos de gate e de verificação humana
  da metodologia **capturaram** os desvios *antes* das transições de
  fase: Teach-Back rejeitável (Fase 0), correção de granularidade
  (Fase 1), `advance_phase` bloqueia sem exit criteria marcados (Fase 4).
  Evidência: `GATES.md` G0/G1/G4-04; D0020/D0022.
- **F-PROC-03** — a metodologia **não impôs** um passo de aprovação
  humana isolada para a adição de um módulo novo dentro de uma resposta
  unificada da Fase 3 (M-23 passou junto com 35 resoluções). Evidência:
  D0027; a lacuna só foi fechada por iniciativa do GA (P0008) + aprovação
  post-hoc (D0033).
- **F-PROC-06** — o hook `test-outcome.js` do Versus **não reconhece o
  runner de teste iOS** (`xcodebuild test`); foi necessário um alias
  `npm test`. Evidência: `.versus/test-outcome.js` (`TEST_PATTERNS`);
  Versus decisões #68/#70.
- **F-META-03/04** — `check_all_safeguards` reporta só as safeguards
  "aplicáveis à fase corrente"; S6/S7 em `warning` durante fase de
  implementação ativa é estado **normal**, não violação. Evidência:
  `GATES.md` nota após G4; `get_exit_criteria(5)` `s6_applied`;
  `check_all_safeguards` = 0 violações em toda a Fase 5/6.
- **Observação:** todas as transições de fase (G0–G6) foram
  **aprovadas** — 0 gates de fase reprovados. Isso é *observação do
  caso*, **não** evidência de que a metodologia "funciona": não há
  linha de base sem a metodologia para comparar.

### 6.4 Achados sobre o VA-human

- **F-META-02** — verificação humana **ativa e frequente** neste caso:
  1 Teach-Back rejeitado; 1 correção de granularidade; 3 pausas de fase
  (ambiente, checkpoint 7/23, Firebase manual); **8+ rodadas de smoke
  test reais com credenciais reais**; 2 relatos de FAIL no UC-3 na
  passada exploratória; 1 aprovação parcial ("só a mudança A"). Evidência:
  31 linhas de `DECISIONS.md` com autor "VA-human"; 17 `AskUserQuestion`;
  P0017–P0031/P0033/P0034/P0035.
- **F-META-02 (contradição registrada)** — em P0012 o VA-human **relatou**
  que a integração manual do Firebase estava concluída; a **verificação
  objetiva do GA divergiu** (D0048): o pacote resolvia mas
  `FirebaseMessaging` não estava linkado ao target. A divergência foi
  registrada como tal, sem suavizar.

### 6.5 Limitações do estudo

- **F-META-05** (estrutural, declarada no `STUDY_PROTOCOL.md`): caso
  único; sem grupo de controle; pesquisador = operador (viés de
  confirmação); baseline única de domínio institucional; dependência de
  ferramenta versionada; ambiente de build iOS incompleto no início.
- **F-META-06** (mensuração): **métricas de esforço/tempo por atividade
  não são calculáveis** — `RESEARCH_LOG.md` registra timestamp por
  *entrada*, não por ação; sem marcação de início/fim de esforço; sem
  rótulo de sessão.
- **F-META-07** (mensuração): **contagem total exata de builds e de
  execuções de teste não é auditável** — só limites inferiores.
- **F-META-08** (mensuração): **contador de VAL cobertos
  automaticamente desatualizado** — "34/40" é snapshot de 67 testes;
  há 43 VAL e 78 testes hoje, sem recontagem formal.
- **F-PROC-07** (registro): `P0014.md` ausente; `D0049` ausente de
  `DECISIONS.md`; `DECISIONS.md` não atualizada para a Fase 6.

---

## 7. MÉTRICAS TEMPORAIS

> Apenas *spans de calendário* entre timestamps de gate são calculáveis
> de forma confiável. **Esforço** (tempo de trabalho ativo) **não é
> calculável** com os registros atuais (F-META-06). Os spans abaixo
> incluem lacunas longas entre sessões (instalação de Xcode; ~19 h de
> gap enquanto o VA-human tentava o Firebase manualmente em
> 2026-08-30; etc.) e **não representam esforço**.

| Fronteira | Timestamp (UTC) | Fonte |
|---|---|---|
| Início do registro | 2026-08-26T21:52:28Z | STUDY_PROTOCOL.md; P0001 [M090] |
| 1ª decisão da Fase 0 (D0007) | 2026-08-26T22:23:47Z | Versus get_decisions |
| Gate Fase 0 → 1 | 2026-08-26T23:36:39Z | GATES G0-03 [M091] |
| Gate Fase 1 → 2 | 2026-08-29T16:39:59Z | GATES G1-02 [M092] |
| Gate Fase 2 → 3 | 2026-08-29T16:54:06Z | GATES G2-02 [M093] |
| Gate Fase 3 → 4 | 2026-08-29T16:54:06Z | GATES G3-02 [M094] |
| Gate Fase 4 → 5 | 2026-08-29T16:56:14Z | GATES G4-04 [M095] |
| Fase 5 pausada (ambiente) | 2026-08-29T21:39:29Z | GATES; D0029 [M096] |
| Fase 5 retomada | 2026-08-29T21:40:49Z | ENVIRONMENT.md; D0030 [M097] |
| Gate Fase 5 → 6 | 2026-08-31T17:11:05Z | GATES [M098] |
| Gate critério Fase 6 `tests_passing` | 2026-08-31T17:49:41Z | GATES; Versus `lastTestOutcome` [M099] |
| Última decisão registrada (P0035) | 2026-08-31T22:50:22Z | Versus get_decisions [M100] |
| Este relatório (P0036) | 2026-09-02T14:42:49Z | RESEARCH_LOG P0036 |

**Spans de calendário entre gates:**

| Fase | Span (calendário) | Fonte | Nota |
|---|---|---|---|
| 0 | **~1 h 13 min** (1ª decisão → gate) [M101] | M090b→M091 | Sessão única; ~1 h 44 min desde o research-init |
| 1 | **~2 d 17 h 03 min** (gate→gate) [M102] | M091→M092 | ~2,7 dias sem atividade; trabalho ativo de Fase 1 ≈ 9 min em 2026-08-29 (+ proposta de 11 módulos rejeitada) |
| 2 | **~14 min** [M103] | M092→M093 | — |
| 3 | **não isolável** [M104] | M093 = M094 | Gates G2 e G3 registrados no mesmo timestamp |
| 4 | **~2 min** [M105] | M094→M095 | — |
| 5 | **~1 d 20 h 15 min** (gate→gate) [M106] | M095→M098 | **Fortemente pontuado por lacunas entre sessões** — NÃO é esforço |
| 6 | **~2 d 21 h+** (gate→este relatório) [M107] | M098→P0036 | **Fase 6 ABERTA** (2/3 critérios pendentes) |

- **Tempo entre gate de entrada e de saída:** as linhas acima (spans de
  calendário). Confiável apenas como *duração de calendário*, não como
  *duração de trabalho*.
- **Tempo gasto em implementação / correção / testes isoladamente:**
  **não calculável com os registros atuais** [M108] — sem instrumentação
  de esforço.
- **Quantidade de sessões de chat:** **não rotulada nos registros**
  [M109]. Estimável por agrupamento de timestamps (≥ 9–10 janelas de
  trabalho distintas), mas isso **não é um dado observado**.
- **Eventos explícitos de pausa/retomada/renovação: 4** [M110] —
  D0029/D0030 (ambiente); D0032 (checkpoint 7/23); D0047 (Firebase
  manual); Versus decisão #67 + `RESEARCH_LOG.md` P0032 (renovação de
  sessão "retomar Versus" na Fase 6).
- **Retomadas pós-compactação de contexto:** ≥ 1 nesta sessão (não há
  contador persistente) [M111].

---

## 8. RETRABALHO

| Métrica | Valor | Fonte |
|---|---|---|
| Diagnósticos posteriormente refutados/corrigidos | **3** [M085] | D0054→D0055 ([cifra legada] → senha vazia); D0053 insuficiente → D0054; D0057 "não confirmado" → D0065 confirmado |
| Decisões revisadas por nova entrada (histórico preservado) | **5** [M086] | D0020→síntese revisada; D0022→D0023; D0054→D0055; D0072→D0073; P0033→P0034→P0035 |
| Ciclos "falha → diagnóstico → correção → novo teste" **fechados** | **5** [M087] | RESEARCH_LOG P0017–P0026 (Firebase; mTLS+nome; PKCS12; HTTP/2 coalescing + frentes; Certidão/CertExt/AVA; Certificados/CPF) |
| Ciclo "falha → diagnóstico → correção → novo teste" **aberto** | **1** | Fase 6 / UC-3: P0033 correção → P0034 falha → P0035 observabilidade → **reteste pendente** |
| Problemas encontrados **só após build verde** | **12** [M088] | 11 defeitos funcionais da Fase 5 (F-PROD-01/05/06/07/08/09/10/11/12/13/14) + UC-3 da Fase 6 |
| Problemas encontrados **só após testes automatizados verdes** | **1** [M089] | UC-3 (F-PROD-19/20): 67/74/78 testes verdes; o defeito "formulário não carrega" só apareceu no teste manual exploratório — os testes automatizados usavam `urlCurso` e CPF fictícios e nunca exercitaram o caminho real. O achado de P0034 (timeout 30 s vs 120 s) também persiste com 78 testes verdes |

**Padrão observável (não causal):** o *build verde* e a *suíte
automatizada verde* **não** capturaram nenhum dos defeitos funcionais
mais relevantes deste caso. A verificação que os capturou foi
**execução humana real** (smoke test / passada exploratória), o que
está alinhado ao S4/AP5 da metodologia ("Human-AV é insubstituível em
cada gate"). Evidência: §4.7, §7, D0052–D0070, P0033/P0034.

---

## 9. RASTREABILIDADE

- Toda métrica numérica deste documento tem um identificador `M###`
  correspondente em `research/METRICS/PARTIAL_RESULTS_TABLE.csv`, com as
  colunas `fonte` (arquivo / ID de decisão / entrada de log / resultado
  Versus) e `observacao`.
- Todo achado tem um identificador `F-###` em
  `research/METRICS/FINDINGS_CURRENT.csv`, com `evidencia`, `causa`,
  `acao`, `validacao` e `status`.
- Fontes primárias usadas nesta consolidação:
  `research/STUDY_PROTOCOL.md`, `research/ENVIRONMENT.md`,
  `research/BASELINE.md`, `research/BASELINE_MANIFEST.md`,
  `research/RESEARCH_LOG.md` (2685 linhas; headings e greps
  quantitativos), `research/GATES.md` (integral),
  `research/DECISIONS.md` (integral),
  `research/PROMPT_LOG/` (listagem), `research/METRICS/README.md`,
  `specs/validation/*`, `specs/datasets/*`,
  `specs/design/coverage-matrix.md`, `specs/technical/architecture.md`,
  e o estado do Versus via `get_phase_state`, `get_decisions`,
  `get_exit_criteria(0..6)`.
- **Contradições/lacunas explicitamente registradas** (não resolvidas
  nesta consolidação): F-PROC-07 (P0014.md ausente; D0049 ausente;
  DECISIONS.md desatualizada para a Fase 6); F-META-06/07/08
  (esforço/tempo, contagem de builds, contador de VAL); M104 (Fase 3
  não isolável no tempo); P0012 vs D0048 (relato do VA-human vs
  verificação objetiva do GA sobre o Firebase).

---

## 10. SAÍDAS GERADAS

| Arquivo | Conteúdo |
|---|---|
| `research/METRICS/PARTIAL_RESULTS_CURRENT.md` | Este relatório (10 seções, auditável) |
| `research/METRICS/PARTIAL_RESULTS_SUMMARY.md` | Resumo de 1–2 páginas para a orientadora |
| `research/METRICS/PARTIAL_RESULTS_TABLE.csv` | 1 linha por métrica: `metric_id, categoria, nome, valor, unidade, fase, fonte, observacao` (M001–M111) |
| `research/METRICS/FINDINGS_CURRENT.csv` | 1 linha por achado: `finding_id, fase, tipo, descricao, evidencia, causa, acao, validacao, status` (F-PROC/F-PROD/F-META) |

**Aviso final (repetido do topo):** esta é uma consolidação **parcial**.
A Fase 6 está aberta (2/3 critérios pendentes; UC-3 com defeito aberto).
Nenhuma afirmação de efetividade ou superioridade da IACDM é feita ou
implícita. O que este documento sustenta é: *o que foi registrado, com
que evidência, e onde os registros são insuficientes.*
