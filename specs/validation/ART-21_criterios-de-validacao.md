# Critérios de Validação — ESJUD iOS (Fase 6)

> Fonte de verdade para o Test Map da Fase 6. Derivado de: casos de uso
> da Fase 0 (`get_decisions(phase=0)` / D0001, D0009, D0016–D0019),
> `specs/technical/architecture.md` V(2) (premissas A-1..A-11,
> resoluções de achados críticos), `specs/technical/integracao-apis.md`
> e `specs/technical/comportamentos-especificos-android.md`.
>
> Cada critério declara: **o que** deve ser verdadeiro, **por que**
> (rastreabilidade), e **como** é verificável nesta Fase 6 —
> distinguindo o que é testável por XCTest unit (rede mockada via
> `URLProtocol` stub, sem credenciais reais de backend) do que só é
> verificável por teste manual exploratório do VA-human.

## Casos de uso da Fase 0 (Delivery Target = produto completo, D0001)

| id | Caso de uso (fluxo do app Android replicado) | Passada exploratória manual Fase 6 |
|---|---|---|
| UC-1  | Login Moodle (usuário/senha → token de sessão) | **PASS manual** (P0044/D0085) |
| UC-2  | Listar cursos com inscrição aberta | **PASS manual** (P0043/D0084) |
| UC-3  | Inscrição em curso (formulário condicional por vínculo + confirmação) | Cliente correto / **paridade com a baseline**; funcionalidade absoluta bloqueada por **EXT-DEP-02** (P0041/P0043/D0084) — não é FAIL do cliente |
| UC-4  | Listar certificados por CPF + baixar PDF | **PASS manual** (listagem+download+abertura) (P0043/D0084) |
| UC-5  | Certidão de cursos: gerar / validar / baixar PDF | **PASS manual** (geração+Abrir PDF+Compartilhar+Validar) (P0044/D0086) |
| UC-6  | Certificado externo (Servidor/Magistrado): obter pessoa, listar, registrar, excluir | B5 FAIL manual → corrigido (seletor Servidor/Magistrado, VAL-47) → **reteste B5-B10 PASS manual** (P0044/D0086/D0087) |
| UC-7  | Acesso ao AVA Moodle (autologin no navegador embutido) | **PASS manual** (BLOCO C, P0046/D0090; relato do VA-human) |
| UC-8  | Notícias: listar paginado + ler matéria completa | **PASS manual** (BLOCO C, P0046/D0090; relato do VA-human) |
| UC-9  | Notificações administrativas: receber / listar / polling / badge / marcar como lidas · **+ push remoto APNs/FCM** | **PASS manual** (execução humana real, P0046/D0090 + P0047/D0092–D0093): feed / listagem / polling `/api/public/feed` / badge / marcar como lidas **e o recebimento da notificação dentro do app** (aviso enviado → aparece na lista via feed/polling). **Pendência exclusiva — push remoto do sistema iOS (APNs/FCM)**: banner na Central de Notificações, recebimento com app em background/encerrado, tap no push abrindo o app/tela → **implementação concluída / validação runtime pendente** por `EXT-DEP-03` (P0045/D0088; sem Apple Developer Team institucional do TJAC → `aps-environment` não entra no provisioning). Cliente verificado por build/teste (plist real no bundle, `FirebaseApp.configure()` com config real, autorização + APNs + token FCM/APNs sanitizado + re-registro de device + handlers foreground/background/tap, `UIBackgroundModes remote-notification`, 96 testes verdes). **Não é FAIL do cliente.** `EXT-DEP-01` (plist) desbloqueado 2026-09-05. |
| UC-10 | Lembretes de curso (notificações locais por data de fim) | **Aceito com WAIVER EXPLÍCITO do VA-human** (P0048/D0094) — **não** PASS manual. Lógica de domínio coberta por teste automatizado (VAL-34..VAL-38) + porte Tier-2 fiel do Android + ausência de evidência de divergência do cliente. A entrega efetiva da notificação **local** em runtime (`UNUserNotificationCenter.add` em `scenePhase==.active`) não foi validada manualmente. |
| UC-11 | Logout com limpeza total de dados locais (D0017/A-6) | **PASS manual** (P0044/D0085) |
| UC-12 | Restauração de sessão entre reaberturas do app (sem expiração local, D0016/A-7) | **PASS manual** (P0044/D0085) |

## Critérios de validação

### Autenticação e sessão

- **VAL-1 (UC-1, AS-01).** O login trata sucesso e falha que chegam
  ambos com **HTTP 200** (padrão Moodle): a decisão vem da inspeção do
  corpo (`token` presente e não vazio → sucesso; `error`/`errorcode` →
  `AuthError.invalidCredentials` com a mensagem do backend), nunca do
  código HTTP.
  *Verificável por:* XCTest unit (stub devolve corpo Moodle de sucesso e
  de erro, ambos com status 200).
- **VAL-2 (UC-1).** Falha de perfil (`core_webservice_get_site_info`)
  **não** impede o login — a sessão é retornada com `username` = o
  informado e campos de perfil vazios (mesma semântica da baseline
  Android `runCatching{...}.getOrNull()`).
  *Verificável por:* XCTest unit (stub: token OK, site-info devolve erro
  de rede/JSON inválido).
- **VAL-3 (UC-12, A-7).** `currentSession()` reconstrói a sessão a
  partir de `LocalStore` (metadados não sensíveis + conta atual) +
  `SecureStore` (token). Retorna `nil` — nunca lança — se qualquer peça
  estiver ausente.
  *Verificável por:* XCTest unit parcial (caminho `nil` com stores
  vazios; caminho positivo depende de Keychain, coberto por teste
  manual — ver VAL-4).
- **VAL-4 (UC-12).** Fluxo real login → fechar → reabrir → continua
  logado (passos A–D do roteiro de P0029).
  *Verificável por:* **teste manual** (exige Keychain real + credenciais
  reais). Já confirmado PASS em D0071/D0073; a Fase 6 re-executa como
  parte da passada exploratória dedicada.
- **VAL-5 (UC-11, A-6/D0017).** `logout()` limpa o token do Keychain
  (conta lida do `LocalStore`, não exigida como parâmetro) **e** as duas
  chaves de `LocalStore` (`auth.currentAccount`, `auth.sessionMeta`).
  Após logout, `currentSession()` devolve `nil`.
  *Verificável por:* XCTest unit (com `LocalStore` de suíte isolada) +
  **teste manual** para a parte Keychain (passos E–G de P0029, PASS em
  D0073).
- **VAL-6 (UC-11).** Divergência deliberada da baseline: a senha do
  usuário **nunca** é persistida (nem Keychain, nem UserDefaults) —
  apenas o token (Keychain) e metadados não sensíveis (UserDefaults).
  `PersistedSessionMeta` não contém `token` nem `password`.
  *Verificável por:* XCTest unit (inspeção de que `PersistedSessionMeta`
  codificado não contém o segredo) + revisão de código.

### Rede / M-01 (executor HTTP genérico)

- **VAL-7 (RS-03).** `AuthStrategy.mTLSClient` sem `CertificateProviding`
  injetado ⇒ `NetworkError.certificateUnavailable` **distinto** de
  qualquer erro HTTP — a requisição nem chega a ser disparada (resolve a
  degradação silenciosa da baseline Android, `NetworkModule.kt`).
  *Verificável por:* XCTest unit (sem stub necessário — curto-circuito).
- **VAL-8 (A-8/D0015).** `AuthStrategy.apiKeyHeader(k)` injeta o header
  `X-Api-Key: k` na requisição; `.none` não injeta header de auth
  algum; `.moodleQueryToken` não é aplicado como header (o token vai na
  query string do chamador).
  *Verificável por:* XCTest unit (`URLProtocol` stub captura a request e
  inspeciona headers).
- **VAL-9.** Resposta com status fora de 200..<300 ⇒
  `NetworkError.httpStatus(code, body)` preservando o corpo; corpo que
  não decodifica no tipo esperado ⇒ `NetworkError.decoding(...)`; falha
  de transporte ⇒ `NetworkError.transport(...)`.
  *Verificável por:* XCTest unit (stub).
- **VAL-10 (timeout).** O `timeout` por chamada é repassado ao
  `URLRequest` (30s padrão; 15s em chamadas de perfil/validação; 30s
  explícito em endpoints Puppeteer-backed).
  *Verificável por:* XCTest unit (stub inspeciona `timeoutInterval`) —
  cobertura parcial (verifica repasse, não o disparo real do timeout).

### Cursos e inscrição (UC-2, UC-3)

> **Reavaliação por paridade com a baseline (P0043, 2026-09-06).**
> **UC-2 (listar cursos):** funcional no iOS e no Android — **PARIDADE,
> PASS manual.** **UC-3 (formulário de inscrição):** o cliente iOS está
> **verificado como correto** (VAL-12/41/42/43/44/45 + P0040: máquina de
> estados sem loading infinito, sempre com saída; requisição idêntica à
> baseline Android e ao `curl` — CPF de 11 dígitos crus, este endpoint
> não usa máscara). A **funcionalidade absoluta está bloqueada por
> `EXT-DEP-02`**: `GET /[endpoint-formulario-inscricao]` retorna HTTP 422
> `FORM_UNAVAILABLE "etapa: timeout"` de forma **determinística** para a
> maioria dos cursos (Puppeteer server-side do backend estourando o
> próprio tempo; confirmado por `curl` em P0041 e pela **mesma
> indisponibilidade na baseline Android**, validada pelo VA-human em
> P0043). Backend é contrato fixo (D0012). **UC-3 não é FAIL do
> cliente** — paridade com a baseline mantida; dependência externa
> registrada separadamente (ver §"Dependências externas").

- **VAL-11 (UC-2).** `CursoApiItem.toCourse()` remove o prefixo
  `"Curso: "` e o sufixo `"."` do campo `curso`, e usa `periodo` como
  `dataAtividade` quando este vem vazio — mesma limpeza da baseline
  (`CourseRepository.kt`).
  *Verificável por:* XCTest unit (função pura, `@testable`).
- **VAL-12 (UC-3, PW-02).** `fetchForm` mapeia explicitamente
  **HTTP 409 → `.jaInscrito`**, **422 → `.indisponivel`**, qualquer
  outra falha → `.erro`, extraindo a `message` do corpo JSON quando
  presente (fallback para texto padrão).
  *Verificável por:* XCTest unit (stub devolve 409/422/500 com e sem
  campo `message`).
- **VAL-13 (UC-3, PW-02).** `enroll` mapeia **HTTP 409 → `.jaInscrito`**;
  resposta 200 com `success:false` → `.falha(message)`; `success:true`
  → `.sucesso(message)`; falha de transporte → `.erro`.
  *Verificável por:* XCTest unit (stub).
- **VAL-14 (UC-3).** `EnrollmentProfile` default: `vinculo = "N"` e os
  demais campos vazios — replicando o default do formulário Android.
  *Verificável por:* XCTest unit (init com defaults).
- **VAL-41 (UC-3, P0033 — achado adversarial da Fase 6).** O fluxo de
  inscrição **captura e valida o CPF** antes de chamar o backend:
  `EnrollmentViewModel.loadForm()` com `cpfDigits` de menos de 11
  dígitos ⇒ `formState = .erro(...)` **sem** fazer nenhuma chamada de
  rede; com 11 dígitos ⇒ chama `fetchForm(cpf:)` e, em `.sucesso`,
  invoca `persistCPF(cpfDigits)`. `sanitizeCPF()` mantém só dígitos,
  máx. 11. Espelha `CpfInputDialog` + guard de `CoursesViewModel.inscrever()`
  + `authRepository.saveCpf()` da baseline Android.
  *Verificável por:* XCTest unit (`@MainActor`, `CoursesUI`) — caminho
  inválido não incrementa `StubURLProtocol.requestCount`; caminho válido
  carrega o formulário e persiste.
- **VAL-42 (UC-3, P0033).** `CourseRepository.fetchForm` em falha HTTP
  que **não** seja 409/422 (ex.: 400 "parâmetros obrigatórios") expõe a
  `message` do corpo quando presente.
  *Verificável por:* XCTest unit (stub devolve 400 com `message`).
- **VAL-43 (UC-3, P0035 — observabilidade).** `fetchForm` **não colapsa**
  `NetworkError` numa única mensagem: cada modo de falha vira uma
  mensagem distinta e **segura** (sem CPF/PII, sem payload/URL bruta) —
  `.invalidURL`, `.certificateUnavailable`, `.transport` (identifica
  timeout/conexão + resumo `domain/code`), `.decoding` (identifica
  "formato inesperado", sem despejar o corpo), `.httpStatus` (nomeia o
  código + `message` operacional do backend). Complementar: o resumo que
  `NetworkClient` coloca em `NetworkError.transport` é só `domain code=N`
  — nunca `String(describing:)`/`localizedDescription` (que embutem a
  URL com o parâmetro `cpf`); `logTransportError` não loga mais
  `userInfo`.
  *Verificável por:* XCTest unit — `CoursesTests` (5 modos, cada um
  nomeado; asserções negativas de que o CPF/query/URL não aparecem) +
  `NetworkingTests` (`transportSummary` seguro).
- **VAL-44 (UC-3, P0039).** Dentro do modo `.transport`, cancelamento
  (`NSURLErrorCancelled`, `code=-999`) é **distinguido** de timeout —
  mensagem própria ("cancelado... toque novamente"), nunca "tempo
  limite excedido". Evita mascarar um cancelamento de lifecycle de UI
  como se fosse lentidão de rede.
  *Verificável por:* XCTest unit (`CoursesTests`, stub com
  `URLError(.cancelled)`).
- **VAL-45 (UC-3, P0040 — CAUSA RAIZ do "loading infinito").**
  Máquina de estados do formulário de inscrição: `formState` começa
  `.idle`; **completar o CPF (11 dígitos) NÃO altera `formState` nem
  liga o indicador de carregamento** (`isLoadingForm == formState ==
  .loading`, nunca derivado de `hasValidCPF`); só `loadForm()` entra em
  `.loading`, e **toda** passagem por `loadForm()` sai de `.loading`
  para um estado terminal (`.loaded` / `.jaInscrito` / `.indisponivel`
  / `.erro`) — os 4 desfechos de `FormularioResult` + os dois `guard`
  (urlFragment nil, CPF inválido). Não existe caminho que deixe a tela
  em carregamento sem uma operação real em andamento e sem saída.
  *Verificável por:* XCTest unit (`EnrollmentViewModelTests`:
  `test_valid_cpf_alone_does_not_enter_loading`,
  `test_loadForm_always_exits_loading_to_terminal_state`). **O `body`
  da `EnrollmentScreen` em si (SwiftUI View) não é coberto por teste
  unitário** — decisão de escopo P0032 (sem automação de UI); a
  invariante testada trava o contrato do ViewModel do qual o `body`
  corrigido depende.

### Certificados (UC-4)

> **Validação manual (P0043, 2026-09-06):** reteste manual real do
> VA-human após a correção P0042/D0083 — **listagem PASS, download PASS,
> abertura/visualização do PDF PASS. UC-4 = PASS manual.**

- **VAL-46 (UC-4, P0042 — CAUSA RAIZ de "parece baixar vários / nenhum
  PDF abre").** O estado de download é **por índice de certificado**
  (`CertificatesViewModel.downloadStates[index]` / `downloadState(for:)`)
  — tocar em um item nunca altera o estado visual de outro. O download
  bem-sucedido **salva** os bytes em `Documents/certificados/<nome>.pdf`
  (arquivo real, extensão `.pdf`, tamanho == bytes recebidos, **CPF não
  vai no nome**), expõe a URL (`downloadedURLs[index]`, usada por
  "Abrir PDF" + `ShareLink`) e define `lastDownloaded` (identidade nova
  a cada sucesso → a tela abre o QuickLook automaticamente). Falha de
  rede/save ⇒ `.failed` só naquele item, sem URL, sem abrir preview.
  Novo `load()` limpa os estados da lista anterior.
  *Verificável por:* XCTest unit (`CertificatesViewModelTests`, 4
  testes). **A apresentação em si (QuickLook/`ShareLink` na View)** não
  é coberta por unit test — escopo P0032 (sem automação de UI); os
  testes travam o contrato do ViewModel (URL de arquivo válida e
  existente, estado por item) do qual a apresentação depende.
- **VAL-15 (UC-4, D0066).** O modelo `Certificate` decodifica a
  **resposta real de produção** (`GET /api/certificados/{cpf}`) — 15
  itens, cada um só com `index`/`tipo`/`periodo`/`atividade`, **sem**
  campo `pessoa` — sem `keyNotFound`.
  *Verificável por:* XCTest unit contra o fixture
  `certificados-producao-real.json` (amostra real registrada em
  D0065/D0066).
- **VAL-16 (UC-4).** `download(cpf,index)` devolve os bytes crus do PDF
  (via `executeRaw`); falha de rede → `CertificateError.network`.
  *Verificável por:* XCTest unit (stub devolve `%PDF-...` bytes).

### Certidão de cursos (UC-5)

- **VAL-17 (UC-5, LG-01).** `Period` codifica as três formas do contrato
  polimórfico da API: `.retroativo(meses:)` → número JSON;
  `.ano("2025")` → string `"2025"`; `.mes(ano:"2025",mes:"03")` → string
  `"2025-03"`. O corpo de `generate` é
  `{"cpf": "...", "period": <número|string>}`.
  *Verificável por:* XCTest unit (encode + inspeção do JSON resultante).
- **VAL-18 (UC-5).** `generate` extrai os metadados dos headers HTTP da
  resposta binária: `X-Certificate-Number`, `X-Person-Name`,
  `X-Total-Courses` (Int), `X-Total-Hours` (Double); ausência de header
  ⇒ campo `nil`.
  *Verificável por:* XCTest unit (stub `executeRaw` com/sem headers).
- **VAL-19 (UC-5).** `validate(numero)` decodifica
  `{success, valida, certificateNumber?, message?}`.
  *Verificável por:* XCTest unit (stub).

### Certificado externo (UC-6)

- **VAL-47 (UC-6, P0044 — lacuna de paridade B5 FAIL manual, corrigida).**
  Ao abrir "Certificado Externo" na Home, o app apresenta uma seleção
  explícita **Servidor / Magistrado** (`.confirmationDialog` nativo em
  `HomeScreen`), espelhando o `showTipoDialog` da baseline Android —
  antes o iOS entrava direto em Servidor e o modo Magistrado era
  inalcançável. A escolha roteia `Route.certExt(.servidor|.magistrado)`;
  o `CertExtViewModel` já é criado com o `tipo` correto e usa o prefixo
  de rota certo (`registro-certificados-externos` vs `vida-funcional`);
  `submit()` só envia `nome_atuacao` / `nome_periodo` quando
  `tipo == .magistrado` (gate por tipo no ViewModel **e** no
  Repository). A `CertExtScreen` já renderiza os campos extras
  Atuação/Período para `.magistrado`.
  *Verificável por:* XCTest unit — `CertExtViewModelTests` (tipo fixo
  por instância; Magistrado envia atuação/período + rota
  `vida-funcional`; Servidor omite mesmo com campos preenchidos + rota
  de servidor) + `CertExtTests.test_registrar_magistrado_fields_gated_by_tipo`
  + `test_route_prefix_depends_on_tipo`. **O `.confirmationDialog` em si
  (SwiftUI)** não é coberto por unit test — escopo P0032.


- **VAL-20 (UC-6, D0067).** `formattedCPF(_:)` produz sempre
  `000.000.000-00`: a partir de 11 dígitos crus, de um CPF já
  mascarado, ou de entrada com ruído/espaços. Aplicado nos **4** pontos
  de rede do módulo (`obterPessoa`, `listar`, `registrar`, `excluir`).
  *Verificável por:* XCTest unit (função pura `@testable` + inspeção da
  query/-body das 4 chamadas via stub).
- **VAL-21 (UC-6, PW-01).** `CertificateStatus(rawValue:)`: `1 →
  .emAnalise` (com `podeExcluir == true`); **qualquer** outro inteiro →
  `.unknown(n)` (com `podeExcluir == false`) — nunca inventa
  `.aprovado`/`.rejeitado` sem evidência.
  *Verificável por:* XCTest unit (função pura).
- **VAL-22 (UC-6).** `CertExtItem` (Decodable custom) tolera campos
  ausentes com defaults seguros (`id_situacao` ausente → 1 → `.emAnalise`;
  `curso_credenciado` ausente → `"N"`), e mapeia todas as `CodingKeys`
  snake_case.
  *Verificável por:* XCTest unit (fixture completo + fixture mínimo).
- **VAL-23 (UC-6, SE-03).** `PDFAttachment.init?` **rejeita** (retorna
  `nil`): dados vazios, dados acima de `maxBytes` (default 10 MiB), e
  dados cujos 5 primeiros bytes não sejam `"%PDF-"`. Aceita um PDF
  válido dentro do limite.
  *Verificável por:* XCTest unit (função pura).
- **VAL-24 (UC-6, ET-01).** `registrar` só reporta
  `.confirmed(message:)` quando o backend responde `status:true` com
  mensagem; `status:false` → `.rejected(reason:)` com a razão do
  backend — nunca sucesso silencioso.
  *Verificável por:* XCTest unit (stub).
- **VAL-25 (UC-6).** `obterPessoa` com resposta `{"status":false,
  "message":"Pessoa não encontrada."}` (a resposta real de 56 bytes para
  CPF sem máscara — D0065) ⇒ `.success(nil)` (não erro); com
  `{"status":true,"data":{...}}` ⇒ `.success(PessoaExtData)`.
  *Verificável por:* XCTest unit contra fixtures reais.

### AVA Moodle (UC-7)

- **VAL-26 (UC-7).** `autoLoginURL(token:moodleUserId:)` monta a URL
  final anexando `userid` e `key` à `autologinurl` devolvida por
  `tool_mobile_get_autologin_key`.
  *Verificável por:* XCTest unit (stub).
- **VAL-27 (UC-7, D0064).** Quando a chave de autologin não pode ser
  obtida, `loginPageURL()` deriva `login/index.php` do `baseURL`
  injetado (fallback idêntico ao da baseline Android, sem host
  hardcoded).
  *Verificável por:* XCTest unit (função pura).

### Notícias (UC-8)

- **VAL-28 (UC-8).** `list(pagina:)` decodifica
  `{success, pagina, totalPaginas, noticias:[...]}` e preserva
  `pagina`/`totalPaginas` no `NoticiasPage`.
  *Verificável por:* XCTest unit (fixture).
- **VAL-29 (UC-8).** `materia(url:)` com `{success:true, noticia:null}`
  ⇒ `NewsError.notFound`; com `noticia` presente ⇒ `MateriaCompleta`
  com `conteudoHTML` e `imagens` mapeados.
  *Verificável por:* XCTest unit (fixture).

### Notificações administrativas (UC-9)

- **VAL-30 (UC-9, AR-02/PW-03).** `receive(_:)` faz **dedup por `id`**:
  receber duas vezes a mesma notificação não duplica na store nem
  incrementa o contador de não lidas duas vezes.
  *Verificável por:* XCTest unit (`LocalStore` de suíte isolada).
- **VAL-31 (UC-9).** `fetchFeed` (`mergeIncoming`) só incrementa o
  contador de não lidas pela quantidade de `id`s **novos** em relação
  ao que já está persistido.
  *Verificável por:* XCTest unit (stub + `LocalStore` isolada).
- **VAL-32 (UC-9, RS-02).** `pollIfStale(maxAge:)` **não** refaz a
  busca se `lastFetch` é mais recente que `maxAge`; refaz se está
  obsoleto ou ausente.
  *Verificável por:* XCTest unit (grava `lastFetch` sintético na
  `LocalStore` isolada).
- **VAL-33 (UC-9).** `markAllRead()` zera o contador; `receive` respeita
  o cap de 100 itens persistidos.
  *Verificável por:* XCTest unit.

### Lembretes de curso (UC-10)

- **VAL-34 (UC-10).** `DateParsing.parseEndDate` (porte Tier 2 de
  `EnrolledCourse.kt`) resolve: intervalo `dd/MM/yyyy a dd/MM/yyyy` (usa
  a 2ª data), `"<mês> de <ano>"` PT-BR (último dia do mês), `MM/yyyy`
  (último dia do mês), `dd/MM/yyyy` / `yyyy-MM-dd` simples, e devolve
  `-1` para entrada vazia ou não reconhecível.
  *Verificável por:* XCTest unit (função pura, tabela de casos).
- **VAL-35 (UC-10, AS-03).** Regra de cadência `shouldNotify`: nunca
  notificado (`notificationsSent == 0`) → notifica; já notificado → só
  após `>= 7` dias desde `lastNotifiedEpochDay`. Cap de 50 lembretes
  agendados por execução.
  *Verificável por:* XCTest unit (a regra é `private`; verificável via
  `@testable` extraindo a lógica, ou marcada como GAP se não exposta —
  ver `critical-coverage.md`).
- **VAL-36 (UC-10).** `reminderMessage(for:)` produz as **5** variações
  de texto por proximidade do prazo: hoje (`days == 0`), 1–3 dias,
  4–7 dias, `> 7` dias, e sem data (`daysRemaining == -1`).
  *Verificável por:* XCTest unit (`private static` — ver nota de GAP em
  `critical-coverage.md`; alternativamente coberto por teste manual).
- **VAL-37 (UC-10).** `EnrolledCourse.isStillActive` / `daysRemaining`:
  `endEpochDay == -1` ⇒ sempre ativo, `daysRemaining == -1`; caso
  contrário compara com `todayEpochDay()`.
  *Verificável por:* XCTest unit (função pura).
- **VAL-38 (UC-10).** `trackEnrollment` substitui (não duplica) por
  `id`; `prune` remove cursos terminados há mais de 30 dias, preserva
  `endEpochDay == -1`.
  *Verificável por:* XCTest unit (`LocalStore` isolada).

### Persistência (transversal)

- **VAL-39 (AR-03/RE-01).** `SecureStore` aceita **apenas** o tipo
  `Credential`; `LocalStore` é genérico `<T: Codable>` e não tem
  sobrecarga que aceite `Credential` — separação sensível/não-sensível
  garantida em tempo de compilação.
  *Verificável por:* revisão de tipos + XCTest unit de `LocalStore`
  round-trip (save/load/clear) com suíte isolada.
- **VAL-40 (SE-01).** `SecureStore.save` usa
  `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
  *Verificável por:* revisão de código (o atributo não é lido de volta
  pela API de teste sem device real) — **GAP** anotado; complementado
  por teste manual (persistência sobrevive a relançamento — VAL-4).

## Restrições técnicas (specs/technical) — verificação

- **TC-1 (A-1/D0012).** Nenhum teste altera contrato de backend — todos
  os stubs reproduzem contratos existentes; nenhum endpoint novo.
- **TC-2.** Produção é 100% HTTPS (ATS padrão) — nenhuma exceção de ATS
  no `Info.plist` gerado. *Verificável por:* revisão do target.
- **TC-3 (A-5).** Lembretes usam `UNUserNotificationCenter` agendado por
  data, não worker periódico. *Verificável por:* revisão de código +
  ausência de `BGTaskScheduler` periódico.

## Fora de cobertura automática nesta Fase 6 (justificado)

| Item | Motivo | Compensação |
|---|---|---|
| Handshake mTLS real contra os 3 backends | Exige `.p12` + rede + backend de produção | Teste manual (smoke P0) + curto-circuito `certificateUnavailable` testado (VAL-7) |
| Login/UC end-to-end com credenciais reais | GA não tem credenciais Moodle de produção | Teste manual exploratório do VA-human (Step 5) |
| Renderização visual das telas SwiftUI | Sem automação de UI (decisão P0032) | Teste manual exploratório + screenshots já feitos na Fase 5 |
| Recebimento real de push FCM (`EXT-DEP-01` → `EXT-DEP-03`) | `EXT-DEP-01` (`GoogleService-Info.plist`, D0051) **resolvido 2026-09-05**; resta `EXT-DEP-03` (Apple Developer Team / provisioning APNs institucional, D0090) | Integração de cliente concluída (P0045/D0088); dívida técnica de **validação de runtime** registrada; fora do escopo do gate |
| `SecItem` real / atributo de acessibilidade do Keychain | API de teste sem device real não lê o atributo de volta | Revisão de código (VAL-40) + persistência entre relançamentos (VAL-4, manual) |

## Dependências externas do ecossistema (não são defeitos do cliente iOS)

Fluxos cujo cliente iOS está verificado como **correto e em paridade
com a baseline Android**, mas cuja **funcionalidade absoluta** depende
de terceiros e está atualmente **indisponível também na baseline
Android**. Registrados como limitação do estudo (Fase 7), não como
FAIL do produto iOS.

| id | Fluxo | Evidência de causa externa comum | Registro |
|---|---|---|---|
| **EXT-DEP-01** | Push FCM real (envio/recebimento de notificação) | Falta `GoogleService-Info.plist` do console Firebase institucional do TJAC (acesso administrativo indisponível ao VA-human) | D0051; P0015–P0016 |
| **EXT-DEP-01** _(atualização — não substitui a linha acima)_ | Push FCM real — **BLOQUEADO → DESBLOQUEADO PARCIALMENTE** | `GoogleService-Info.plist` institucional real recebido em **2026-09-05** e integrado ao target `ESJUDApp` (Copy Bundle Resources, verificado no bundle). Caminho de **cliente iOS completo** e verificado por build/teste (96 testes verdes; App target `BUILD SUCCEEDED`). **Pendência de runtime** (não de arquivo): push real ponta-a-ponta exige **dispositivo físico + conta Apple Developer institucional** (App ID com Push + provisioning para `aps-environment` — sob assinatura ad-hoc o `.xcent` sai vazio, comprovado) **+ APNs Auth Key `.p8` no Firebase Console + envio de push de teste + validação manual S4**. | D0088; D0089; P0045 |
| **EXT-DEP-02** | Formulário de inscrição em curso (UC-3) | `GET /[endpoint-formulario-inscricao]` → HTTP 422 `FORM_UNAVAILABLE "etapa: timeout"` determinístico para a maioria dos cursos (Puppeteer server-side do backend); reproduzido por `curl` (cliente distinto do `URLSession`) em P0041 e **confirmado indisponível na baseline Android** pelo VA-human em P0043. Backend é contrato fixo (D0012). | D0084; P0041; P0043 |
| **EXT-DEP-03** | Validação de runtime do push real (UC-9) — assinatura/provisionamento APNs | **Não há Apple Developer Team institucional (TJAC) configurada no Xcode.** O app exige essa Team para assinatura/provisionamento; sem ela `aps-environment` não entra efetivamente no provisioning (confirmado empiricamente em P0045/D0089: sob assinatura ad-hoc sem *team* o Xcode reduz o `.xcent` a **vazio**). Logo o registro APNs e a validação de push real em dispositivo físico não podem ser concluídos agora. Distinta de `EXT-DEP-01` (arquivo `GoogleService-Info.plist`, já resolvido 2026-09-05). **Integração de cliente iOS concluída e verificada por build/teste — não é defeito do código nem FAIL do cliente.** Falta só: Team Apple do TJAC + App ID com *Push Notifications* + *provisioning* com `aps-environment` + APNs Auth Key `.p8` (Key ID + Team ID) no Firebase Console → Cloud Messaging → Apple app configuration + envio de push de teste + validação manual S4 em dispositivo real. | D0090; P0046; P0045/D0088–D0089 |

## Consolidação final da Fase 6 (P0047 / D0091)

### Matriz de casos de uso — estado manual real

| UC | Estado | Fonte |
|---|---|---|
| UC-1 Login | **PASS manual** | P0044/D0085 |
| UC-2 Cursos/listagem | **PASS manual** | P0043/D0084 |
| UC-3 Inscrição | **Paridade com a baseline** — cliente correto (P0033 + P0040); funcionalidade absoluta bloqueada por **EXT-DEP-02** (backend/Puppeteer). Não é FAIL do cliente. | P0041/P0043/D0084 |
| UC-4 Certificados | **PASS manual** (lista + download + abertura de PDF) | P0043/D0084 |
| UC-5 Certidão | **PASS manual** (gerar + validar + abrir + compartilhar) | P0044/D0086 |
| UC-6 Certificado Externo | **PASS manual** (Servidor + Magistrado; cadastro + listagem; B5 FAIL→corrigido→reteste PASS) | P0044/D0086/D0087 |
| UC-7 AVA/Moodle | **PASS manual** | P0046/D0090 |
| UC-8 Notícias | **PASS manual** | P0046/D0090 |
| UC-9 Notificações — feed / listagem / polling / badge / marcar como lidas **+ recebimento da notificação dentro do app** | **PASS manual** (execução humana real) | P0046/D0090; P0047/D0092–D0093 |
| UC-9 Notificações — **push remoto do sistema iOS (APNs/FCM)** (banner na Central, background/encerrado, tap) | **Implementação concluída / validação runtime pendente** por **EXT-DEP-03**. Não é FAIL do cliente. | P0045/D0088; P0047/D0093 |
| UC-10 Lembretes | **Aceito com WAIVER EXPLÍCITO do VA-human** (P0048/D0094) — **não** PASS manual. Base do waiver: VAL-34..38 (lógica automatizada), paridade Tier-2 fiel com o Android, ausência de evidência de divergência do cliente. A entrega efetiva da notificação **local** em runtime não foi validada manualmente. | P0047/D0091; P0048/D0094 |
| UC-11 Logout | **PASS manual** | P0044/D0085 |
| UC-12 Persistência de sessão | **PASS manual** (inclui metade Keychain de VAL-5 + VAL-4 relaunch) | P0044/D0085 |

### Edge cases — cobertura acumulada durante a passada (não um bloco à parte)

Achados adversariais reais **corrigidos com teste de regressão** durante a Fase 6: UC-3 *loading infinito* → máquina de estados (P0037–P0040, VAL-44/45); recriação de ViewModel sem `@State` (P0039); Certificados estado compartilhado + bytes de PDF descartados (P0042, VAL-46); CPF vazando em `os_log` → `redactedPathForLog` (P0042); seletor Servidor/Magistrado ausente (P0044, VAL-47). Caminhos de erro/limite automatizados: rejeições 400/409/422 com mensagem segura sem PII (VAL-12/41/42/43); `hasValidCPF` antes de rede (VAL-45); `PDFAttachment` rejeita vazio/não-PDF/grande (VAL-23); dedup por `id` push×polling (VAL-30/31 + `PushTransportTests`); cadência/cap de lembretes (VAL-35); cancelamento (`-999`) nomeado distinto de timeout (`-1001`) (VAL-44).

### Critérios de saída da Fase 6 (avaliação objetiva IACDM)

| Critério | `met` | Base |
|---|---|---|
| `tests_passing` | ✅ **MET** | 96 testes, 0 falhas, `TEST SUCCEEDED`, engine-witnessed (`lastTestOutcome` phase 6 exitCode 0, 2026-09-06T01:57:12Z). Suíte cresceu 67→78→96 na Fase 6, sempre verde. Package + App target `BUILD SUCCEEDED`. |
| `manual_testing` | ✅ **MET** (com ressalvas, P0048/D0094) | **10/12 UCs PASS manual** (UC-1/2/4/5/6/7/8/**9**/11/12; UC-9 = feed/listagem/polling/badge/marcar + recebimento no app). Ressalvas: UC-3 = paridade + `EXT-DEP-02`; UC-9 push remoto do sistema iOS = `EXT-DEP-03`; **UC-10 = waiver explícito do VA-human** (não PASS manual). |
| `edge_cases` | ✅ **MET** (P0048/D0094) | Racional aceita pelo VA-human: cobertura adversarial real da Fase 6 (achados reais + correções + testes de regressão) + caminhos de erro/limite automatizados. |

**Fase 6 — 3/3 critérios de saída `met`, com ressalvas documentadas (P0048 / D0094).**

**Ressalvas / pendências carregadas para a Fase 7** (dependências externas do ecossistema institucional, comuns à baseline Android, **não** defeitos do produto iOS):

- **EXT-DEP-02** — UC-3 Inscrição: backend `api-esjud.tjac.jus.br` / Puppeteer server-side (contrato fixo D0012).
- **EXT-DEP-03** — UC-9 push remoto do sistema iOS: falta Apple Developer Team institucional do TJAC + provisioning com `aps-environment` + APNs Auth Key `.p8` no Firebase Console + envio de push de teste + validação S4 em dispositivo real.
- **Waiver UC-10** — validação manual da entrega da notificação **local** não realizada (aceita por decisão do VA-human).
- `EXT-DEP-01` (arquivo `GoogleService-Info.plist`) — **RESOLVIDO** 2026-09-05.

**`advance_phase(7)` RETIDO** — aguarda o "go" final explícito do VA-human (S2 = critério de parada pertence ao usuário).

---

## Fase 7 (Post-Review) — Avaliação do produto (VA-human, D0095)

`advance_phase(target_phase=7)` executado 2026-09-06 após GO explícito do VA-human. Avaliação do produto colhida via `AskUserQuestion`:

**Veredito:** o app iOS **atende aos requisitos do P0** (produto completo — login, cursos, inscrição, certificados, certidão, certificado externo, AVA/Moodle, notícias, notificações, lembretes) **com as 3 ressalvas externas já documentadas**. 10/12 UCs PASS manual + UC-3 em paridade. Nenhuma lacuna restante é defeito do código iOS.

**Ressalvas confirmadas:** `EXT-DEP-02` (backend/Puppeteer — formulário de inscrição), `EXT-DEP-03` (validação runtime do push remoto — Apple Developer Team / provisioning APNs institucional), waiver `UC-10` (entrega da notificação local não validada manualmente).

**Backlog para o ciclo v2.0** (todos marcados pelo VA-human — detalhe em `specs/references/lessons.md`):

1. `EXT-DEP-03` — validar push remoto real com a conta/Team Apple Developer institucional do TJAC.
2. `UC-10` — fechar o waiver (validar entrega do lembrete local em runtime; cadência/cap em uso real).
3. `EXT-DEP-02` — acompanhar o backend de inscrição; revalidar UC-3 ponta a ponta quando corrigido.
4. Risco residual — aplicar `@State` semeado uma vez nas outras 8 telas com ViewModel construído inline (`CertificatesScreen`, `CertidaoScreen`, `CertExtScreen`, `MoodleWebScreen`, `NoticiasScreen`, `MateriaScreen`, `NotificationsScreen`, `HomeScreen`).
