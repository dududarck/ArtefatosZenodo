# Registro de Gates e Transições de Fase (IACDM/Versus)

Este arquivo registra, cronologicamente, toda transição de fase e todo
resultado de gate/safeguard observado a partir do estado real do Versus
(`.versus/state.json` e saídas das ferramentas MCP `mcp__versus-claude__*`),
nunca a partir de afirmação do GA sobre si mesmo.

Regras de preenchimento:

- Cada linha corresponde a um evento observado, não a uma intenção.
- Um gate só é registrado como aprovado quando a ferramenta MCP
  correspondente (`get_exit_criteria`, `check_safeguard`,
  `check_all_safeguards`, `advance_phase`) reportar isso, ou quando o
  VA-human confirmar explicitamente uma aprovação humana — e o tipo de
  evidência (automática vs. humana) deve ser sempre indicado.
- Nenhuma linha é reescrita retroativamente; correções entram como novas
  linhas com referência à linha corrigida.

## Estado inicial observado (referência, não é uma transição)

| Timestamp (UTC) | Campo | Valor observado | Fonte |
|---|---|---|---|
| 2026-08-26T21:5xZ | `.versus/state.json`.currentPhase | 0 | Leitura direta do arquivo de estado (somente leitura) |
| 2026-08-26T21:5xZ | `.versus/state.json`.currentIteration | 1 | idem |
| 2026-08-26T21:5xZ | `.versus/state.json`.phase0Score | null | idem |
| 2026-08-26T21:5xZ | `.versus/state.json`.safeguards | S0–S7 todos "ok" (estado inicial padrão) | idem |
| 2026-08-26T21:5xZ | `.versus/state.json`.decisions | [] (vazio) | idem |
| 2026-08-26T21:5xZ | `.versus/state.json`.createdAt | 2026-08-23T03:28:54.518Z | idem |

Nota: este estado foi lido diretamente do arquivo apenas para fins de
registro de baseline do próprio estudo (não é a via recomendada de
interação corrente com o Versus, que deve ocorrer via ferramentas MCP).
Nenhuma escrita foi feita em `.versus/`.

## Log de transições e gates

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência | Observações |
|---|---|---|---|---|---|---|
| (nenhuma transição ocorreu ainda) | | | | | | A Fase 0 do IACDM ainda não foi iniciada por instrução explícita do usuário (P0001). |

## Atualização — P0002 (2026-08-26)

Nenhuma transição de fase ou gate do IACDM ocorreu em P0002. As
atividades realizadas (manifesto de baseline, preenchimento de
`specs/`) são preparação pré-Fase-0 explicitamente solicitada pelo
VA-human, e não substituem nem antecipam o veredito de nenhum exit
criterion de Fase 0 (que continua exigindo as chamadas MCP
`get_exit_criteria`/`mark_exit_criterion` no momento apropriado). O
estado do Versus (`.versus/state.json`) permanece:
`currentPhase = 0`, `currentIteration = 1`, `decisions = []`,
`phase0Score = null` — não lido novamente neste evento, apenas
inferido como inalterado por nenhuma ferramenta MCP de escrita ter sido
chamada.

## Atualização — P0004 (2026-08-26): verificação Human-AV funcionou antes do Gate G0

Nenhuma transição de fase ocorreu. Registro de que o mecanismo de
verificação humana (Human-AV, Teach-Back) previsto pela metodologia para
a Fase 0 funcionou como esperado: permitiu ao VA-human identificar e
rejeitar uma síntese que misturava fatos/restrições confirmados com
decisões de solução antecipadas ("possível vazamento de decisões de
solução para a Fase 0" / phase-boundary leakage — ver
`RESEARCH_LOG.md`, P0004; `DECISIONS.md`, D0020) **antes** de qualquer
tentativa de cruzar o Gate G0 (`advance_phase` para a Fase 1). O score de
convergência da Fase 0 (`phase0Score`) permanece `null` — nenhuma
pontuação foi submetida com base na síntese rejeitada. Esta ocorrência
será observada nas próximas fases/iterações para determinar se é
episódica ou sistemática (ver nota de acompanhamento em
`RESEARCH_LOG.md`, P0004).

## Gate G0 — Convergência da Fase 0 (2026-08-26)

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência | Observações |
|---|---|---|---|---|---|---|
| G0-01 | 2026-08-26T23:36:39Z | Fase 0 (permanece) | Score de convergência (`update_score`) | 96/100 (breakdown: clarezaProblema 10, casosDeUso 14, vocabulario 10, ambiguidades 13, foraDeEscopo 10, criteriosSucesso 9, premissas 10, documentacao 5, usuarioConfirmou 10, iaConfiante 5) | Automática (ferramenta MCP `update_score`) + julgamento do GA na atribuição de cada nota | Score computado e exibido em chat ANTES de ser submetido (R5); `meetsThreshold: true` retornado pela ferramenta |
| G0-02 | 2026-08-26T23:36:39Z | Fase 0 (permanece) | 10 exit criteria (`get_exit_criteria`/`mark_exit_criterion`) | 10/10 `met=true` | Automática (ferramentas MCP) | Cada critério marcado individualmente com `details` citando evidência específica (não fabricado); `ambiguities_zero` marcado como "aceito" (5 ambiguidades técnicas menores explicitamente documentadas como pendências, não escondidas — evitando AP10) |
| G0-03 | 2026-08-26T23:36:39Z | **Fase 0 → Fase 1** | `advance_phase(target_phase=1)` | Sucesso — `currentPhase: 1` | Automática (ferramenta MCP `advance_phase`, que valida server-side todos os exit criteria antes de permitir) | Primeira transição de fase real do estudo |

### Nota sobre o achado P0004 e este gate

O achado de "phase-boundary leakage" (P0004) foi detectado e corrigido
**antes** deste gate ser tentado — a síntese de Teach-Back rejeitada na
Iteração 1 nunca chegou a ser usada como base para pontuação ou
avanço de fase. O score de 96/100 e os 10 exit criteria acima refletem
a síntese **revisada e aprovada**, não a versão rejeitada. Isso é
evidência de que o mecanismo de verificação humana (Human-AV) funcionou
como projetado neste caso específico — não é ainda evidência suficiente
para concluir se o padrão de vazamento tende a se repetir nas próximas
fases (ver acompanhamento solicitado em P0004).

## Gate G1 — Convergência da Fase 1 (Arquitetura) — 2026-08-29T16:39:59Z

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência | Observações |
|---|---|---|---|---|---|---|
| G1-01 | 2026-08-29T16:39:59Z | Fase 1 (permanece) | 8 exit criteria (`get_exit_criteria`/`mark_exit_criterion`) | 8/8 `met=true` | Automática (ferramentas MCP) | Cada critério com `details` citando `specs/technical/architecture.md` e decisões D0022-D0025 |
| G1-02 | 2026-08-29T16:39:59Z | **Fase 1 → Fase 2** | `advance_phase(target_phase=2)` | Sucesso — `currentPhase: 2` | Automática (ferramenta MCP, valida server-side) | Segunda transição de fase real do estudo |

Nota: a decomposição de módulos passou por uma rodada de correção de
granularidade do VA-human (P0005) antes de ser aprovada — a versão
aprovada (22 módulos) é a única persistida em
`specs/technical/architecture.md`; a versão inicial de 11 módulos não
foi escrita em arquivo, apenas exibida em chat e rejeitada.

## Gate G2 — Convergência da Fase 2 e Gate G3 — Fase 3 — 2026-08-29T16:54:06Z

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência |
|---|---|---|---|---|---|
| G2-01 | 2026-08-29T16:54:06Z | Fase 2 (permanece) | 5 exit criteria da Fase 2 | 5/5 `met=true` | Automática (MCP) |
| G2-02 | 2026-08-29T16:54:06Z | **Fase 2 → Fase 3** | `advance_phase(3)` | Sucesso | Automática (MCP) |
| G3-01 | 2026-08-29T16:54:06Z | Fase 3 (permanece) | 4 exit criteria da Fase 3 | 4/4 `met=true` | Automática (MCP) |
| G3-02 | 2026-08-29T16:54:06Z | **Fase 3 → Fase 4** | `advance_phase(4)` | Sucesso | Automática (MCP) |

Loop 2↔3 executado uma única vez (Iteração 1); não houve retorno à
Fase 2 pois a mudança estrutural (4,3%) e críticos remanescentes (0)
ficaram abaixo do limiar de nova iteração — decisão aceita pelo
VA-human (D0028).

## Gate G4 — Convergência Final (Fase 4) — 2026-08-29T16:55:49Z

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência |
|---|---|---|---|---|---|
| G4-01 | 2026-08-29T16:55:49Z | Fase 4 (permanece) | Relatório de convergência (5 itens: exit criteria F2/F3, safeguards, 4 perguntas F1, concentração sem falha sistêmica, specs/ populado) | 5/5 ✅ | Automática (`check_all_safeguards`, `check_specs_status`, `get_exit_criteria`×2) + julgamento do GA na leitura dos resultados |
| G4-02 | 2026-08-29T16:55:49Z | — | LLM Switch Point oferecido | VA-human optou por continuar na mesma sessão | Humana (AskUserQuestion) |
| G4-03 | (a seguir) | **Fase 4 → Fase 5** | `advance_phase(5)` | (pendente de registro na próxima entrada) | Automática |

Nota sobre `check_all_safeguards`: retornou apenas S2 e S4 como
"aplicáveis" nesta chamada (ambas `ok`) — não as 8 safeguards S0-S7
completas do estado inicial do projeto. Isso é o comportamento
documentado da ferramenta ("Checks ALL safeguards applicable to the
CURRENT phase"), registrado aqui para não ser confundido com uma
omissão de verificação.

## Gate G4 (conclusão) e transição para Fase 5 — 2026-08-29T16:56:14Z

| ID | Timestamp (UTC) | Fase origem → destino | Gate/critério | Resultado | Tipo de evidência |
|---|---|---|---|---|---|
| G4-03 | 2026-08-29T16:56:14Z | Fase 4 (permanece) | 2 exit criteria da Fase 4 (`exit_criteria_p2p3`, `safeguards_s1_s5`) | 2/2 `met=true` | Automática (MCP) |
| G4-04 | 2026-08-29T16:56:14Z | **Fase 4 → Fase 5** | `advance_phase(target_phase=5)` — primeira tentativa falhou (`missingCriteria`: os 2 exit criteria da própria Fase 4 ainda não haviam sido marcados via `mark_exit_criterion`, apesar de verificados em chat) | Sucesso após correção | Automática (MCP) |

**Marco metodológico:** a partir deste gate, o IACDM permite
implementação de código Swift/iOS de produção (Fase 5), conforme a
regra estabelecida em `research/STUDY_PROTOCOL.md` ("código iOS de
produção não poderá ser implementado antes que o IACDM permita"). Todo
código de produção escrito a partir de agora deve ser registrado em
`RESEARCH_LOG.md` com anúncio de progresso, por instrução R5/Fase 5 da
metodologia.

## Fase 5 — PAUSADA por bloqueio de ambiente — 2026-08-29T21:39:29Z

O projeto entrou na Fase 5 (Gate G4 cruzado com sucesso), mas foi
**pausado antes da implementação de qualquer módulo** por decisão
explícita do VA-human, diante da ausência de Xcode no ambiente (ver
`research/ENVIRONMENT.md`, `RESEARCH_LOG.md` P0006, `DECISIONS.md`
D0029). Nenhum código de produção foi escrito. Nenhuma verificação
Automated-AV (compilação/lint/teste) foi executada ou poderia ter sido
executada de forma genuína neste ambiente. O estado do Versus permanece
`currentPhase = 5`, `currentIteration = 1`, aguardando retomada
quando o ambiente permitir verificação real.

## 2026-08-31T17:11:05Z — Gate de saída da Fase 5 → Fase 6

**Fonte da evidência**: ferramenta MCP `mcp__versus-claude__get_exit_criteria`/`check_all_safeguards`/`advance_phase` (não afirmação do GA).

| Critério | Status | Evidência |
|---|---|---|
| all_modules | ✅ atendido | 22/22 módulos V(2) + M-23, `xcodebuild BUILD SUCCEEDED` real (Package + App target) |
| specs_consulted | ✅ atendido | specs/architecture consultado por módulo, disciplina P0010/P0011 |
| s6_applied | ✅ atendido | Diagnóstico nomeado antes de cada nova tentativa em todas as falhas reais desta sessão |
| ui_runnable | ✅ atendido | Smoke test P0 end-to-end real, credenciais reais, múltiplas rodadas (P0021–P0031), todos os fluxos P0 PASS dentro do app real (D0073) |

`check_all_safeguards()`: 0 violações (S2 ok; S6/S7 em `warning`, esperado durante Fase 5 ativa).

`advance_phase(target_phase=6)` → `success: true`. **Fase 5 encerrada; Fase 6 iniciada.**

**Dívida técnica explicitamente preservada através deste gate**: push FCM real (D0051) — pendência externa, não resolvida por este avanço, a ser tratada como item de escopo pendente na Fase 6 (Scope Inventory).

## 2026-08-31T17:49:41Z — Gate de critério da Fase 6: `tests_passing`

**Fonte da evidência**: hook `test-outcome.js` do Versus (execução real testemunhada pelo engine — não afirmação do GA). `mcp__versus-claude__get_phase_state` → `lastTestOutcome = {outcome: "pass", phase: 6, exitCode: 0, exitSource: "echo" (VERSUS_TEST_EXIT), toolUseId real, at: 2026-08-31T17:49:41.033Z}`.

| Critério | Status | Evidência |
|---|---|---|
| tests_passing | ✅ atendido (`met=true` via `mark_exit_criterion`) | Suíte XCTest `DomainTests` (13 arquivos, 67 testes, 0 falhas) executada via `xcodebuild test -scheme ESJUDAC-Package -destination 'platform=iOS Simulator,name=iPhone 17'` (envolto em `npm test` só para o hook reconhecer; runner XCTest não modificado). Run verde testemunhado pelo engine. |
| manual_testing | ⏳ pendente (`met=false`) | Aguardando a passada exploratória dedicada do VA-human (roteiro registrado, `record_decision` phase=6 category=testing "TESTING STATUS: automated-done"). |
| edge_cases | ⏳ pendente (`met=false`) | Idem — edge cases incluídos no mesmo roteiro. |

`check_all_safeguards()`: 0 violações (S6/S7 em `warning`, estado normal). Nenhuma transição de fase neste gate — a Fase 6 permanece aberta até `manual_testing` e `edge_cases` serem confirmados por execução humana real.

**Anomalia registrada** (ver `RESEARCH_LOG.md`, P0032): a 1ª rodada da suíte teve 8 falhas reais em `AdminFeedTests` (requisições saindo para a rede real por não-interceptação do `URLProtocol` stub no 1º uso de `URLSession` do processo). Causa nomeada e corrigida (suíte de aquecimento `AAABootstrapTests`); rodada seguinte 67/67 verde. Não ativou S6 (1 falha, 1 causa, 1 correção).

## 2026-09-06T01:53:26Z — Fase 6: execução real de build/teste após P0045 (integração Firebase/FCM)

**Fonte da evidência**: execução real (não afirmação do GA).

| Item | Resultado real | Fonte |
|---|---|---|
| Suíte automatizada | **96 testes, 0 falhas**, `** TEST SUCCEEDED **` | `npm test` → `xcodebuild test -scheme ESJUDAC-Package -destination 'platform=iOS Simulator,name=iPhone 17'`; run verde **testemunhado pelo engine** (`VERSUS_TEST_EXIT=0`). +7 `PushTransportTests` (89 → 96). |
| Package build | `** BUILD SUCCEEDED **` (exit 0) | `xcodebuild build -scheme ESJUDAC-Package` |
| App target build | `** BUILD SUCCEEDED **` (exit 0) | `xcodebuild -scheme ESJUDApp -destination 'platform=iOS Simulator,name=iPhone 17' clean build` (`AppShell/`) |
| Plist no bundle | `GoogleService-Info.plist` presente na raiz do `.app` | inspeção do bundle em `DerivedData/.../ESJUDApp.app` |
| Background mode | `UIBackgroundModes = [remote-notification]` no `Info.plist` do bundle | `plutil -p .../ESJUDApp.app/Info.plist` |
| Entitlement `aps-environment` | `.xcent` sai **vazio** sob assinatura ad-hoc sem *team* — **esperado**; só passa a valer com assinatura institucional | `codesign -d --entitlements` no `.app`; `ProcessProductPackaging` no log de build |

`check_all_safeguards()`: **0 violações** (S2/S4 ok; S6 `warning`, `0/3` — normal com implementação ativa). Nenhuma falha consecutiva de teste → S6 não acionado.

**Critérios de saída da Fase 6 — inalterados**: `tests_passing` permanece `met=true`; `manual_testing` e `edge_cases` permanecem **`met=false`**. Nenhuma transição de fase. **UC-9 Notificações NÃO marcado PASS** — compilar e rodar teste não é prova de push real; o fechamento do UC-9 depende de ações humanas (dispositivo físico + conta Apple institucional + APNs Auth Key no Firebase Console + envio de push de teste + validação manual S4), registradas em `DECISIONS.md` D0089 e `RESEARCH_LOG.md` (P0045).

## 2026-09-06T02:11:14Z — Fase 6: classificação de estado do UC-9 (P0046) — sem execução de gate

**Sem alteração de código; nenhum build/teste novo executado** (o último — P0045, 96 testes verdes engine-witnessed + App target `BUILD SUCCEEDED` — permanece a evidência corrente).

| Item | Estado |
|---|---|
| **UC-9 Notificações** | **IMPLEMENTAÇÃO CONCLUÍDA / VALIDAÇÃO REAL PENDENTE POR DEPENDÊNCIA INSTITUCIONAL.** Não PASS manual, não FAIL do cliente. Integração de cliente iOS verificada por build/teste (P0045/D0088). |
| Bloqueio | **EXT-DEP-03** — não há Apple Developer Team institucional (TJAC) no Xcode → `aps-environment` não entra no provisioning (`.xcent` vazio sob assinatura ad-hoc, comprovado P0045/D0089) → registro APNs e push real em dispositivo indisponíveis. Distinto de `EXT-DEP-01` (plist, resolvido 2026-09-05). |

`check_all_safeguards()`: **0 violações** (S6 `warning`, `0/3`). **Critérios de saída da Fase 6 inalterados**: `tests_passing` `met=true`; `manual_testing` e `edge_cases` **`met=false`**. Nenhuma transição de fase. A passada exploratória **não** fica bloqueada por `EXT-DEP-03` — segue para o **BLOCO D** (UC-10 Lembretes + edge cases).

## 2026-09-06T02:31:19Z — Fase 6: consolidação final da validação funcional (P0047 / D0091) — SEM avanço de fase

**Sem alteração de código. Nenhum `mark_exit_criterion` / `advance_phase` executado** (aguarda confirmação explícita do VA-human).

### Critérios de saída da Fase 6

| Critério | `met` | Avaliação objetiva |
|---|---|---|
| `tests_passing` | ✅ `true` (já marcado 2026-08-31) | Evidência **corrente**: `npm test` → 96 testes, 0 falhas, `** TEST SUCCEEDED **`, run verde **testemunhado pelo engine** (`lastTestOutcome` outcome=pass, phase=6, exitCode=0, `2026-09-06T01:57:12Z`). Suíte cresceu 67 → 78 → 96 ao longo da Fase 6, sempre verde, sem regressão. |
| `manual_testing` | ⏳ `false` | **9/12 casos de uso com PASS manual** confirmado pelo VA-human (UC-1/2/4/5/6/7/8/11/12) + UC-3 reclassificado (paridade, não é defeito do cliente) + UC-9 cliente-completo. **Pendência:** UC-10 — perna de entrega da notificação local (`UNUserNotificationCenter.add` em `scenePhase==.active`), não coberta pelo ambiente automatizado, não depende de APNs/Team. Fecha com *check* curto **ou** *waiver* do VA-human. |
| `edge_cases` | ⏳ `false` | **Cobertura substancial de fato**: achados adversariais reais corrigidos com teste de regressão durante a passada (UC-3 máquina de estados P0037–P0040; Certificados P0042; CPF em log P0042; seletor CertExt P0044) + caminhos de erro/limite automatizados (rejeições 400/409/422 sem PII; `hasValidCPF`; `PDFAttachment`; dedup push×polling; cadência de lembretes; cancelamento vs timeout). Marcável `met` como **julgamento do VA-human** com esta racional. |

`check_all_safeguards()`: **0 violações** (S6 `warning`, `0/3`).

### Ressalvas explícitas para o fechamento da Fase 6 → Fase 7

Dependências externas do ecossistema institucional, **comuns à baseline Android**, **não** defeitos do produto iOS:

- **EXT-DEP-02** — UC-3 Inscrição: `GET /[endpoint-formulario-inscricao]` → HTTP 422 `FORM_UNAVAILABLE`/`etapa: timeout` determinístico para a maioria dos cursos (Puppeteer server-side; backend é contrato fixo D0012). Cliente iOS verificado correto e em paridade.
- **EXT-DEP-03** — UC-9 Notificações: validação de runtime do push real bloqueada por falta de Apple Developer Team / provisioning APNs institucional do TJAC. Integração de cliente concluída e verificada por build/teste.
- `EXT-DEP-01` (arquivo `GoogleService-Info.plist`) — **RESOLVIDO** em 2026-09-05.

**Proposta:** confirmados UC-10 (check/waiver) e a racional de `edge_cases` pelo VA-human → `manual_testing` e `edge_cases` a `met=true` → Fase 6 fechada **com as ressalvas acima** → preparar `advance_phase(7)` **somente após go/no-go explícito do VA-human**.

## 2026-09-06T02:44:41Z — Fase 6: refinamento da classificação do UC-9 (P0047 cont. / D0092)

Esclarecimento do VA-human. UC-9 **split**:
- **Tela de Notificações / listagem de avisos / polling `/api/public/feed` / badge / marcar todas como lidas: PASS manual** (execução humana real).
- **Push remoto APNs/FCM: implementação concluída / validação runtime pendente** por `EXT-DEP-03` (falta Apple Developer Team institucional do TJAC + provisioning com `aps-environment`). Não é FAIL do cliente. Não bloqueia o fechamento da Fase 6 — a ressalva `EXT-DEP-03` permanece registrada e será carregada para a Fase 7.

**Efeito nos critérios de saída:** UCs com PASS manual passam de **9/12 para 10/12** (UC-1/2/4/5/6/7/8/9/11/12). `tests_passing` permanece `met=true`. `manual_testing` e `edge_cases` permanecem `met=false` — itens abertos **inalterados**: (1) UC-10 perna de entrega da notificação local (check curto **ou** waiver); (2) aceitação da racional de `edge_cases` pelo VA-human. Nenhum `mark_exit_criterion` / `advance_phase` executado.

## 2026-09-06T03:33:51Z — Fase 6: ajuste final da classificação do UC-9 (P0047 cont. / D0093)

Esclarecimento adicional do VA-human: a funcionalidade de notificações administrativas **já funciona em runtime** (aviso enviado aparece no app; toque no ícone mostra o aviso na lista; feed/polling/badge/tela operacionais).

**Classificação definitiva do UC-9:**
- feed / listagem / polling `/api/public/feed` / badge / marcar como lidas: **PASS manual**.
- **Recebimento da notificação dentro do app** (aviso enviado → lista via feed/polling): **PASS manual**.
- **Push remoto do sistema iOS (APNs/FCM)** — banner na Central de Notificações, background/encerrado, tap abrindo o app/tela: **implementação concluída / validação runtime pendente** por `EXT-DEP-03`.

A pendência é **exclusivamente o canal push remoto do sistema iOS**. Não bloqueia o fechamento da Fase 6. `tests_passing` `met=true`; `manual_testing`/`edge_cases` `met=false` — itens abertos **inalterados**: (1) UC-10 perna de entrega da notificação **local**; (2) aceitação da racional de `edge_cases` pelo VA-human. Nenhum `mark_exit_criterion` / `advance_phase` executado.

## 2026-09-06T03:44:58Z — FECHAMENTO DA FASE 6 (Testes) com ressalvas documentadas — P0048 / D0094

**GO explícito do VA-human.** Fonte da evidência: execução real + decisão humana registrada.

### Critérios de saída da Fase 6 — estado final

| Critério | `met` | Evidência |
|---|---|---|
| `tests_passing` | ✅ `true` | 96 testes, 0 falhas, `** TEST SUCCEEDED **`, run verde **testemunhado pelo engine** (`lastTestOutcome` outcome=pass, phase=6, exitCode=0, `2026-09-06T01:57:12Z`). Suíte cresceu 67 → 78 → 96 ao longo da Fase 6, sempre verde. Package + App target `BUILD SUCCEEDED`. |
| `manual_testing` | ✅ `true` (com ressalvas) | Passada exploratória manual concluída (P0032–P0048), execução humana real do VA-human. **10/12 UCs PASS manual.** Ressalvas: UC-3 = paridade + `EXT-DEP-02`; UC-9 push remoto do sistema iOS = `EXT-DEP-03`; UC-10 = **waiver explícito** do VA-human (não PASS manual). `mark_exit_criterion` executado com `details` completo. |
| `edge_cases` | ✅ `true` | Racional aceita pelo VA-human: cobertura adversarial real da Fase 6 com achados reais + correções + testes de regressão (UC-3 máquina de estados; Certificados estado/PDF; CPF em log; seletor CertExt) + caminhos de erro/limite automatizados. `mark_exit_criterion` executado com `details` completo. |

`check_all_safeguards()`: **0 violações** (S6 `warning` 0/3 — normal).

### Fase 6 encerrada — pendências carregadas para a Fase 7

Dependências externas do ecossistema institucional, **comuns à baseline Android**, **não** defeitos do produto iOS:

- **EXT-DEP-02** — UC-3 Inscrição: backend `api-esjud.tjac.jus.br` / Puppeteer server-side (HTTP 422 `etapa: timeout`, contrato fixo D0012).
- **EXT-DEP-03** — UC-9 push remoto do sistema iOS: falta Apple Developer Team institucional do TJAC + provisioning com `aps-environment` + APNs Auth Key `.p8` no Firebase Console + envio de push de teste + validação S4 em dispositivo real.
- **Waiver UC-10** — validação manual da entrega da notificação **local** não realizada (aceita por decisão do VA-human, D0094).
- `EXT-DEP-01` (arquivo `GoogleService-Info.plist`) — **RESOLVIDO** 2026-09-05.

### `advance_phase(7)` — RETIDO

O engine sinalizou que os 3 critérios estão `met` e que o próximo passo seria `advance_phase()`. **Não executado** — o VA-human exigiu confirmação final explícita antes do avanço (S2 = critério de parada pertence ao usuário). A Fase 6 está pronta para fechar; o avanço aguarda o "go" final.

## 2026-09-06T03:47Z — TRANSIÇÃO DE FASE: Fase 6 (Testes) → Fase 7 (Post-Review)

**Fonte da evidência (real, não afirmação do GA):**
- `get_exit_criteria(phase=6)` → **3/3 `met`** (`tests_passing`, `manual_testing`, `edge_cases`), com os `details` completos gravados em cada critério.
- `advance_phase(target_phase=7)` → `{"success":true,"message":"Advanced to Phase 7.","currentPhase":7,"currentIteration":1}`.
- `check_all_safeguards()` (pré-transição) → 0 violações (S6 `warning` 0/3).

**GO explícito do VA-human** (P0048 + confirmação final via `AskUserQuestion` = "GO — executar advance_phase(7)").

**Anomalia registrada:** a 1ª chamada `advance_phase()` falhou (`target_phase` ausente → "Phase undefined") **e** o engine reportou `tests_passing` como não testemunhado porque comandos `Bash` de `cat >> GATES.md`/`FINDINGS_CURRENT.csv` (escrita do registro científico) foram interceptados pelo hook `test-outcome.js` e classificados como `outcome="unknown"`, sobrescrevendo o `lastTestOutcome` verde anterior. Correção: re-execução de `npm test; echo "VERSUS_TEST_EXIT=$?"` isolado → `VERSUS_TEST_EXIT=0`, `xcodebuild ... ** TEST SUCCEEDED **`, engine re-testemunhou `outcome=pass, phase=6, exitCode=0` (2026-09-05T22:49Z hora local / 2026-09-06 UTC). 2ª chamada `advance_phase(target_phase=7)` → sucesso. Nenhuma alteração de código; nenhuma métrica fabricada.

**Ressalvas carregadas para a Fase 7** (dependências externas do ecossistema institucional, comuns à baseline Android, **não** defeitos do produto iOS): **EXT-DEP-02** (UC-3 formulário de inscrição — backend/Puppeteer), **EXT-DEP-03** (UC-9 push remoto do sistema iOS — Apple Developer Team / provisioning APNs institucional), **waiver UC-10** (entrega da notificação local não validada manualmente). `EXT-DEP-01` (arquivo `GoogleService-Info.plist`) resolvido 2026-09-05.

## 2026-09-06T04:12:00Z — ENCERRAMENTO DA METODOLOGIA (Fase 7 passo 4)

`get_phase_state` → `currentPhase: 7`. VA-human escolheu (via `AskUserQuestion`) **"Projeto completo — encerrar a metodologia"** — `start_new_cycle` **não** chamado. Decisão Versus **D0096** (process, id `b856d270-1e38-4e0b-93cb-9c9e1d944ce2`).

**Ciclo v1.0 do IACDM concluído — Fases 0→7.** Produto iOS **atende ao P0** com 3 ressalvas externas documentadas (`EXT-DEP-02`, `EXT-DEP-03`, waiver `UC-10`). Verificação final: 96 testes automatizados 0 falhas (engine-witnessed); 10/12 UCs PASS manual + UC-3 paridade; Package + App target `BUILD SUCCEEDED`. `check_all_safeguards()` na Fase 6 → 0 violações.

**Registro científico completo e preservado:** `RESEARCH_LOG.md` (P0001–P0048), `DECISIONS.md` (D0001–D0096), `GATES.md`, `METRICS/`, `PROMPT_LOG/`, `specs/` (incl. `references/lessons.md` com backlog v2.0).
