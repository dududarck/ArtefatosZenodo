# Vocabulário de Domínio e Atores — evidenciado a partir do Android (ESJUDAC)

> Fonte: inspeção somente-leitura de `./ESJUDAC android referencia para criar ios/`
> em 2026-08-26 (P0002, ver `research/RESEARCH_LOG.md` e
> `research/BASELINE_MANIFEST.md` para identificação reproduzível do estado
> inspecionado). Este documento trata o código Android como **evidência**,
> não como especificação normativa para o iOS.

Legenda usada em todo este documento:
**[FATO]** diretamente evidenciado no código/recursos · **[INFERÊNCIA]**
comportamento deduzido a partir de evidência indireta · **[PRESSUPOSTO]**
suposição não totalmente confirmada · **[AMBIGUIDADE]** informação
conflitante ou incompleta · **[PERGUNTA-VA]** requer confirmação do
VA-human antes da Fase 0/1 tratar como decidido.

## Instituição e identidade do produto

- **[FATO]** `strings.xml`: `app_name = "ESJUD"`,
  `app_full_name = "Escola Superior da Magistratura do Acre"`,
  `app_subtitle = "ESJUD - Acre"`.
- **[FATO]** `LoginScreen.kt` (rodapé): texto fixo
  `"v1.0 · Escola do Poder Judiciário do Acre"`.
- **[FATO]** `README.md` do projeto: "App oficial da Escola do Poder
  Judiciário do Acre (ESJUD-AC) (...) integrada com o AVA Moodle do TJAC."
- **[AMBIGUIDADE]** O nome institucional por extenso diverge entre três
  fontes do próprio projeto: "Escola Superior da Magistratura do Acre"
  (`strings.xml`), "Escola do Poder Judiciário do Acre" (`LoginScreen.kt`
  e `README.md`). Não há como resolver qual é o nome oficial atual
  apenas com o código.
- **[PERGUNTA-VA]** Qual é o nome institucional correto/atual a ser usado
  no produto iOS: "ESJUD" como marca curta é consistente nas três fontes,
  mas o nome por extenso precisa de confirmação humana.
- **[FATO]** `applicationId` Android: `br.jus.tjac.esjud`; `namespace`:
  `com.example.esjudac` — indica vínculo institucional com o Tribunal de
  Justiça do Acre (TJAC), mas o pacote de desenvolvimento ainda usa
  `com.example` como namespace interno de código.

## Atores (evidenciados)

- **Aluno/servidor autenticado (usuário do AVA Moodle)** — **[FATO]**
  autentica-se com usuário/senha do "AVA TJAC" (Moodle), consome cursos,
  certificados, notícias e certidões. É o único perfil de usuário final
  identificado no app (não há indício de múltiplos papéis/perfis dentro
  do app mobile).
- **Servidor (para fins de Certificado Externo)** — **[FATO]**
  `TipoUsuarioCertExt.SERVIDOR`, usa prefixo de rota
  `registro-certificados-externos`.
- **Magistrado (para fins de Certificado Externo)** — **[FATO]**
  `TipoUsuarioCertExt.MAGISTRADO`, usa prefixo de rota `vida-funcional` e
  exige campos adicionais (`nomeAtuacao`, `nomePeriodo`) não exigidos do
  Servidor — **[INFERÊNCIA]** magistrados têm um fluxo de registro de
  certificado ligeiramente mais rico por exigência funcional/de cargo,
  mas o código não explica por quê.
- **Administrador do painel (ator externo, fora do app mobile)** —
  **[INFERÊNCIA]** a partir de `PainelApi`/`PainelRepository`/
  `EsjudacFirebaseMessagingService`: existe um operador humano ou processo
  que publica "notificações administrativas" (comunicados) através do
  `painel-web` (subprojeto Node/Next.js irmão, fora do escopo do app
  mobile), que chegam ao app via feed HTTP e/ou push FCM.
- **Backend/API institucional (ator de sistema)** — **[FATO]** múltiplos
  serviços HTTP mantidos pelo TJAC/ESJUD consumidos pelo app: Moodle
  (`ava.tjac.jus.br`), API ESJUD (`api-esjud.tjac.jus.br`), API de
  Certificados Externos (`api-esjud-registro-certificado-externo.tjac.jus.br`),
  API de Certidão de Cursos (`api-esjud-certidao-cursos.tjac.jus.br`) e
  Painel (`esjudac-mobile.tjac.jus.br`). Ver
  `../technical/integracao-apis.md` para detalhes.

## Vocabulário de domínio (termos observados no código/UI, em português)

| Termo (PT-BR, como aparece no app) | Significado evidenciado | Fonte |
|---|---|---|
| Curso | Atividade de capacitação disponível para inscrição | `Course.kt`, `CoursesScreen.kt` |
| Inscrição | Ato de se matricular em um curso via API ESJUD | `CourseRepository.enroll` |
| Cronograma | (mencionado no README como funcionalidade original; **[AMBIGUIDADE]** não foi localizada uma tela/rota "Cronograma" no código atual — ver seção "Divergência README vs. código" abaixo) | `README.md` |
| Certificado | Comprovante de participação em curso, disponível em PDF | `Certificate.kt`, `CertificatesScreen.kt` |
| Certidão de Cursos | Documento agregando múltiplos cursos concluídos num período, com número de validação | `CertidaoRepository.kt`, `CertidaoScreen.kt` |
| Certificado Externo | Certificado de curso feito fora do ESJUD, registrado pelo próprio usuário (upload de PDF) para fins funcionais | `CertExtRepository.kt` |
| Vínculo | Classificação do usuário no formulário de inscrição: com vínculo (servidor, "S") ou sem vínculo (externo, "N") — determina se o campo exibido é "setor" ou "local" | `EsjudacApiModels.kt` (`FormularioInscricaoResponse`) |
| PCD | Pessoa com deficiência — campo do formulário de inscrição | `EsjudacApiModels.kt` |
| AVA | Ambiente Virtual de Aprendizagem — nome popular do Moodle do TJAC | `MoodleWebScreen.kt`, `README.md` |
| Notícia / Matéria | Conteúdo editorial publicado pelo ESJUD, listado paginado e com página de leitura completa | `Noticia.kt`, `NewsRepository.kt` |
| Notificação administrativa (comunicado) | Aviso enviado pelo painel administrativo, exibido no app e/ou via push | `PainelApiModels.kt` (`AdminNotification`) |
| Lembrete de curso | Notificação local automática sobre cursos em andamento perto do fim do prazo | `CourseReminderWorker.kt`, `NotificationHelper.kt` |

## Divergência README vs. código (evidência de deriva de escopo)

- **[FATO]** O `README.md` do repositório de referência descreve como
  funcionalidades: "Login Moodle", "Listar e inscrever em cursos",
  "Cronograma de cursos/eventos" e "Listar e baixar certificados em PDF" —
  quatro funcionalidades, mapeadas para
  `ScheduleRepository.kt`/tela de Cronograma.
- **[FATO]** O código-fonte atual (61 arquivos Kotlin) contém, além
  dessas, telas e repositórios para: Notícias/Matéria, Notificações
  administrativas (push + feed), Certidão de Cursos, Certificado Externo
  (Servidor/Magistrado) e acesso ao AVA Moodle via WebView/Custom Tabs —
  e **não há** `ScheduleRepository.kt` nem tela de "Cronograma" no
  código atual.
- **[INFERÊNCIA]** O `README.md` reflete uma versão anterior do produto
  e não foi atualizado à medida que o app evoluiu; o código-fonte é a
  evidência mais confiável do comportamento atual.
- **[PERGUNTA-VA]** A funcionalidade de "Cronograma" foi descontinuada
  intencionalmente, foi absorvida por outra tela (ex.: Notícias), ou é
  uma lacuna a ser reavaliada para o produto iOS? Isso não pode ser
  decidido pelo GA — decisão de escopo pertence à Fase 0/1.

## Comportamento de segurança observado (fato, não julgamento)

- **[FATO]** `UserPreferences.kt` grava a **senha do Moodle em texto
  aberto** no DataStore (`Keys.PASSWORD`, `stringPreferencesKey`), junto
  com o token — não há indicação de criptografia adicional no código
  lido. Isso é um comportamento observável do sistema existente, citado
  aqui como fato de evidência; **não** implica que o produto iOS deva
  reproduzir esse comportamento — essa é uma decisão de arquitetura/
  segurança a ser tomada nas fases seguintes (ex.: Keychain no iOS é o
  mecanismo idiomático equivalente, mas essa escolha não está sendo
  feita agora).
- **[FATO]** `NetworkModule.kt` contém uma chave de API (`PAINEL_API_KEY`)
  **embutida diretamente no código-fonte Kotlin** (não em `.env`,
  `local.properties` nem BuildConfig). O valor real não é reproduzido
  neste documento por ser um segredo; ver o arquivo original
  (`app/src/main/java/com/example/esjudac/data/remote/NetworkModule.kt`)
  se for necessário consultá-lo, mediante controle de acesso adequado.
  **[PERGUNTA-VA]** Este segredo deve ser rotacionado/gerenciado de outra
  forma no produto iOS, ou tratado como valor público de baixo risco
  (o comentário no código sugere que ele é compartilhado com o
  `painel-web` via `.env.local`)?
