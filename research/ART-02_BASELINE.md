# Baseline: Aplicação Android de Referência

Diretório inspecionado: `./ESJUDAC android referencia para criar ios/`.
Esta inspeção foi **somente leitura** — nenhum arquivo dentro deste
diretório foi criado, modificado ou removido.

Timestamp da inspeção de baseline: 2026-08-26T21:5xZ–22:0xZ (UTC).

## Status desta implementação no estudo

Esta aplicação Android é a **implementação de referência (baseline)**
usada como ponto de partida factual para a reconstrução nativa iOS. Ela
NÃO é tratada como especificação infalível ou normativa: decisões de
arquitetura, UX e domínio para a versão iOS serão avaliadas e
justificadas pela metodologia IACDM (fases 0-4), podendo divergir do
comportamento atual do Android sempre que houver justificativa
registrada.

## Situação do repositório Git

Verificado: **não há repositório Git** neste diretório nem em nenhum
diretório pai do workspace.

- `git status` executado dentro de `ESJUDAC android referencia para criar ios/`
  retornou: `fatal: not a git repository (or any of the parent
  directories): .git`.
- Não existe subdiretório `.git/` em `ESJUDAC android referencia para
  criar ios/` nem na raiz do workspace.
- **Commit atual: indisponível** (não há histórico Git para referenciar).

## Tecnologias objetivamente identificáveis

Identificadas por leitura de arquivos de configuração e código-fonte,
sem execução do projeto:

- **Linguagem principal do app mobile:** Kotlin (Jetpack Compose), via
  plugins Gradle `android.application`, `kotlin.compose`, `ksp`,
  `google.services` (`build.gradle.kts`, `app/build.gradle.kts`).
- **compileSdk:** 36; **minSdk:** 28; **targetSdk:** 35;
  **versionCode:** 25; **versionName:** "1.3.5"; **applicationId:**
  `br.jus.tjac.esjud`; **namespace:** `com.example.esjudac`
  (`app/build.gradle.kts`).
- **Arquitetura declarada:** MVVM com Coroutines + StateFlow, injeção de
  dependência manual via classe `EsjudacApp` (sem Hilt) — conforme
  `README.md` do projeto.
- **Bibliotecas principais (via `libs.*` no Gradle):** Compose BOM,
  Material3, Navigation Compose, Retrofit + Moshi (rede/serialização),
  OkHttp (+ logging), Jsoup (parsing HTML), Kotlinx Coroutines,
  AndroidX DataStore (preferences), Coil (imagens), AndroidX WorkManager,
  AndroidX Core SplashScreen, AndroidX Browser (Custom Tabs), Firebase
  BOM + Firebase Messaging (push).
- **Testes declarados nas dependências:** JUnit, AndroidX Espresso,
  AndroidX Compose UI Test (JUnit4), AndroidX Test JUnit — presentes nas
  dependências de teste/androidTest/debug; não foi verificado se há
  arquivos de teste implementados nem sua cobertura real.
- **Autenticação:** integração com Moodle (AVA do TJAC) via endpoint
  `https://ava.tjac.jus.br/login/token.php` (Retrofit), token persistido
  em DataStore — conforme `README.md`.
- **Scraping/automação:** uso de `WebView` com JavaScript habilitado
  como substituto de Puppeteer (`data/webscraper/WebViewScraper.kt`,
  `WebViewPdfWriter`), descrito no `README.md` como porte do que antes
  rodava em Node/Puppeteer (`whatsapp-api/`).
- **Certificado cliente mTLS:** arquivo `cliente_api_esjud.p12` presente
  na raiz do repositório de referência, exigido para chamar as APIs
  `api-esjud.tjac.jus.br`; senha configurada fora do controle de versão,
  via `local.properties` (`CLIENT_CERT_PASSWORD`). Também há um
  `google-services.json` na raiz. **Nota de sensibilidade:** estes são
  artefatos de credencial/configuração; seu conteúdo não foi lido nem
  será reproduzido neste registro de pesquisa.
- **Subprojetos adicionais no mesmo repositório** (fora do escopo do app
  mobile, mas presentes no diretório de baseline): `api/`, `painel-web/`
  e `whatsapp-api/`, cada um com seu próprio `package.json` — indicando
  projeto(s) Node.js/JavaScript companheiros (painel web e API/bot). Não
  foram inspecionados em profundidade nesta baseline inicial; podem ser
  relevantes como contexto de domínio/API em fases posteriores (specs/).

## Estrutura principal do projeto (módulo `app`)

Código-fonte Kotlin sob `app/src/main/java/com/example/esjudac/` (61
arquivos `.kt` no total), organizado por pacotes:

```
com/example/esjudac/
├── EsjudacApp.kt              # Container DI simples
├── MainActivity.kt            # NavHost + bootstrap
├── notifications/             # Firebase Cloud Messaging
├── data/
│   ├── local/                 # DataStore (token Moodle, CPF)
│   ├── model/                 # Course, Certificate, ScheduleActivity, ...
│   ├── remote/                # MoodleApi, NetworkModule
│   ├── repository/            # Auth, Course, Schedule, Certificate
│   └── webscraper/            # WebViewScraper, WebViewPdfWriter
└── ui/
    ├── components/            # Composables compartilhados
    ├── navigation/             # Routes.kt
    ├── screens/                # Login, Home, Cursos, Cronograma, Certificados
    ├── theme/                  # Cores e tipografia ESJUD
    └── viewmodel/              # ViewModels + factory
```

(Estrutura de diretórios confirmada por listagem direta do sistema de
arquivos; conteúdo funcional de cada tela/repositório ainda não foi
lido linha a linha nesta baseline inicial — isso é trabalho das fases
seguintes da metodologia, quando permitido.)

## Permissões e integrações declaradas (README)

- `INTERNET`, `ACCESS_NETWORK_STATE`.
- PDFs de certificados salvos em armazenamento de app e abertos via
  `FileProvider`.
- Chamadas a `https://ava.tjac.jus.br` (Moodle) e a
  `https://api-esjud.tjac.jus.br/` /
  `https://api-esjud-registro-certificado-externo.tjac.jus.br/` (mTLS).

## Timestamp da baseline

2026-08-26T21:5xZ–22:0xZ (UTC) — ver entradas correspondentes em
`RESEARCH_LOG.md`.

## Manifesto de identificação reproduzível (atualização — P0002)

Em 2026-08-26, foi produzido um manifesto de hashes SHA-256 para
estabelecer uma identificação reproduzível do estado da baseline
Android, já que ela não possui repositório Git. Nenhum arquivo da
baseline foi modificado e nenhum repositório Git foi criado dentro
dela para esse fim.

- **Manifesto completo:** [`BASELINE_MANIFEST.md`](./BASELINE_MANIFEST.md)
- **Escopo:** `app/` (módulo Android/Kotlin) + arquivos de configuração
  de raiz do projeto Gradle; exclui caches (`.gradle/`, `.idea/`,
  `.kotlin/`, `app/build/`).
- **Hash agregado (SHA-256) do manifesto de arquivos:**
  `323205b0a311f98efbfdcbe227cdaeb956121dafddb893f9e6d823b4c996982b`
- **Arquivos sensíveis identificados** (apenas metadados/hash, nunca
  conteúdo, em qualquer parte do registro): `cliente_api_esjud.p12`
  (raiz e cópia em `app/src/main/assets/certs/`),
  `app/esjud-upload-key.jks`, `google-services.json`,
  `local.properties`.
- **Subprojetos companheiros** (`api/`, `painel-web/`, `whatsapp-api/`):
  cada um é um repositório Git independente já identificável por
  commit HEAD; ver tabela em `BASELINE_MANIFEST.md`. Todos os três
  apresentam alterações não commitadas no momento da coleta (11, 6 e 37
  arquivos, respectivamente).
