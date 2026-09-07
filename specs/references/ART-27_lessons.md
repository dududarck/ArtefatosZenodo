# Lições do projeto — ESJUD iOS v1.0 (Fase 7)

> Lições sobre **este projeto** (não sobre a metodologia IACDM).
> Registro persistido que alimenta um eventual ciclo v2.0 e serve de
> post-mortem. Fonte: `research/RESEARCH_LOG.md` P0001–P0048,
> `research/DECISIONS.md` D0001–D0094, `research/GATES.md`.

## 1. Domínio — o ecossistema institucional tem dependências que o app não controla

Dois fluxos do produto têm a **funcionalidade absoluta** bloqueada por
terceiros, e a verificação só ficou clara ao comparar com a baseline
Android rodando o mesmo backend:

- **`EXT-DEP-02` — formulário de inscrição em curso.**
  `GET /[endpoint-formulario-inscricao]` responde HTTP 422
  `FORM_UNAVAILABLE "etapa: timeout"` de forma **determinística por
  curso** para a maioria dos cursos (automação Puppeteer server-side
  estourando o próprio tempo). `curl` mTLS — cliente HTTP totalmente
  diferente do `URLSession` — recebe o **mesmo** 422; o Android
  baseline também não serve o formulário. Conclusão: replicar
  fielmente a baseline **inclui replicar o comportamento observável de
  uma falha externa**. O erro de porta teria sido "consertar" o cliente
  para mascarar isso.
- **`EXT-DEP-03` — push remoto APNs/FCM.** A integração de cliente pode
  estar 100% pronta e testada e ainda assim ser **não-validável** sem a
  conta Apple Developer institucional: sem *team* + App ID com Push +
  provisioning, o Xcode **descarta silenciosamente** o entitlement
  `aps-environment` (o `.xcent` compilado sai vazio) e o registro APNs
  falha. Isso não aparece como erro de build — aparece como
  `didFailToRegisterForRemoteNotificationsWithError` em runtime.

**Invariante que emergiu:** distinguir sempre três níveis — (a) paridade
de cliente alcançada; (b) funcionalidade absoluta do ecossistema; (c)
responsabilidade provável (backend / conta institucional / código). Só
(a) e (c)∩código estão sob controle do projeto.

## 2. Stack — SwiftUI: identidade de objeto em `navigationDestination` é uma armadilha real

Um `@Observable`/ViewModel **construído inline** dentro do closure de
`navigationDestination` (ou passado como propriedade simples / `@Bindable`)
é **recriado** a cada recomposição do ancestral — inclusive quando
`scenePhase` muda. A instância nova cancela a `Task` em voo
(`NSURLErrorCancelled`, `-999`) e o resultado é escrito num objeto que
ninguém mais renderiza → **"loading infinito, nenhum erro visível"**.

- **Antídoto:** semear o ViewModel **uma única vez** com
  `@State private var vm = ViewModel(...)` via `State(initialValue:)` no
  `init`. Custou 4 rodadas de diagnóstico (P0037–P0039) até isolar.
- **Corolário:** a premissa **A-10** da Fase 1 ("a preservação de estado
  padrão do SwiftUI é suficiente para sobreviver à suspensão do app")
  estava **errada como enunciada** — só é verdadeira **com `@State`
  explícito**. O padrão do SwiftUI, sem isso, não preserva.

## 3. Stack — a máquina de estados de uma tela precisa de saída garantida de todo estado transitório

O bug real do UC-3 (P0040) não era rede: era `case .idle, .loading:` no
`body` renderizando `ProgressView` sempre que `hasValidCPF == true`. Ao
completar o CPF, a tela trocava para o spinner e **removia o botão** que
dispararia a operação — `.loading` sem nenhuma operação em andamento e
sem saída.

**Regra adotada:** `.idle` é estado **estável** ("aguardando o usuário",
sempre com um controle de saída visível); toda entrada em `.loading`
vem de uma função que **garante** transição para estado terminal em
todos os ramos (guards inclusive). Travar isso com teste de contrato do
ViewModel (`isLoadingForm <=> formState == .loading`, VAL-45) — o `body`
da View em si não é testável sem automação de UI.

## 4. Stack — Firebase iOS por SPM é incompatível com este projeto; XCFrameworks manuais funcionam

Adicionar o Firebase iOS via Swift Package Manager derruba
**reprodutivelmente** o Xcode/`xcodebuild` com `IDESwiftPackageCore`
neste layout (pacote SPM local `ESJUDAC` + app target com
`project.pbxproj` autoral, sem `.xcworkspace` gerado). Duas sessões
perdidas (D0045/D0046) antes de abandonar o caminho.

- **Solução (D0050):** baixar os 8 `.xcframework` pré-compilados,
  colocá-los em `Frameworks/`, adicionar à fase *Embed Frameworks*,
  `-ObjC -lc++` em `OTHER_LDFLAGS`.
- **Padrão que funcionou:** um **arquivo-ponte** (`FirebaseMessagingBridge.swift`)
  no app-shell é o único lugar que importa o SDK; o módulo de domínio
  (`PushTransport`, M-11) permanece agnóstico via um tipo próprio
  (`RemoteMessagePayload`). Facilita testar (parser e evidência de token
  viraram funções puras em `PushInterop.swift`, cobertas por
  `DomainTests`) e trocar de SDK no futuro.

## 5. Stack — mTLS com `URLSession`: dois obstáculos não óbvios

- **`.p12` de senha vazia é rejeitado** por `SecPKCS12Import` (D0055).
  O arquivo institucional veio assim; foi preciso re-encodar com
  [criptografia moderna] + senha não-vazia (mesmo par de chaves, só re-empacotado).
- **HTTP/2 connection coalescing → HTTP 421.** Quando dois hosts
  resolvem para o mesmo IP e apresentam certificados compatíveis, o
  `URLSession` reusa a conexão TLS e o backend responde **421
  Misdirected Request**. Solução: uma `URLSession` **por host**
  (`sessionsByHost` em M-01, D0058).

## 6. Processo/observabilidade — PII vaza por log antes de vazar por payload

O endpoint `/api/certificados/{cpf}/{index}/download` colocava o **CPF
no path**, que ia para `os_log` em `[request]`/`[metrics]`/`[lifecycle]`
mesmo com o corpo/headers já sanitizados (P0042). Adicionado
`NetworkClient.redactedPathForLog` que mascara sequências de 11 dígitos
e `000.000.000-00` **antes de qualquer `os_log`**. Lição: auditar o que
vai para o log estruturado com o mesmo rigor do que vai para a rede — o
`path` é um vetor fácil de esquecer. Evidência de token idem: só
comprimento + hash não reversível, nunca o valor.

## 7. Processo — o hook de teste do Versus só entende `npm/pytest/cargo/go test`

`xcodebuild test` não é reconhecido pelo `test-outcome.js`; foi preciso
um `package.json` na raiz com `"test"` encaminhando para `xcodebuild`.
E **qualquer** comando `Bash` (inclusive `cat >> arquivo` para escrever
o registro científico) é interceptado e classificado — um `cat` sem
palavras-chave de teste vira `outcome="unknown"` e **sobrescreve** o
último `lastTestOutcome` verde, quebrando `advance_phase`. Mitigação:
usar `Write`/`Edit` para arquivos de `research/`/`specs/` (o
`phase-gate.js` só bloqueia gravação nas Fases 0–4) e rodar o teste
isolado com `npm test; echo "VERSUS_TEST_EXIT=$?"` logo antes de
`advance_phase`.

---

## Backlog para o ciclo v2.0 (Fase 7, avaliação do VA-human — D0095)

O VA-human confirmou que o produto **atende ao P0** *com* as 3 ressalvas
externas documentadas. Itens marcados para carregar ao próximo ciclo:

1. **`EXT-DEP-03` — validar push remoto real.** Com a conta/Team Apple
   Developer institucional do TJAC: App ID `br.jus.tjac.esjud.app` com
   *Push Notifications*, provisioning com `aps-environment`, APNs Auth
   Key `.p8` (Key ID + Team ID) no Firebase Console → Cloud Messaging →
   Apple app configuration, envio de push de teste (Console e/ou backend
   do painel) e validação S4 em dispositivo físico (token APNs+FCM nos
   logs sanitizados; device no painel; foreground→banner sem duplicar;
   background/encerrado→bandeja; tap abre a tela de Notificações;
   polling `/api/public/feed` segue funcional; badge/"marcar todas"
   coerentes; sem duplicação push × feed).
2. **UC-10 — fechar o waiver.** Inscrição em curso com data futura →
   background → reabrir → confirmar a notificação local `"Lembrete: …"`;
   testar cadência (7 dias) e cap (50) em uso real.
3. **`EXT-DEP-02` — acompanhar o backend de inscrição** (não é código
   iOS). Se/quando o passo Puppeteer server-side for corrigido,
   revalidar UC-3 ponta a ponta no app com CPF real.
4. **Risco residual — ViewModels inline sem `@State` nas outras 8 telas.**
   P0039 corrigiu só `EnrollmentScreen`/`CoursesScreen`. O mesmo padrão
   existe em `CertificatesScreen`, `CertidaoScreen`, `CertExtScreen`,
   `MoodleWebScreen`, `NoticiasScreen`, `MateriaScreen`,
   `NotificationsScreen`, `HomeScreen` — nenhuma apresentou o sintoma
   (D0073), mas carregam o mesmo risco estrutural. Aplicar `@State`
   semeado uma vez, preventivamente.
