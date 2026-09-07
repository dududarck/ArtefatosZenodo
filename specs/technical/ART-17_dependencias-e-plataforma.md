# Dependências e Plataforma-alvo Android — evidenciado a partir do ESJUDAC

> Ver legenda de marcadores em `../domain/vocabulario-e-atores.md`.
> Fonte: `app/build.gradle.kts`, `gradle/libs.versions.toml`. Estas
> versões descrevem a **implementação Android de referência**, não são
> requisitos para o produto iOS — nenhuma dependência ou biblioteca iOS
> é decidida neste documento.

## Plataforma-alvo Android (para contexto de comparação)

| Item | Valor | Fonte |
|---|---|---|
| compileSdk | 36 | `app/build.gradle.kts` |
| minSdk | 28 (Android 9) | idem |
| targetSdk | 35 (Android 15) | idem |
| versionName / versionCode | 1.3.5 / 25 | idem |
| applicationId | `br.jus.tjac.esjud` | idem |
| Compatibilidade Java | 11 (source/target) | idem |
| Kotlin | 2.2.10 | `libs.versions.toml` |
| Android Gradle Plugin | 9.2.0 | idem |

## Bibliotecas de terceiros por responsabilidade (Android)

| Responsabilidade | Biblioteca(s) Android | Versão |
|---|---|---|
| UI declarativa | Jetpack Compose (BOM) | 2026.02.01 |
| Design system | Material3 (+ ícones estendidos) | 1.7.6 |
| Navegação | Navigation Compose | 2.8.5 |
| Ciclo de vida/estado | Lifecycle runtime/viewmodel compose | 2.8.7 |
| Rede HTTP | Retrofit + OkHttp (+ logging interceptor) | Retrofit 2.11.0 / OkHttp 4.12.0 |
| Serialização JSON | Moshi (+ codegen via KSP) | 1.15.1 |
| Parsing HTML | Jsoup | 1.18.1 |
| Concorrência | Kotlinx Coroutines | 1.9.0 |
| Persistência chave-valor | AndroidX DataStore (Preferences) | 1.1.1 |
| Carregamento de imagens | Coil | 2.7.0 |
| Execução em segundo plano | AndroidX WorkManager | 2.10.0 |
| Splash screen | AndroidX Core SplashScreen | 1.0.1 |
| Navegador embutido | AndroidX Browser (Custom Tabs) | 1.8.0 |
| Push notifications | Firebase (BOM) + Firebase Messaging | BOM 33.7.0 |
| Testes unitários | JUnit | 4.13.2 |
| Testes instrumentados/UI | AndroidX Test JUnit, Espresso, Compose UI Test | 1.2.1 / 3.6.1 / (via Compose BOM) |

## Observações relevantes para a tradução de plataforma (sem prescrever solução iOS)

- **[FATO]** Não há biblioteca de injeção de dependência (Hilt/Koin/Dagger)
  — o próprio `README.md` e o comentário em `EsjudacViewModelFactory.kt`
  confirmam que a DI é manual e deliberadamente simples ("Em projetos
  maiores trocaríamos por Hilt/Koin"). **[INFERÊNCIA]** isso indica que a
  simplicidade da injeção de dependência é uma escolha consciente de
  escopo do projeto Android, não uma limitação técnica — relevante como
  contexto (não como requisito) ao decidir a abordagem de DI no iOS.
- **[FATO]** Não há biblioteca de banco de dados relacional (Room/SQLite)
  — toda persistência estruturada é DataStore + JSON manual (ver
  `../technical/persistencia-e-dados-locais.md`).
- **[FATO]** Não foi encontrado uso de Jsoup em nenhum arquivo lido até
  agora, apesar de listado como dependência — **[AMBIGUIDADE]** pode
  estar em uso em `WebViewPdfWriter.kt` ou em outro arquivo não lido
  neste levantamento, ou ser uma dependência remanescente de uma
  implementação anterior (o próprio `whatsapp-api` legado, em Node, é
  quem historicamente fazia scraping/parsing HTML). **[PERGUNTA-VA]**
  não é necessário resolver esta ambiguidade agora; registrar para
  eventual verificação em fase de código (Fase 5).
- **[FATO]** Testes automatizados estão **declarados** nas dependências,
  mas verificado por listagem direta: `app/src/test/` contém apenas
  `ExampleUnitTest.kt` e `app/src/androidTest/` contém apenas
  `ExampleInstrumentedTest.kt` — os testes de template gerados pelo
  Android Studio, sem nenhum teste real do domínio da aplicação. **A
  baseline Android não tem cobertura de teste automatizado
  significativa.** Isso não deve ser interpretado como meta de
  "paridade zero de testes" para o iOS — é apenas o estado real
  observado, a ser considerado nas decisões de Fase 1/6.
