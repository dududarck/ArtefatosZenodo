# Arquitetura — ESJUD iOS (Fase 1)

> Aprovado pelo VA-human após uma rodada de correção de granularidade
> (P0005, ver `research/RESEARCH_LOG.md` e `research/DECISIONS.md`
> D0022–D0024). Este documento é a fonte canônica dos nomes de módulo
> usados pela matriz de cobertura da Fase 2 e pela implementação da
> Fase 5 — os nomes na coluna `module` não devem divergir em fases
> posteriores.

## Padrão arquitetural e princípios

- **Padrão:** Layered (presentation / domain / data), espelhando a
  separação já existente no Android de referência.
- **Princípios transversais:** SOLID, KISS+YAGNI, Composition over
  Inheritance. DDD explicitamente rejeitado (domínio não é rico o
  suficiente para justificar agregados/bounded contexts).
- **Concorrência:** Actor Model (Swift Concurrency — `async/await` +
  `actor`), idiomático no Swift 6.3 (confirmado em `research/ENVIRONMENT.md`).
- **Padrões de design:** GoF — Adapter (DTO→modelo em cada módulo de
  domínio) e Strategy (`AuthStrategy` em M-01; variação Servidor/
  Magistrado em M-07). Fowler — Domain Model leve (Nível de domínio);
  Repository + Data Mapper (acesso a dados).
- **Rede:** URLSession nativo (sem dependências de terceiros).

## V(1) — Módulos

| id | module | responsibility | interface | depends-on |
|---|---|---|---|---|
| M-01 | networking | Executor HTTP genérico, parametrizado por estratégia de autenticação por chamada — não conhece regras de domínio de nenhum backend específico | `execute<T>(request, auth: AuthStrategy) -> Result<T>`; `AuthStrategy = .none \| .moodleQueryToken \| .mTLSClient \| .apiKeyHeader(key)` | — |
| M-02 | persistence | Dois protocolos explicitamente separados — nunca dado sensível na store não segura | `SecureStore.save/load/clear(credential)` (Keychain); `LocalStore.save/load/clear(key)` (UserDefaults) | — |
| M-03 | auth | Login Moodle, sessão, logout com limpeza total de dados locais (A-6) | `login(user,pass) -> Session`; `logout()` | networking, persistence.SecureStore |
| M-04 | courses | Listar cursos, formulário de inscrição condicional por vínculo, confirmar inscrição | `list() -> [Course]`; `fetchForm(cpf) -> FormularioResult`; `enroll(profile) -> EnrollmentResult` | networking, auth |
| M-05 | certificates | Listar certificados por CPF, baixar PDF | `list(cpf) -> [Certificate]`; `download(cpf,index) -> Data` | networking, auth |
| M-06 | certidao | Gerar/validar/baixar certidão de cursos agregada | `generate(cpf,periodo) -> CertidaoGerada`; `validate(numero) -> ValidateResult` | networking, auth |
| M-07 | cert-ext | Obter pessoa por CPF, listar/registrar/excluir certificado externo (Servidor/Magistrado) | `obterPessoa(cpf,tipo)`; `listar(cpf,tipo)`; `registrar(...)`; `excluir(id,cpf,tipo)` | networking, auth |
| M-08 | moodle-web | Gerar URL de autologin no AVA Moodle | `autoLoginURL() -> URL` | networking, auth |
| M-09 | news | Listar notícias paginadas, ler matéria completa | `list(pagina) -> NoticiasPage`; `materia(url) -> MateriaCompleta` | networking |
| M-10 | admin-feed | Buscar/persistir feed de notificações administrativas; contador de não lidas | `fetchFeed()`; `unreadCount: Stream<Int>`; `markAllRead()` | networking, persistence.LocalStore |
| M-11 | push-transport | Ciclo de vida do token FCM, registro de dispositivo, recepção de push remoto (entrega ao admin-feed ou dispara notificação de sistema) | `registerDevice()`; `onTokenRefresh(token)`; `onRemoteMessage(payload)` | networking, persistence.LocalStore, admin-feed |
| M-12 | course-reminders | Rastrear cursos inscritos localmente; agendar/atualizar notificações locais por data de fim do curso | `trackEnrollment(course)`; `scheduleReminders()`; `prune()` | persistence.LocalStore |
| M-13 | app-shell | Entrada do app, `NavigationStack` raiz, composição/injeção de dependências | compõe todos os módulos de domínio | M-03..M-12 |
| M-14 | auth-ui | Tela de Login | — | auth |
| M-15 | home-ui | Menu de serviços, saudação, prévia de notícias, sino de notificações | — | courses, certificates, certidao, cert-ext, moodle-web, news, admin-feed |
| M-16 | courses-ui | Lista de cursos + formulário de inscrição | — | courses |
| M-17 | certificates-ui | Lista de certificados + download | — | certificates |
| M-18 | certidao-ui | Geração/validação de certidão | — | certidao |
| M-19 | cert-ext-ui | Fluxo Servidor/Magistrado de certificado externo | — | cert-ext |
| M-20 | moodle-web-ui | Estado de loading/erro + abertura do navegador embutido (SFSafariViewController) | — | moodle-web |
| M-21 | news-ui | Lista de notícias + matéria completa | — | news |
| M-22 | notifications-ui | Lista de notificações dentro do app | — | admin-feed, course-reminders |

## Premissas numeradas

- **A-1.** Os 5 backends institucionais (Moodle, ESJUD, Certidão,
  Certificados Externos, Painel) são contratos fixos e imutáveis
  durante este estudo (D0012) — nenhuma mudança de backend está no
  escopo do produto iOS.
- **A-2.** O certificado cliente mTLS (`.p12`) pode ser embutido no
  bundle do app iOS, da mesma forma que no Android (D0014).
- **A-3.** O backend `painel-web` aceita `platform: "ios"` no registro
  de dispositivo e envia push via Firebase Admin SDK de forma agnóstica
  de plataforma — verificado por leitura de código-fonte
  (`painel-web/src/lib/devicesRepo.js`, `push.js`), não presumido
  (D0021).
- **A-4.** A ausência de bloco `apns` explícito no payload de push do
  `painel-web` não impede a entrega da notificação ao Firebase SDK para
  iOS com comportamento padrão (D0021) — apenas limita nuances finas de
  exibição (badge/som customizado).
- **A-5.** iOS não garante execução periódica confiável em segundo
  plano equivalente ao WorkManager do Android; a estratégia adotada
  (M-12) é agendar notificações locais por data específica em vez de
  recalcular tudo periodicamente.
- **A-6.** O logout no iOS limpa todos os dados locais do usuário
  (sessão, cursos inscritos, notificações administrativas) — diverge
  deliberadamente do comportamento observado no Android (D0017).
- **A-7.** A sessão do usuário não expira localmente por tempo — apenas
  por logout manual ou falha de autenticação numa chamada de API
  (D0016), replicando o comportamento do Android.
- **A-8.** A chave de API do Painel (`X-Api-Key`) é tratada como
  segredo de baixo risco e pode ser embutida no cliente iOS (D0015).

## Negative scope (o que o sistema deliberadamente NÃO faz)

- Não implementa a funcionalidade "Cronograma de cursos/eventos"
  (ausente do Android atual — D0009).
- Não modifica nenhum dos 5 backends institucionais (A-1/D0012).
- Não espelha visualmente o Material3 do Android — segue Apple Human
  Interface Guidelines, usando as telas Android apenas como referência
  funcional (D0019).
- Não implementa expiração de sessão local nova (A-7).
- Não introduz autenticação federada/SSO além do fluxo Moodle existente.
- Não introduz banco de dados relacional local (Room/SQLite-equivalente)
  — persistência local via Keychain/UserDefaults, espelhando a
  simplicidade já usada no Android (DataStore, sem Room).

## Resolução dos achados da Fase 2 (V(1) → V(2))

Resposta unificada da Fase 3 aos 35 achados de `specs/design/coverage-matrix.md`,
Iteração 1. Resumo completo com justificativa por achado apresentado em
chat nesta sessão (Fase 3) e espelhado em `research/RESEARCH_LOG.md`.
Todos os 8 críticos foram resolvidos por mudança de contrato/interface
ou pela adição do módulo M-23 (infraestrutura, não feature). Dos 21
importantes, 13 foram resolvidos por refinamento de interface e 8 foram
aceitos explicitamente com justificativa (KISS/YAGNI, escala atual,
detalhe de Fase 5, ou responsabilidade herdada de contrato externo fixo).
Os 6 achados 🟢 (sugestão) ficam adiados para uma v2.0 fora deste ciclo.

## V(2) — Módulos (completo — substitui V(1) como versão corrente)

| id | module | responsibility | interface | depends-on |
|---|---|---|---|---|
| M-01 | networking | Executor HTTP genérico parametrizado por estratégia de autenticação e timeout por chamada; não conhece regras de domínio | `execute<T>(request, auth: AuthStrategy, timeout: TimeInterval) -> Result<T, NetworkError>`; `AuthStrategy = .none \| .moodleQueryToken \| .mTLSClient \| .apiKeyHeader(key)`; `NetworkError` inclui caso `.certificateUnavailable` distinto de erro HTTP genérico (resolve RS-03) | — |
| M-02 | persistence | `SecureStore` (Keychain, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, aceita apenas o tipo `Credential`) e `LocalStore` (UserDefaults, genérico `<T: Codable>`) — tipos distintos impedem uso cruzado em tempo de compilação (resolve AR-03) | `SecureStore.save/load/clear(_ credential: Credential)`; `LocalStore.save/load/clear<T: Codable>(_ value: T, forKey:)` | — |
| M-03 | auth | Login Moodle (inspeciona corpo mesmo em HTTP 200 para detectar erro de domínio — resolve AS-01), sessão, logout com limpeza total (A-6) | `login(user,pass) -> Result<Session, AuthError>`; `logout()` | networking, persistence.SecureStore |
| M-04 | courses | Listar cursos, formulário de inscrição condicional por vínculo, confirmar inscrição; mapeamento explícito HTTP 409→JaInscrito, 422→Indisponivel, 500→Erro (resolve PW-02); timeout estendido (15s) para `fetchForm` (Puppeteer-backed) | `list() -> [Course]`; `fetchForm(cpf) -> FormularioResult` onde `FormularioResult = .sucesso(Formulario) \| .jaInscrito(msg) \| .indisponivel(msg) \| .erro(msg)`; `enroll(profile) -> EnrollmentResult` onde `EnrollmentResult = .sucesso(msg) \| .jaInscrito(msg) \| .falha(msg) \| .erro(msg)` | networking, auth |
| M-05 | certificates | Listar certificados por CPF, baixar PDF | `list(cpf) -> [Certificate]`; `download(cpf,index) -> Data` | networking, auth |
| M-06 | certidao | Gerar/validar/baixar certidão; campo `period` modelado como enum `Period` com `Encodable` customizado cobrindo as duas formas de fio da API — número (retroativo) ou string (ano/mês) (resolve LG-01) | `generate(cpf, period: Period) -> CertidaoGerada`; `validate(numero) -> ValidateResult` | networking, auth |
| M-07 | cert-ext | Obter pessoa, listar/registrar/excluir certificado externo; validação de tamanho/tipo de PDF antes do upload (resolve SE-03); `enum CertificateStatus` cobre todos os valores conhecidos de `idSituacao` + caso `.unknown(raw)` (resolve PW-01); confirmação explícita de registro (resolve ET-01) | `obterPessoa(cpf,tipo)`; `listar(cpf,tipo) -> [CertExtItem]` (com `status: CertificateStatus`); `registrar(nomePessoa, cpf, nomeCurso, cargaHoraria, nomeInstituicao, arquivo: PDFAttachment, nomeAtuacao: String?, nomePeriodo: String?) -> Result<.confirmed(receiptId), CertExtError>`; `excluir(id,cpf,tipo)` | networking, auth |
| M-08 | moodle-web | Gerar URL de autologin no AVA Moodle | `autoLoginURL() -> URL` | networking, auth |
| M-09 | news | Listar notícias paginadas, ler matéria completa; timeout estendido (15s, Puppeteer-backed) | `list(pagina) -> NoticiasPage`; `materia(url) -> MateriaCompleta` | networking |
| M-10 | admin-feed | Buscar/persistir feed administrativo; `receive(external:)` distinto de `fetchFeed()` para conteúdo entregue via push, com dedup por id (resolve AR-02/PW-03); `pollIfStale(maxAge:)` chamado ao trazer o app para primeiro plano (resolve RS-02) | `fetchFeed()`; `receive(external: AdminNotification)`; `pollIfStale(maxAge: TimeInterval)`; `unreadCount: Stream<Int>`; `markAllRead()` | networking, persistence.LocalStore |
| M-11 | push-transport | Ciclo de vida do token FCM; falha de init do Firebase degrada para modo somente-feed (resolve AS-02); allowlist de domínio (`*.tjac.jus.br`) antes de abrir `actionUrl` (resolve SE-04); loga tentativas de entrega via diagnostics (resolve OB-02); SDK Firebase fixado por faixa de versão major via SPM (resolve MEC-02) | `registerDevice() -> Result<Void, PushError>`; `onTokenRefresh(token)`; `onRemoteMessage(payload)` | networking, persistence.LocalStore, admin-feed, diagnostics |
| M-12 | course-reminders | Rastrear cursos inscritos; agendar notificações locais com cap de 50 pendentes, reagendadas a cada abertura do app (resolve AS-03) | `trackEnrollment(course)`; `scheduleReminders()`; `prune()` | persistence.LocalStore |
| M-13 | app-shell | Entrada do app, `NavigationStack` raiz, composição/injeção de dependências; chama `admin-feed.pollIfStale()` ao voltar ao primeiro plano | compõe todos os módulos de domínio | M-03..M-12, M-23 |
| M-14 | auth-ui | Tela de Login | — | auth |
| M-15 | home-ui | Menu de serviços, saudação, prévia de notícias, sino de notificações (fan-in aceito — mesma forma do Android) | — | courses, certificates, certidao, cert-ext, moodle-web, news, admin-feed |
| M-16 | courses-ui | Lista de cursos + formulário de inscrição; estado de loading/cancelamento explícito para chamadas longas (resolve UX-01) | — | courses |
| M-17 | certificates-ui | Lista de certificados + download | — | certificates |
| M-18 | certidao-ui | Geração/validação de certidão | — | certidao |
| M-19 | cert-ext-ui | Fluxo Servidor/Magistrado; estado preservado pelo view model retido por app-shell durante seleção de arquivo (A-10, resolve UX-02) | — | cert-ext |
| M-20 | moodle-web-ui | Estado de loading/erro + abertura do navegador embutido | — | moodle-web |
| M-21 | news-ui | Lista de notícias + matéria completa | — | news |
| M-22 | notifications-ui | Lista de notificações dentro do app | — | admin-feed, course-reminders |
| M-23 | diagnostics | Fachada fina de log estruturado por módulo sobre `os_log`/`Logger` nativo (zero dependência nova) — permite diagnóstico em produção sem alteração de código (resolve OB-01) | `log(category: Module, level: LogLevel, message: String)` | — |

**Mudança estrutural V(1)→V(2):** 1 módulo adicionado (M-23), 0 removidos, 0 com limites/dependências redesenhados — os demais 33 achados foram resolvidos por refinamento de interface dentro dos módulos já existentes, não por reestruturação de fronteiras.

## Premissas numeradas (V(2) — acrescenta A-9, A-10, A-11 às 8 de V(1))

- **A-9.** O backend garante que uma busca por CPF na API de Certificados
  Externos retorna uma pessoa única/inequívoca (AS-04, aceito).
- **A-10.** A preservação de estado padrão do SwiftUI (view model retido
  pela navegação de app-shell) é suficiente para sobreviver à suspensão
  do app durante a seleção de arquivo PDF (UX-02, aceito).
- **A-11.** Validação de trust do servidor via mecanismo padrão do SO
  (sem certificate pinning adicional) é aceita como suficiente para o
  perfil de risco deste produto (SE-02, aceito com justificativa
  KISS/YAGNI) — risco residual de MITM com CA comprometida na cadeia do
  dispositivo, considerado aceitável e não exclusivo deste app.

## Rastreabilidade

Cada módulo de domínio/dados corresponde a uma responsabilidade já
evidenciada na baseline Android (repositório, DataStore, ou serviço
distinto) — ver `specs/references/rastreabilidade-baseline.md` e
`specs/technical/integracao-apis.md`/`persistencia-e-dados-locais.md`
para as referências originais de arquivo.

---

## Fase 7 (Post-Review) — decisões finais da implementação e resultados reais

> Consolidação dos ajustes técnicos decididos durante as Fases 5–6
> (`research/DECISIONS.md` D0025–D0094). Nenhuma fronteira de módulo de
> V(2) mudou; todos os itens abaixo são refinamentos internos ou
> escolhas de integração.

### Integração do Firebase (push) — XCFrameworks manuais (D0045–D0050)

- **Descartado:** Firebase iOS via SPM. O caminho SPM **reproduzivelmente**
  derruba o Xcode/`xcodebuild` com `IDESwiftPackageCore` neste projeto
  (pacote local + app target com `project.pbxproj` autoral). Registrado
  em D0045/D0046.
- **Adotado (Opção A, D0050):** 8 XCFrameworks pré-compilados em
  `AppShell/ESJUDApp/Frameworks/` (FBLPromises, FirebaseCore,
  FirebaseCoreInternal, FirebaseInstallations, FirebaseMessaging,
  GoogleDataTransport, GoogleUtilities, nanopb), fase *Embed Frameworks*,
  `-ObjC`/`-lc++` em `OTHER_LDFLAGS`.
- **`FirebaseMessagingBridge.swift`** (`AppDelegate`) é o **único** ponto
  que fala com o SDK; traduz callbacks do Firebase para o M-11
  (`PushTransportRepository`) via `RemoteMessagePayload` — tipo agnóstico
  de SDK. O módulo de domínio M-11 **não** importa Firebase.

### mTLS — `.p12` e isolamento de sessão (D0055, D0058)

- O `.p12` institucional original tinha **senha vazia**, que
  `SecPKCS12Import` **rejeita**. Solução: re-encodar o `.p12` com
  [criptografia moderna] + senha não-vazia embutida no bundle (D0055). Não é uma
  mudança de credencial — é o mesmo par de chaves, só re-empacotado.
- HTTP/2 **connection coalescing** entre hosts que resolvem para o mesmo
  IP causava **HTTP 421 Misdirected Request**. Solução: `URLSession`
  isolada por host (`sessionsByHost` em M-01), impedindo o reuso de
  conexão TLS entre hosts distintos (D0058).

### SwiftUI — identidade de ViewModel e máquina de estados (D0081, D0082)

- **`@State` obrigatório** para ViewModels construídos dentro do closure
  de `navigationDestination` — sem ele, uma recomposição do ancestral
  (ex.: `scenePhase`) recria a instância e cancela a `Task` em voo
  (`-999`), produzindo "loading infinito sem erro" (D0081).
- **Máquina de estados explícita** na `EnrollmentScreen.body`: `.idle`
  estável (mostra entrada de CPF, saída pelo botão) separado de
  `.loading` (só enquanto há operação real). Todo caminho para
  `.loading` tem saída garantida para estado terminal (D0082/VAL-45).
  Premissa **A-10** (preservação de estado padrão do SwiftUI suficiente)
  **revista na prática**: só é verdadeira com `@State` explícito.

### Notificações — FCM/APNs de ponta a ponta (D0088–D0094)

- `GoogleService-Info.plist` institucional real integrado ao bundle
  (Copy Bundle Resources), `EXT-DEP-01` resolvido em 2026-09-05.
- `ESJUDApp.entitlements` com `aps-environment` + `UIBackgroundModes`
  `remote-notification` via `Info.plist` parcial (merge com
  `GENERATE_INFOPLIST_FILE=YES`). **Achado:** sob assinatura ad-hoc
  ("Sign to Run Locally", sem *team*) o Xcode reduz o `.xcent` a
  **vazio** — `aps-environment` só vale com assinatura institucional.
- Contrato de registro de dispositivo reproduzido do Android
  (`PainelRepository.registerDevice` → `POST api/public/register-device`,
  corpo `{token, platform:"ios", userId, username, fullName}`,
  `X-Api-Key`); token FCM salvo em `LocalStore` (`device_push_token`),
  UUID de fallback antes do FCM — espelha `getOrCreateDeviceToken()`.
- **Divergência deliberada do Android:** o *tap* numa push leva à tela de
  Notificações do app (não abre `actionUrl` no navegador) — evita
  duplicar o allowlist `tjac.jus.br` no app-shell e reduz open-redirect.
- Evidência de token em log é **sanitizada e não reversível**
  (`PushTokenEvidence.fingerprint` = comprimento + SHA-256[0..4]).

### Dependências externas do ecossistema (não são defeitos do produto iOS)

- **EXT-DEP-02** — `GET /[endpoint-formulario-inscricao]` retorna HTTP 422
  `FORM_UNAVAILABLE "etapa: timeout"` determinístico para a maioria dos
  cursos (Puppeteer server-side do backend). Reproduzido por `curl`
  mTLS; **confirmado indisponível também na baseline Android**. Backend
  é contrato fixo (D0012). Cliente iOS verificado correto e em paridade.
- **EXT-DEP-03** — validação de *runtime* do push remoto real bloqueada
  por falta de Apple Developer Team institucional do TJAC (App ID com
  Push + provisioning com `aps-environment` + APNs Auth Key `.p8` no
  Firebase Console). Integração de cliente concluída e verificada por
  build/teste.
- **Waiver UC-10** — a entrega efetiva da notificação **local** de
  lembrete não foi validada manualmente em runtime; aceita por decisão
  do VA-human (D0094) na força de VAL-34–38 + paridade Tier-2.

### Verificação final (Fase 6)

`xcodebuild test -scheme ESJUDAC-Package` → **96 testes, 0 falhas**,
`** TEST SUCCEEDED **`, run verde testemunhado pelo engine Versus
(`VERSUS_TEST_EXIT=0`). Package build e App target
(`AppShell/ESJUDApp.xcodeproj`) build → `** BUILD SUCCEEDED **`.
