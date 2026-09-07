# Comportamentos Específicos da Plataforma Android — evidenciado a partir do ESJUDAC

> Ver legenda de marcadores em `../domain/vocabulario-e-atores.md`. O
> propósito deste documento é **separar o que é comportamento
> externamente observável do produto** (deve ter algum equivalente
> funcional no iOS) **do que é mecanismo específico do Android** (não
> deve ser transcrito literalmente para iOS — precisa de tradução
> arquitetural nas fases seguintes).

## 1. Scraping via WebView como substituto de Puppeteer

- **[FATO]** `WebViewScraper.kt` implementa um "Puppeteer para Android":
  carrega páginas num `WebView` headless (não exibido ao usuário na
  maioria dos usos) e executa JavaScript arbitrário para navegar,
  preencher formulários e ler dados de páginas do EmeronWeb/portal ESJUD.
  O comentário do arquivo confirma explicitamente que "toda a lógica do
  JS dos serviços de scraping da pasta `whatsapp-api` foi portada para
  uso aqui".
- **[FATO]** É usado por telas/repositórios específicos — não é o
  mecanismo geral de acesso às APIs REST (a maior parte do app usa
  Retrofit normalmente); o comentário nos endpoints de "formulário de
  inscrição" e "matéria de notícia" indica que **o backend**, não o app,
  é quem executa Puppeteer nesses casos — o `WebViewScraper` do app é
  usado em outro(s) ponto(s) do fluxo que não foram lidos em detalhe
  neste levantamento (nenhuma tela lida até agora chama
  `WebViewScraper` diretamente nos arquivos já inspecionados;
  **[PERGUNTA-VA]** confirmar em qual fluxo exato do app o
  `WebViewScraper` local é efetivamente utilizado, via inspeção adicional
  ou explicação do time, antes de decidir se há necessidade de qualquer
  equivalente no iOS).
- **[INFERÊNCIA]** Este é o tipo de mecanismo que **não deve** ser
  reproduzido literalmente no iOS (WKWebView headless + JS injection)
  sem antes entender o que ele resolve — pode ser que, no iOS, o mesmo
  resultado deva vir simplesmente de uma chamada Retrofit-equivalente ao
  backend, já que o comentário sugere que o scraping "pesado" já roda no
  servidor via Puppeteer real. Este é um ponto crítico para a Fase 1
  (arquitetura), não uma conclusão deste levantamento.

## 2. WebViewPdfWriter (geração de PDF a partir de WebView)

- **[FATO]** Existe `WebViewPdfWriter.kt` (não lido linha a linha neste
  levantamento, apenas confirmada sua existência e menção no README
  como equivalente ao `page.pdf({format:'A4'})` do Puppeteer, usando
  `createPrintDocumentAdapter` do Android).
- **[INFERÊNCIA]** Isso sugere que, em algum fluxo, o próprio app (não
  apenas o backend) gera um PDF localmente a partir de conteúdo web —
  possivelmente para certificados ou certidões, embora os fluxos de
  Certificado e Certidão lidos neste levantamento obtenham o PDF pronto
  diretamente da API (bytes binários), não localmente. **[PERGUNTA-VA]**
  identificar em qual fluxo exato `WebViewPdfWriter` é usado antes de
  decidir se o iOS precisa de um equivalente (ex.: `WKWebView` +
  `UIPrintPageRenderer`, ou se a geração de PDF é sempre responsabilidade
  do backend e este componente está em desuso).

## 3. Notificações push (Firebase Cloud Messaging)

- **[FATO]** Usa Firebase Cloud Messaging (FCM) para push administrativo.
  Comportamento externamente observável: usuário recebe uma notificação
  do sistema com título/corpo vindos do payload FCM (`notification.*` ou
  `data.*` como fallback); ao tocar, se houver `actionUrl`, abre essa URL;
  senão, abre o app na tela de Notificações.
- **[FATO]** O token FCM é persistido localmente e reenviado ao painel
  administrativo sempre que muda (`onNewToken`) ou após login.
- **[INFERÊNCIA]** O mecanismo de transporte (FCM) é específico do
  ecossistema Google/Android; o **comportamento observável** (usuário
  logado recebe avisos administrativos direcionados, com opção de abrir
  um link) é o que precisa ser preservado no iOS — o equivalente
  idiomático de transporte seria APNs (Apple Push Notification service),
  possivelmente via Firebase Cloud Messaging for iOS (que internamente
  usa APNs) se o backend do painel for reaproveitado sem alteração, ou
  APNs direto se o backend for adaptado. Essa é uma decisão de
  arquitetura para a Fase 1, não deste levantamento.

## 4. Canais de notificação (Android NotificationChannel)

- **[FATO]** Três canais distintos, cada um com nome/descrição/
  importância própria: `course_reminder` (lembretes de curso,
  importância padrão, com vibração), `enrollment_success` (confirmação
  de inscrição, importância alta), `admin_notifications` (avisos ESJUD,
  importância alta, com vibração).
- **[INFERÊNCIA]** Esses três canais representam três **categorias de
  notificação com prioridades distintas na percepção do produto** —
  informação de domínio relevante mesmo que o iOS não tenha o conceito
  exato de "canal" (iOS usa categorias de notificação com propósito
  parecido, mas mecanismo diferente).

## 5. Lembretes de curso via WorkManager (execução em segundo plano periódica)

- **[FATO]** `CourseReminderWorker` roda semanalmente (`PeriodicWorkRequestBuilder`,
  7 dias, política `KEEP` — não duplica agendamento se já existir) e,
  independentemente disso, a mesma lógica de envio de lembretes também é
  disparada no momento do login/abertura do app (via `HomeViewModel`,
  inferido a partir da chamada peer em `CourseReminderWorker.sendReminders`
  ser reaproveitada por dois pontos de entrada).
- **[FATO]** Regra de negócio de cadência: nunca notificado → notifica
  imediatamente; já notificado → só notifica de novo após 7 dias desde o
  último lembrete (`shouldNotify`).
- **[FATO]** Regra de conteúdo da mensagem varia pela proximidade do
  prazo final do curso: hoje ("termina HOJE"), 1–3 dias, 4–7 dias, mais
  de 7 dias, ou sem data definida — cinco variações de texto
  (`buildReminderMessage`).
- **[INFERÊNCIA]** Esse é um comportamento de produto genuíno (engajamento
  do usuário com cursos em andamento), não um detalhe de implementação
  Android — precisa de um equivalente funcional no iOS (ex.:
  `BGAppRefreshTask`/notificações locais agendadas), mas a manutenção
  de execução em segundo plano é native ao Android (WorkManager sobrevive
  a reinícios via `RECEIVE_BOOT_COMPLETED`) e tem restrições e mecanismos
  bastante diferentes no iOS — decisão de arquitetura para fases
  seguintes.

## 6. Permissão de notificação (Android 13+)

- **[FATO]** Solicita `POST_NOTIFICATIONS` em tempo de execução apenas
  em `Build.VERSION.SDK_INT >= TIRAMISU` (API 33), e apenas se ainda não
  concedida — comportamento condicional específico de versões recentes
  do Android. **[INFERÊNCIA]** o equivalente conceitual no iOS é a
  solicitação de autorização de notificações via
  `UNUserNotificationCenter`, que sempre exige prompt explícito
  (diferente do Android, que não pedia permissão em versões antigas).

## 7. Splash screen, edge-to-edge e tratamento de crash na inicialização

- **[FATO]** Usa a API `SplashScreen` do AndroidX Core (biblioteca de
  compatibilidade) e `enableEdgeToEdge()` — comportamentos de
  apresentação visual específicos da plataforma Android/Jetpack Compose;
  não têm relação direta 1:1 no iOS (que tem seu próprio mecanismo de
  launch screen).
- **[FATO]** Handler global de exceção não capturada tenta mostrar uma
  tela de erro (`StartupErrorScreen`) em vez de crashar silenciosamente
  — este é um **comportamento de produto observável** (robustez perante
  falha de inicialização) que vale a pena preservar conceitualmente no
  iOS, ainda que o mecanismo (`Thread.setDefaultUncaughtExceptionHandler`)
  seja específico da JVM/Android.

## 8. Deep link / intent para abrir a tela de Notificações a partir de uma notificação tocada

- **[FATO]** Usa `Intent` com `FLAG_ACTIVITY_SINGLE_TOP`/`CLEAR_TOP` e um
  extra booleano (`EXTRA_OPEN_NOTIFICATIONS`) para sinalizar à
  `MainActivity` que deve navegar direto para a tela de Notificações
  assim que o NavHost estiver pronto — mecanismo de intents é específico
  do Android; o comportamento observável (tocar numa notificação leva
  direto à tela relevante) tem equivalente natural no iOS via
  `UNUserNotificationCenterDelegate` + navegação programática.

## 9. Certificado cliente mTLS embarcado como asset do app

- **[FATO]** O `.p12` é copiado para dentro do pacote do app
  (`assets/certs/`) em tempo de build via uma task Gradle
  (`copyClientCert`), a partir de um arquivo mantido na raiz do
  repositório (fora do controle de versão, conforme `.gitignore`) — ver
  `../technical/integracao-apis.md` para o uso do certificado.
- **[INFERÊNCIA]** Esse é um mecanismo de empacotamento específico do
  processo de build Gradle; no iOS, o equivalente seria embarcar o
  `.p12` no bundle da aplicação (ou geri-lo via um mecanismo de
  distribuição de segredo mais seguro) — decisão de segurança/arquitetura
  para as fases seguintes, não deste levantamento.

## 10. Chrome Custom Tabs para navegador embutido com tema

- **[FATO]** Usado apenas para abrir o AVA Moodle autenticado
  (`MoodleWebScreen`), com cor de toolbar/barra de navegação igual à cor
  primária do tema do app — mecanismo Android (AndroidX Browser); o
  equivalente natural no iOS é `SFSafariViewController` (com
  customização de cor via `preferredControlTintColor`/
  `preferredBarTintColor`) ou `ASWebAuthenticationSession` se autenticação
  federada for necessária.
