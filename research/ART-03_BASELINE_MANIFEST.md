# Manifesto de Identificação da Baseline Android (ESJUDAC)

## Metadados da coleta

- **Timestamp da coleta (UTC):** 2026-08-26T22:06:12Z
- **Caminho da baseline:** `./ESJUDAC android referencia para criar ios/`
  (caminho absoluto no momento da coleta:
  `/Users/allandiegoafonsoalmeida/Documents/projeto converter android para ios/ESJUDAC android referencia para criar ios/`)
- **Algoritmo de hash de arquivo:** SHA-256 (`shasum -a 256`, macOS).
- **Escopo do manifesto:** módulo do aplicativo Android/Kotlin
  propriamente dito (`app/`) e os arquivos de configuração/raiz
  necessários para identificar e reconstruir o estado observado do
  projeto Gradle (build scripts, wrapper, `gradle/`, README, imagens de
  marca, política de privacidade, arquivos de configuração local e
  credenciais referenciadas pelo build).
- **Diretórios excluídos do escopo (e motivo):**
  - `.gradle/`, `.idea/`, `.kotlin/`, `app/build/` — caches de
    build/IDE, não fazem parte da implementação, são regenerados
    automaticamente e não são deterministicamente estáveis entre
    máquinas/execuções.
  - `api/`, `painel-web/`, `whatsapp-api/` — **não fazem parte do
    escopo deste manifesto de hashes de arquivo.** Cada um é um
    repositório Git independente (evidência: subdiretório `.git/`
    próprio dentro de cada pasta), já possuindo um identificador de
    estado reproduzível nativo (commit SHA). Ver seção "Subprojetos
    companheiros" abaixo para os identificadores observados.
- **Total de arquivos incluídos no manifesto:** 121.

## Regra de segurança aplicada

Nenhum conteúdo de arquivo sensível foi lido, copiado ou reproduzido
neste registro. Para todo arquivo, apenas caminho relativo, tamanho em
bytes e hash SHA-256 (calculado diretamente pelo shell, sem carregar o
conteúdo no contexto do agente) foram registrados. Os seguintes 5
arquivos foram identificados como sensíveis por seu tipo/finalidade
(certificado cliente mTLS, chave de assinatura de release, config do
Firebase, propriedades locais com possível senha) e têm **apenas
metadados e hash** — nunca conteúdo — nesta e em qualquer outra parte
do registro de pesquisa:

- `cliente_api_esjud.p12` (certificado cliente mTLS, raiz do projeto)
- `app/src/main/assets/certs/cliente_api_esjud.p12` (cópia do mesmo
  certificado, resultado da task Gradle `copyClientCert`)
- `app/esjud-upload-key.jks` (keystore de assinatura de release)
- `google-services.json` (configuração do Firebase)
- `local.properties` (propriedades locais de build, pode conter
  `CLIENT_CERT_PASSWORD`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD` e caminho
  do SDK local)

## Subprojetos companheiros (identificação por commit Git, não por hash de arquivo)

Estes três diretórios são repositórios Git próprios, com histórico e
remoto configurados. Registrados aqui apenas como contexto de
identificação de estado — não fazem parte do hash agregado da baseline
Android abaixo.

| Subprojeto | HEAD (commit) | Data do commit HEAD | Remoto (`origin`) | Arquivos com alteração não commitada (`git status --porcelain`) |
|---|---|---|---|---|
| `api/` | `e4c4bc633507d36d7be71750618714d8d2625efd` | 2026-05-08 11:20:26 -0500 | `https://git.tjac.jus.br/esjud/apiweb-emeronweb.git` | 11 |
| `painel-web/` | `38621975a50af80d5201d626b2f2c2e796ddd550` | 2026-05-12 09:28:37 -0500 | `https://git.tjac.jus.br/esjud/web-esjudac-mobile.git` | 6 |
| `whatsapp-api/` | `7ccd087b0cf7df95ed4e1d3e4cd829ef0946782b` | 2025-11-12 08:33:13 -0500 | `https://git.tjac.jus.br/esjud/whatsapp-api.git` | 37 |

Nenhum destes remotos foi acessado pela sessão; a informação vem
exclusivamente da configuração Git local (`.git/config`) e do histórico
local já presente no disco.

## Tabela de arquivos, tamanhos e hashes (escopo do manifesto)

Colunas: caminho relativo à raiz da baseline | tamanho em bytes | SHA-256 | sensível (metadados apenas).

| Caminho | Bytes | SHA-256 | Sensível |
|---|---|---|---|
| .gitignore | 237 | `103eb04771999aa7d864aecdc3979fda88afcc395a29a7551430f8e2e5a4a195` | não |
| README.md | 4679 | `652060de0daf156361ddf1a5e471cf0f36d33336956fd48d17c8e60161a2ac7d` | não |
| app/.gitignore | 30 | `3af209aeae4c4afc243a0169c9ae6838d321171f0323917633a779938949a067` | não |
| app/build.gradle.kts | 5608 | `dd7be060a03c07102cb498276c523d27318703f37fafcb150dd9aec8e3c754f4` | não |
| app/esjud-upload-key.jks | 2790 | `9eac3c9c3ef58ccbd1051769bfecae83e03813e42e2231e83036d36268a94b46` | sim |
| app/google-services.json | 693 | `34df959dd173da365a24e0bb433050f45f78e45f1eae69f872191473f22556a0` | não |
| app/painel-web-esjud-app-01-firebase-adminsdk-fbsvc-c0205fab5a.json | 2409 | `41ac9382d38ea1a1c8552e8a0a5f4995f26a4e915894adcc50cd059f430e7f4b` | não |
| app/proguard-rules.pro | 3575 | `f5d74a064ef9f984caec845c3d11d77b14a6b4a79a5004c48e12fc9f0ada24a7` | não |
| app/release/app-release.aab | 25216047 | `2e35d66331a4e02849a9b53650709e8ece63865b2866ff5211f887d987c432e9` | não |
| app/src/androidTest/java/com/example/esjudac/ExampleInstrumentedTest.kt | 665 | `a1dc09189adb1e700486dd7754e929753f579c02d7e1b06bc7994ed0d47525ca` | não |
| app/src/main/AndroidManifest.xml | 2425 | `baae30a89f1d58fb9539f3483208564cd4f0a444656accea814f1e66e94f18c4` | não |
| app/src/main/assets/certs/cliente_api_esjud.p12 | 4357 | `5109263b727d086a07ff2718891bac3c61c9d274d3a5191375662ad775af4aaf` | sim |
| app/src/main/java/com/example/esjudac/EsjudacApp.kt | 4890 | `2b97b729dcedfcbb11d8f6b9aea38e2ea679cfdb661a118b3e30a97e9b322624` | não |
| app/src/main/java/com/example/esjudac/MainActivity.kt | 13782 | `2aa44ceb1869d4b2a25e5d43714f566e8a6196dad0315f57e43b79a0324ab0b9` | não |
| app/src/main/java/com/example/esjudac/data/local/AdminNotificationsStore.kt | 5017 | `d323129894b14aef0b5c45c2b511f13a457d119c98a7d2d1688fb1f7476f3487` | não |
| app/src/main/java/com/example/esjudac/data/local/EnrolledCoursesStore.kt | 4843 | `08b2050df61619b361891cb446cf5f981263d204228ac7bb988e278b58882bc0` | não |
| app/src/main/java/com/example/esjudac/data/local/UserPreferences.kt | 5364 | `8fa56dacb190c6b56c060fe8a61ee459ad3ceb96f2bcdac2d8782c7e901cd9f2` | não |
| app/src/main/java/com/example/esjudac/data/model/Certificate.kt | 280 | `6e1efb7173c0c14b7a3e9b0a07366d38146411e1f8f9719de0ce1ae9219071da` | não |
| app/src/main/java/com/example/esjudac/data/model/Course.kt | 587 | `81c9098de12955d607bc3d7f882b09ddbca29bad1af06c8d121bc255e99ed61d` | não |
| app/src/main/java/com/example/esjudac/data/model/EnrolledCourse.kt | 3660 | `b983e5f3f41cf10a8a40bd5b18963a537784d342f3314d841bb5d2b9415b8732` | não |
| app/src/main/java/com/example/esjudac/data/model/MoodleModels.kt | 2419 | `4f24880f3c197abc080381cffea91875d4ead4c5e47e4c59e52d64c1c66b9770` | não |
| app/src/main/java/com/example/esjudac/data/model/Noticia.kt | 572 | `b480a606f970550fa71154df43da3d38012381a055e4781998347e42cc47f9f1` | não |
| app/src/main/java/com/example/esjudac/data/model/ScheduleActivity.kt | 420 | `9fcc0f266553fa4d5d3a36cc4a408848a699a46fefed57fb8d95f28036d31b0f` | não |
| app/src/main/java/com/example/esjudac/data/model/UiState.kt | 593 | `68847d41cd381af5e0aadf6f78363a28b4b6ef127106e1f4329931c1051b0965` | não |
| app/src/main/java/com/example/esjudac/data/remote/CertExtApi.kt | 2080 | `a0d3c502a1aaad74b235cd5cd0ca7aed5d158d90d7fbd25e27e0d975bc219b12` | não |
| app/src/main/java/com/example/esjudac/data/remote/CertExtApiModels.kt | 2456 | `59fe849cc0476dffab007967d884b81c899ab227e3bd5cc1cf605de4107dab1b` | não |
| app/src/main/java/com/example/esjudac/data/remote/CertidaoApi.kt | 1471 | `faabc32ab0bc6fb819804ecb01daf0c7627383845ec02b22290745d0a04584e9` | não |
| app/src/main/java/com/example/esjudac/data/remote/CertidaoApiModels.kt | 2092 | `65c8c9a9bf6e64f0e4550ed054f77317f169366f3b502e4556e008dec014a9ff` | não |
| app/src/main/java/com/example/esjudac/data/remote/ClientCertificateProvider.kt | 2323 | `7595505ee7a1e65c446593715de245009404678051057cffa1136f681e2d16d2` | não |
| app/src/main/java/com/example/esjudac/data/remote/EsjudacApi.kt | 2343 | `f9fc47053be24783fe7ea0b9097160dfafb93e171f771cbe4dab4175385608ef` | não |
| app/src/main/java/com/example/esjudac/data/remote/EsjudacApiModels.kt | 6348 | `86094499eda0d13d14eb91b38c512a045c4d76ea7583ae3b8f8b88611d9ea470` | não |
| app/src/main/java/com/example/esjudac/data/remote/MoodleApi.kt | 2370 | `04215af6e7dfb885132dc0d0e0898a7c8cb0297030248c4c05190b012d17023b` | não |
| app/src/main/java/com/example/esjudac/data/remote/NetworkModule.kt | 8222 | `9a5bc5e21d08383b2401675dd3df8bde7fd7c79de54da6d4707db5129aa4dfbf` | não |
| app/src/main/java/com/example/esjudac/data/remote/PainelApi.kt | 1603 | `e9e978fdff0a98cd5aae2961a850352717355479942dfba2e99f75d76930cec0` | não |
| app/src/main/java/com/example/esjudac/data/remote/PainelApiModels.kt | 1500 | `3c6ed8db40425c32825bfd681dcd94743fbdd763d09c5fb76a5f7f874bc34930` | não |
| app/src/main/java/com/example/esjudac/data/repository/AuthRepository.kt | 2778 | `dfb5eeaedc35feb0ea883f72a4f56a2eb07cab6205b772175aa4a4763796ea23` | não |
| app/src/main/java/com/example/esjudac/data/repository/CertExtRepository.kt | 4322 | `02a5d85d74adaf76d8928ea147dbfa75d40db271f398865b5690d94452ef44c2` | não |
| app/src/main/java/com/example/esjudac/data/repository/CertidaoRepository.kt | 4386 | `b3765ca3157a7fd014e7a6590a5d768b657a34bff601e0bb5a863fa3f06276ff` | não |
| app/src/main/java/com/example/esjudac/data/repository/CertificateRepository.kt | 2494 | `64109937d8ee47e3b1ae9cc1b1190774ef6178acfb739490f113043e4c4806f6` | não |
| app/src/main/java/com/example/esjudac/data/repository/CourseRepository.kt | 6438 | `5a15606b1a4cfd12a9c2638d72952be11e61a9d5180ebbcee390114cf433550c` | não |
| app/src/main/java/com/example/esjudac/data/repository/MoodleEnrollmentRepository.kt | 4122 | `93913054bb7ccc35482697697daa6630de79159649c7c0cc63ea065959327dc2` | não |
| app/src/main/java/com/example/esjudac/data/repository/NewsRepository.kt | 1777 | `e8ecb402bf968c0fea8b01fc8f51b8963d7bf5877c32c4b422476d273812c6d7` | não |
| app/src/main/java/com/example/esjudac/data/repository/PainelRepository.kt | 3185 | `88f6558f490c66da57fa7ceaa7d9fd52c0a7614d1330d1d85b2645b45c8e037a` | não |
| app/src/main/java/com/example/esjudac/data/webscraper/WebViewPdfWriter.kt | 3627 | `5e1ab1367d627a8ba566015d885eafeff000ca9defeab5157ae7b7a8845d971d` | não |
| app/src/main/java/com/example/esjudac/data/webscraper/WebViewScraper.kt | 7162 | `e472fe511642649703be2cda995f6e1b9510164822d87433a2e93333c15615ea` | não |
| app/src/main/java/com/example/esjudac/notifications/CourseReminderWorker.kt | 2708 | `d54bb7c666b54119f5fe113fde8aaea9f93eec8b5aacb8279c221f1337b065c2` | não |
| app/src/main/java/com/example/esjudac/notifications/EsjudacFirebaseMessagingService.kt | 2637 | `f63850e8ca5f971db4693775ce949b15931e1d151a55583ec90c8897e710b684` | não |
| app/src/main/java/com/example/esjudac/notifications/NotificationHelper.kt | 9686 | `34e9e01f9ca93bcb94546121e10443abffbfbd038ed9f3c8f8bee87f14e50b88` | não |
| app/src/main/java/com/example/esjudac/ui/components/Common.kt | 5512 | `892a45635b624094b72b093e9074bdd966f13adf15d4a71e1fadf7bf55b62d31` | não |
| app/src/main/java/com/example/esjudac/ui/navigation/AppNavigation.kt | 659 | `bd342f86b8fa4a68a2cb9fcb9d808a21f5c751e6e21a1d02f94d92c1c2887f8e` | não |
| app/src/main/java/com/example/esjudac/ui/screens/CertExtScreen.kt | 26450 | `8ba1b5bb45f08ea25a3e67be7b15493512141aeb5e9d9d9787b954dc35c5c6e3` | não |
| app/src/main/java/com/example/esjudac/ui/screens/CertidaoScreen.kt | 32489 | `d011544ac5dd964ca24ad067ad81f73e4f66baf31b7d2566d6aa805dff8348c7` | não |
| app/src/main/java/com/example/esjudac/ui/screens/CertificatesScreen.kt | 12739 | `e3e3d851c1ba80b891f93fde5a549c0fc2517ea949640bae1d42e3c8825549af` | não |
| app/src/main/java/com/example/esjudac/ui/screens/CoursesScreen.kt | 29325 | `a266c5e700cbc19934fa71d74562d7e22fafb098b285a48fba05c87b23d94d92` | não |
| app/src/main/java/com/example/esjudac/ui/screens/HomeScreen.kt | 26624 | `04dea1343d1655257066a384334792363fa1209d89057cb62582e1d6d6fa6ccf` | não |
| app/src/main/java/com/example/esjudac/ui/screens/LoginScreen.kt | 8162 | `4339482990d21bca092383a7eb75323ddc2e5086debbb698764d3808af3c8f48` | não |
| app/src/main/java/com/example/esjudac/ui/screens/MateriaScreen.kt | 10755 | `431d5a9999f60eb03f78b922a359840f6c81500689db4871388463e66e21ec38` | não |
| app/src/main/java/com/example/esjudac/ui/screens/MoodleWebScreen.kt | 6363 | `fd98bdaaead48f9f413eab6620ea1f4097440602308fff32c67a20f79ff790d1` | não |
| app/src/main/java/com/example/esjudac/ui/screens/NoticiasScreen.kt | 9223 | `3f6295bb271c3d9545581bfabf143691d176563b7f5a1f3d1b16f5a922ef38d3` | não |
| app/src/main/java/com/example/esjudac/ui/screens/NotificationsScreen.kt | 20281 | `7000a1825cc7753f866b437d54d7a70e0a4044422ffd4a10b55a0d982d1f3638` | não |
| app/src/main/java/com/example/esjudac/ui/theme/Color.kt | 640 | `ac89f38f99edb36ea2245808c1d6a19701a95141be8c466c5ee5a57a2b084b5d` | não |
| app/src/main/java/com/example/esjudac/ui/theme/Theme.kt | 1778 | `6ffd435ceb747075b3049bb8a6b7311fbdca13fb09a30c1c6346c3ac07b7216b` | não |
| app/src/main/java/com/example/esjudac/ui/theme/Type.kt | 988 | `3be4292f9782d82ac2bb24c0c0642dc4793cf8f66e132f85c3b162fa504a8e8a` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/CertExtViewModel.kt | 6808 | `aad7b380d2c22ee4374895657d99a98a2c7efb7f0d69ad6b99680b547761b060` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/CertidaoViewModel.kt | 5570 | `ddb9f86d427ddbf025c1f1306e5f085b72acf59a576de54dfbf5f4acffbde0b0` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/CertificatesViewModel.kt | 3038 | `1e0d4e03a55036eb4907db43b92f071464f1ab589fcc28394a4ded6282139ee9` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/CoursesViewModel.kt | 8600 | `378c344d554398ccce97df15fed29d3c122d1f542347bf32d3cddd6afb0ba120` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/HomeViewModel.kt | 1263 | `48536b3548d20f5cda5a6f153b19a915f70902929d80d2e5d8b928f1dd6b96bf` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/LoginViewModel.kt | 1678 | `00ee497ddd84066d8ad865c41d74cee400ff9f1dbac7a09d8aeaeae69fcbd72f` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/MoodleWebViewModel.kt | 2555 | `eb8567974886837f1e812acf8ba2be29b25e659cae4a4370ce4205575b407b15` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/NewsViewModel.kt | 3777 | `5df7be8ac90179bd883bc7c33aefd5972af65e881786cc8410898e1e6745c2b0` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/NotificationsViewModel.kt | 6342 | `0ca1787996283fc2cbbae5e232d843645e414cfe06d145b3cf3eb3f658a48257` | não |
| app/src/main/java/com/example/esjudac/ui/viewmodel/ViewModelFactory.kt | 2943 | `32c25c55b3fc80058e6d41a6d493e4fa2454d1a7d92e7104496cbed6131fadab` | não |
| app/src/main/res/drawable/ic_instagram.xml | 1289 | `d6aac612a46351a6d6db2cc3ae31f0d62632aebc6783e9119b42dca650c32953` | não |
| app/src/main/res/drawable/ic_launcher_background.xml | 175 | `1d4fe3a0935d48d6b60be3fe52aeeb45cd9f87c55904cf5fb26a6291341bd344` | não |
| app/src/main/res/drawable/ic_launcher_foreground.xml | 382 | `3754cfe4f1517a4ee68d332ba82f6ec3552440dc3d119a1d321634384faacb00` | não |
| app/src/main/res/drawable/ic_logo_esjud.png | 154771 | `506eff968edce61cea317ad464ba07329ae4b3dc6fdbf519173249f2394cac15` | não |
| app/src/main/res/drawable/ic_logo_esjud_branca.png | 177093 | `dc473269e977976ef6f4a04b53b4d839126bd0a7c9c4610024af63bc14d5b2d9` | não |
| app/src/main/res/drawable/ic_logo_esjud_icon.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/drawable/ic_notification.xml | 557 | `74e5b4a100e76fac43923b7eec2211b38e1e9c1a5dd7e170287e795ab9bafcaa` | não |
| app/src/main/res/drawable/ic_splash.xml | 620 | `fac918369f7e51cf1e5754a03a56074e79eca2d456aaacb9c7c22b457f7320de` | não |
| app/src/main/res/drawable/ic_youtube.xml | 646 | `4037255e51262ab713477c41d0913695f3fc418b0f87e9ecf363b69b91fb4595` | não |
| app/src/main/res/mipmap-anydpi/ic_launcher.xml | 362 | `b7c775700d1a684121538fea8c6e6d52414815583067cf910ea41de149104892` | não |
| app/src/main/res/mipmap-anydpi/ic_launcher_round.xml | 217 | `99fbe7a38acd16e8f549a7a6587b1ff92de9ff6ac644b9848d4a01ebddcd8efe` | não |
| app/src/main/res/mipmap-hdpi/ic_launcher.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-hdpi/ic_launcher_round.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-mdpi/ic_launcher.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-mdpi/ic_launcher_round.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xhdpi/ic_launcher.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xhdpi/ic_launcher_round.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xxhdpi/ic_launcher.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xxxhdpi/ic_launcher.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| app/src/main/res/raw/keep.xml | 293 | `09a79a02c2df1c789310dd56942dff9e56729a140030a7c010eefc53804e6406` | não |
| app/src/main/res/values/colors.xml | 597 | `3972a1f7bd074ce3a1eb58e099803f55a043c582a328e67286c846653aed5c79` | não |
| app/src/main/res/values/strings.xml | 204 | `1ebaa9eed4b7944d381628c5d16456b06c251e9f2d11e55349d5f69c7c816408` | não |
| app/src/main/res/values/themes.xml | 1002 | `4fe25d55bf4fe1fe25edf736f23c5f04063ff5afc7da81061843969df61ccbae` | não |
| app/src/main/res/xml/backup_rules.xml | 478 | `6cf1a27e6807b1d24e41d3fbe7ddc1bfe1f42226027964f6eaf477d71b43b283` | não |
| app/src/main/res/xml/data_extraction_rules.xml | 551 | `cb1fc47ab4a984530ed60e0e6ee638929c3038290e7e7e0b4b03a3a30fbe7381` | não |
| app/src/main/res/xml/file_provider_paths.xml | 272 | `dd59344c91a49b46f82a1b2fe5d7becf8e32b5b842dc11aa9f4749eb935918c2` | não |
| app/src/main/res/xml/network_security_config.xml | 583 | `9ed3865df84c65e0efbe608ab9a274262cf8826a3596cb74dc0d2ac0f229edb6` | não |
| app/src/test/java/com/example/esjudac/ExampleUnitTest.kt | 343 | `ff3e98deb70e66e00c898f4c36876ea9409997626f1847e6483e80d24d86c262` | não |
| build.gradle.kts | 310 | `22fd6c01241fd66d91ff4c4b93f60deff8b18006f247e19b90182fc2940e77c1` | não |
| cliente_api_esjud.p12 | 4357 | `5109263b727d086a07ff2718891bac3c61c9d274d3a5191375662ad775af4aaf` | sim |
| google-services.json | 689 | `ecb6b759b03b9ee97ccb02a4a24aa60903a61d4fa33a93271b50e1f087a6bd96` | sim |
| gradle.properties | 1035 | `84cb29dbe01a7ccfea54c0ecb1adfcf601e27738871b0eb02af68dbc2a401e56` | não |
| gradle/gradle-daemon-jvm.properties | 1138 | `231649d2f8e8dc24310f18c921e3ae33fd2715b7f48a7ddcaf27a85003e0729a` | não |
| gradle/libs.versions.toml | 4600 | `5f0f92b379cbe54dd149977f168b82f0ea0a530cdc025a03929a8961bcc19167` | não |
| gradle/wrapper/gradle-wrapper.jar | 45457 | `76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3` | não |
| gradle/wrapper/gradle-wrapper.properties | 378 | `597d04151624ba22b668458e03c793abc7ca4f2676d5289e6e6e238c1e56c4a2` | não |
| gradlew | 8728 | `3238afb2aed5cb16eb7d6718077e7138059108f007b54179e9cc157c5a6e0e89` | não |
| gradlew.bat | 2937 | `1d297e00bd21de3ace22b4d7f2de1f9dfa858883d66bbf7c1ccbecccec8f4f3b` | não |
| local.properties | 576 | `dd277d7193ee2d736a6e677c1d4c8433682d295f84e2f2b2185dcc6ce679c0dc` | sim |
| local.properties.example | 253 | `96119d86948776bb1aa806680543675ff39999bd912166fdf1c930e78b602e52` | não |
| logo-esjud-branca.png | 177093 | `dc473269e977976ef6f4a04b53b4d839126bd0a7c9c4610024af63bc14d5b2d9` | não |
| logo-esjud-icon-app.png | 56951 | `a2572261b0ab0995dd379cc86d8663a05e78985a3309c91e7e374ff7daed9521` | não |
| logo-esjud-icon.png | 28101 | `d59da02f581ee9804bd12c2dfb9a23ae2bde5383b130443dfd20eda3ecc4c33c` | não |
| logo-esjud.png | 154771 | `506eff968edce61cea317ad464ba07329ae4b3dc6fdbf519173249f2394cac15` | não |
| politica-de-privacidade.html | 15152 | `85504e3d1ed4b1f09c4938f91b074e3816fb363c39d8d0500fd9516e908cdf9b` | não |
| settings.gradle.kts | 618 | `5f84781ccad793917dad6c6562a8eff0c540e5d30a9cc68caa643622cabb8885` | não |

## Hash agregado do manifesto (mecanismo de verificação de integridade)

O hash agregado é o **SHA-256 do arquivo de dados tabular** (linhas
`caminho<TAB>bytes<TAB>sha256`, uma por arquivo, ordenadas
lexicograficamente por caminho, codificação UTF-8, sem linha de
cabeçalho) que gerou a tabela acima. Qualquer alteração, adição ou
remoção de arquivo dentro do escopo do manifesto altera este hash
agregado, permitindo verificar posteriormente, com um único valor, se a
baseline Android (`app/` + arquivos de raiz listados) foi modificada
desde esta coleta.

```
algoritmo: SHA-256
hash agregado: 323205b0a311f98efbfdcbe227cdaeb956121dafddb893f9e6d823b4c996982b
```

**Procedimento de reprodução:** para cada caminho listado na tabela
acima, calcular `shasum -a 256 <arquivo>`, montar uma linha
`caminho<TAB>tamanho_em_bytes<TAB>hash`, ordenar todas as linhas por
caminho, concatenar em um único arquivo de texto (sem cabeçalho, uma
linha por arquivo, terminadas em `\n`) e calcular `shasum -a 256` desse
arquivo resultante. O valor obtido deve ser idêntico ao hash agregado
acima se, e somente se, nenhum arquivo do escopo foi adicionado,
removido ou alterado em conteúdo ou tamanho.

## Limitações conhecidas deste mecanismo

- Hashes de arquivo e hash agregado detectam alteração de conteúdo,
  adição e remoção de arquivos dentro do escopo — não detectam
  alterações de metadados do sistema de arquivos (permissões,
  timestamps de modificação) quando o conteúdo em bytes permanece
  idêntico.
- Arquivos fora do escopo declarado (`.gradle/`, `.idea/`, `.kotlin/`,
  `app/build/`, e os três subprojetos companheiros) não são cobertos
  por este hash agregado; para os subprojetos companheiros, a
  identificação reproduzível é o commit HEAD de cada um (tabela acima),
  não um hash de arquivo.
- Este manifesto reflete o estado do disco no timestamp da coleta; não
  há garantia further de que o estado do disco não tenha sido alterado
  entre o início e o fim da coleta (a coleta em si levou poucos
  segundos).
