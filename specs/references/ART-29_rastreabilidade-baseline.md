# Índice de Rastreabilidade — specs/ ↔ código-fonte Android (P0002)

Mapa de qual arquivo de `specs/` foi derivado de qual parte da baseline
Android, para permitir auditoria e verificação humana. Todos os
caminhos são relativos a
`./ESJUDAC android referencia para criar ios/`. Identificação
reproduzível completa do estado inspecionado (hashes SHA-256) está em
`../../research/BASELINE_MANIFEST.md`.

| Documento em `specs/` | Principais arquivos-fonte inspecionados |
|---|---|
| `domain/vocabulario-e-atores.md` | `README.md`; `app/src/main/res/values/strings.xml`; `app/build.gradle.kts`; `ui/screens/LoginScreen.kt`; `data/repository/CertExtRepository.kt`; `data/remote/NetworkModule.kt`; `data/local/UserPreferences.kt` |
| `domain/funcionalidades-e-fluxos.md` | `ui/navigation/AppNavigation.kt`; `ui/navigation/Routes.kt`; `MainActivity.kt`; `ui/screens/LoginScreen.kt`, `HomeScreen.kt`, `MoodleWebScreen.kt`; `data/repository/CourseRepository.kt`, `CertificateRepository.kt`, `CertidaoRepository.kt`, `CertExtRepository.kt`, `NewsRepository.kt` |
| `technical/integracao-apis.md` | `data/remote/MoodleApi.kt`, `EsjudacApi.kt`, `CertExtApi.kt`, `CertidaoApi.kt`, `PainelApi.kt`, `NetworkModule.kt`, `ClientCertificateProvider.kt`; `app/src/main/res/xml/network_security_config.xml` |
| `technical/persistencia-e-dados-locais.md` | `data/local/UserPreferences.kt`, `EnrolledCoursesStore.kt`, `AdminNotificationsStore.kt`; `data/repository/AuthRepository.kt` |
| `technical/comportamentos-especificos-android.md` | `data/webscraper/WebViewScraper.kt`; `notifications/EsjudacFirebaseMessagingService.kt`, `NotificationHelper.kt`, `CourseReminderWorker.kt`; `MainActivity.kt`; `EsjudacApp.kt`; `app/src/main/AndroidManifest.xml` |
| `technical/dependencias-e-plataforma.md` | `app/build.gradle.kts`; `gradle/libs.versions.toml`; `app/src/test/`, `app/src/androidTest/` (listagem) |
| `models/modelos-de-dados.md` | `data/model/*.kt`; `data/remote/EsjudacApiModels.kt`, `PainelApiModels.kt`, `CertExtApiModels.kt`, `CertidaoApiModels.kt`, `MoodleModels.kt` |

## Arquivos e diretórios da baseline explicitamente **não** inspecionados neste levantamento (P0002)

Registrados para transparência — não foram lidos em detalhe, apenas
identificados por hash em `../../research/BASELINE_MANIFEST.md`:

- Conteúdo detalhado das telas: `CertExtScreen.kt`, `CertidaoScreen.kt`,
  `CoursesScreen.kt`, `CertificatesScreen.kt`, `NoticiasScreen.kt`,
  `NotificationsScreen.kt`, `MateriaScreen.kt`, `ui/components/Common.kt`,
  `ui/theme/*.kt` — apenas grep/trechos pontuais foram lidos, não o
  arquivo completo.
- `WebViewPdfWriter.kt` — apenas existência e menção no README
  confirmadas, conteúdo não lido.
- Todos os recursos visuais (`res/drawable`, `res/mipmap-*`, `res/raw`),
  `colors.xml`, `themes.xml`.
- Os subprojetos companheiros `api/`, `painel-web/`, `whatsapp-api/`
  (Node.js) — identificados apenas por commit Git em
  `../../research/BASELINE_MANIFEST.md`; nenhum arquivo de código
  interno foi lido.

Se a Fase 0/1 precisar de detalhamento adicional de qualquer um destes
itens, uma nova rodada de inspeção read-only deve ser registrada com seu
próprio identificador `P00NN` em `../../research/RESEARCH_LOG.md`.

## Arquivos da baseline inspecionados em detalhe **durante a implementação** (Fases 5–6)

Registrados na Fase 7 para completar a rastreabilidade — foram lidos
integralmente ao portar/validar comportamento, além do levantamento
inicial P0002:

| Tema | Arquivos-fonte Android lidos | Onde entrou no produto iOS |
|---|---|---|
| Push FCM (serviço, token, re-registro) | `app/src/main/java/com/example/esjudac/notifications/EsjudacFirebaseMessagingService.kt` | `AppShell/ESJUDApp/FirebaseMessagingBridge.swift` (P0045) — `onNewToken`→`didReceiveRegistrationToken`; `onMessageReceived`→`willPresent`/`didReceiveRemoteNotification`; mapeamento de chaves `title`/`message`/`type`/`target`/`actionUrl`/`createdBy` |
| Notificação de sistema + intent de tap | `notifications/NotificationHelper.kt` | Handlers do `UNUserNotificationCenterDelegate`; `EXTRA_OPEN_NOTIFICATIONS` → rota `notifications` no `NavigationPath` |
| Registro de dispositivo no painel | `data/repository/PainelRepository.kt`, `data/remote/PainelApi.kt`, `data/local/UserPreferences.kt` (`getOrCreateDeviceToken`/`saveFcmToken`) | `Sources/PushTransport/PushTransportRepository.registerDevice` + `currentOrFallbackToken`; chamadas ligadas em `ESJUDApp.swift` (login/restauração/`scenePhase`) |
| Permissão de notificação + deep-link no lançamento | `MainActivity.kt` (`requestNotificationPermission`, `LaunchedEffect(session.isLoggedIn)`, `EXTRA_OPEN_NOTIFICATIONS`) | `AppDelegate.requestNotificationAuthorization`; `registerPushDeviceIfLoggedIn`; `appDelegate.onOpenNotifications` |
| Backend do painel (contrato `register-device`) | `painel-web/src/lib/devicesRepo.js`, `painel-web/src/app/api/public/register-device/route.js` | Confirmação do corpo `{token, platform, userId, username, fullName}` e do header `X-Api-Key` — nenhum backend novo |
| Lembretes de curso (datas, cadência, mensagens) | `notifications/CourseReminderWorker.kt`, `data/model/EnrolledCourse.kt`, `notifications/NotificationHelper.sendCourseReminder` | `Sources/CourseReminders/CourseReminderRepository.swift` — `DateParsing`, `shouldNotify` (cadência 7 dias, cap 50), `reminderMessage` (5 variações), `isStillActive`/`daysRemaining` (VAL-34–38) |
| Timeouts de rede | `data/remote/NetworkModule.kt` (`connectTimeout 30s` / `readTimeout 120s` / `writeTimeout 60s`) | Referência para o diagnóstico do UC-3 (P0034); confirmado depois que a causa era outra (máquina de estados, P0040) |
| Fluxo Servidor/Magistrado do Certificado Externo | `ui/screens/CertExtScreen.kt` (`showTipoDialog`), `data/repository/CertExtRepository.kt` (prefixo de rota por tipo) | `Sources/HomeUI/HomeScreen.swift` `.confirmationDialog` + roteamento por `Bool` (P0044/VAL-47) |
| Download/abertura de PDF | `ui/screens/CertificatesScreen.kt`, `ui/viewmodel/CertificatesViewModel.kt` (`FileOutputStream` + `FileProvider`+`ACTION_VIEW`) | `Sources/CertificatesUI/CertificatesScreen.swift` — salvar em `Documents/certificados/` + QuickLook + `ShareLink` (P0042/VAL-46) |
