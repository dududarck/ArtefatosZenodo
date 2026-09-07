# Funcionalidades e Fluxos Visíveis ao Usuário — evidenciado a partir do Android (ESJUDAC)

> Ver legenda de marcadores em `vocabulario-e-atores.md`. Fluxos descritos
> a partir da leitura de `AppNavigation.kt`/`MainActivity.kt`, `ui/screens/*`
> e `ui/viewmodel/*`. Nomes de tela e rótulos são citados literalmente
> quando entre aspas.

## Mapa de navegação (rotas — [FATO], `Routes.kt` + `MainActivity.kt`)

```
LOGIN ──(login bem-sucedido)──▶ HOME
HOME ──▶ COURSES ("Inscrição em curso")
HOME ──▶ CERTIFICATES ("Certificados")
HOME ──▶ CERTIDAO_CURSOS ("Certidão de Cursos")
HOME ──▶ MOODLE_WEB ("AVA Moodle")
HOME ──▶ CERT_EXT/{tipo} ("Certificado Externo", tipo = SERVIDOR|MAGISTRADO,
          escolhido em um diálogo intermediário "Tipo de usuário")
HOME ──▶ NOTICIAS ("Ver todas" das notícias em destaque)
HOME ──▶ NOTIFICATIONS (sino no topo)
NOTICIAS ──▶ MATERIA (abrir uma notícia específica)
HOME ──(logout)──▶ LOGIN
Notificação push tocada ──▶ HOME com NOTIFICATIONS aberta automaticamente
```

- **[FATO]** `startDestination` é `HOME` se `session.isLoggedIn`, senão
  `LOGIN` — decidido de forma síncrona a partir do `Flow` de sessão do
  DataStore no momento em que a Activity é criada.
- **[FATO]** Ao logar, e também toda vez que o app é reaberto com sessão
  ativa, o dispositivo é registrado no painel administrativo em segundo
  plano (`app.painelRepository.registerDevice(...)`), sem bloquear a UI.

## Fluxo: Login

- **[FATO]** Tela única com dois campos ("Usuário Moodle", "Senha") e
  botão "Entrar". Texto de apoio: "Use o mesmo usuário e senha do AVA
  TJAC."
- **[FATO]** `AuthRepository.login`: chama `MoodleApi.login` (token.php);
  se falhar, usa `tokenResponse.error` como mensagem ou uma mensagem
  genérica; se suceder, busca `core_webservice_get_site_info` (nome,
  e-mail, foto, userId) — **em melhor esforço**, ou seja, se essa segunda
  chamada falhar, o login ainda é considerado bem-sucedido, apenas com
  campos de perfil vazios (**[INFERÊNCIA]**: `getSiteInfo` é tratado com
  `runCatching { }.getOrNull()`, então uma falha aqui não impede o login).
- **[FATO]** Sessão persistida localmente inclui a senha em texto puro
  (ver observação de segurança em `vocabulario-e-atores.md`).
- **[FATO]** Estados de UI: `Idle` → `Loading` (botão mostra spinner e
  fica desabilitado) → `Success` (navega para Home, remove Login da
  pilha) ou `Error` (mensagem em vermelho abaixo dos campos).

## Fluxo: Home

- **[FATO]** Saudação personalizada ("Olá, {nome ou usuário ou
  'bem-vindo(a)'}"), sino de notificações (com contador de não lidas,
  **[INFERÊNCIA]** badge dinâmico), botão de logout.
- **[FATO]** Seção "Serviços" com 5 cartões de menu, cada um com título e
  subtítulo:
  1. "Inscrição em curso" — "Veja cursos abertos e inscreva-se"
  2. "Certificados" — "Consultar e baixar PDF"
  3. "Certidão de Cursos" — "Gerar e validar certidão"
  4. "AVA Moodle" — "Acesse seus cursos online"
  5. "Certificado Externo" — "Registrar certificado externo"
- **[FATO]** Seção de destaque de notícias com botão "Ver todas".
- **[FATO]** Ao tocar em "Certificado Externo", abre um diálogo modal
  "Tipo de usuário" pedindo para escolher entre Servidor/Magistrado antes
  de navegar.
- **[FATO]** Rodapé com links para redes sociais (ex.: "YouTube" — outros
  rótulos não confirmados neste corte de leitura).
- **[INFERÊNCIA]** `HomeViewModel` dispara, no login/abertura, a lógica
  de lembretes de curso (`CourseReminderWorker.sendReminders`), reforçada
  por um `Worker` periódico semanal (ver seção de comportamentos
  específicos do Android em `../technical/comportamentos-especificos-android.md`).

## Fluxo: Inscrição em curso (Courses)

- **[FATO]** Lista cursos disponíveis via `GET /api/cursos`
  (`CourseRepository.listAvailableCourses`).
- **[FATO]** Ao selecionar um curso, busca um formulário dinâmico via
  `GET /[endpoint-formulario-inscricao]` (pode levar [latência típica observada] porque o backend usa
  automação de navegador — Puppeteer — internamente, conforme
  comentário no código).
- **[FATO]** O formulário tem campos condicionais: PCD, Gênero, Raça,
  Vínculo (com/sem vínculo institucional), Ocupação, e um campo de
  localização cujo rótulo e opções mudam conforme o vínculo ("local"
  quando sem vínculo, "setor" quando com vínculo) — mutuamente
  exclusivos.
- **[FATO]** Tratamento de respostas do backend:
  - HTTP 409 no GET do formulário ou no POST de inscrição → "já
    inscrito" (mensagem do backend, com fallback padrão).
  - HTTP 422 no GET → "indisponível" (vagas esgotadas/prazo encerrado).
  - Outros erros → mensagem genérica de erro.
- **[FATO]** Perfil de inscrição (PCD, gênero, raça, vínculo, ocupação,
  local/setor) é persistido localmente e reutilizado nas próximas
  inscrições (`UserPreferences.saveProfile`).
- **[INFERÊNCIA]** Após inscrição bem-sucedida, é esperado que
  `NotificationHelper.sendEnrollmentConfirmation` seja chamado (título
  fixo "Inscrição confirmada!") — não foi confirmado neste corte de
  leitura o ponto exato do `CoursesScreen`/`CoursesViewModel` que dispara
  essa chamada; **[PERGUNTA-VA]** confirmar se toda inscrição bem
  sucedida sempre dispara essa notificação local.

## Fluxo: Certificados

- **[FATO]** Lista certificados por CPF via `GET /api/certificados/{cpf}`.
- **[FATO]** Nota de evidência no próprio repositório: o campo "pessoa"
  do certificado **nunca é preenchido pela API** (sempre vazio) — a UI
  precisa lidar com isso.
- **[FATO]** Download individual em PDF via
  `GET /api/certificados/{cpf}/{index}/download`, como stream binário
  salvo em arquivo local e exposto via `FileProvider`.

## Fluxo: Certidão de Cursos

- **[FATO]** Gera uma certidão agregada por CPF e período (`PeriodoConfig`
  — aceita um número de meses ou uma string, ex. um ano ou "ano-mês")
  via `POST /api/v1/certificates/generate`, que retorna um PDF binário
  mais metadados em headers HTTP customizados: número da certidão
  (`X-Certificate-Number`), nome da pessoa, total de cursos e total de
  horas.
- **[FATO]** Permite validar um número de certidão já emitido
  (`GET /api/v1/certificates/validate/{numero}`) e baixar o PDF de uma
  certidão existente pelo número
  (`GET /api/v1/certificates/pdf/{numero}`).
- **[FATO]** Mensagens de erro do backend são extraídas por regex de
  campos `message`/`error` no corpo JSON de erro.

## Fluxo: Certificado Externo (Servidor/Magistrado)

- **[FATO]** Fluxo de 3 etapas evidenciado pela API: (1) buscar pessoa
  pelo CPF (`obter_pessoa.php`), (2) listar certificados já registrados
  (`listar_certificados.php`), (3) registrar um novo certificado com
  upload de PDF via `multipart/form-data`
  (`registrar_certificado.php`) — campos: nome da pessoa, CPF, nome do
  curso, carga horária (inteiro), instituição emissora, arquivo PDF; para
  Magistrado, adicionalmente "nome de atuação" e "nome do período".
- **[FATO]** Permite excluir um certificado registrado, mas **apenas
  quando seu status é "Em análise" (id_situacao == 1)**, conforme
  comentário no repositório — **[INFERÊNCIA]** certificados já
  aprovados/rejeitados não podem ser excluídos pelo usuário via app.
- **[FATO]** As duas variantes de usuário (Servidor/Magistrado) usam
  prefixos de rota diferentes na mesma base de API, mas a mesma forma de
  buscar pessoa é usada para ambas ("resultado é idêntico para ambos",
  conforme comentário no código).

## Fluxo: AVA Moodle (WebView/Custom Tabs)

- **[FATO]** Não é um WebView embutido na tela — a tela busca uma "chave
  de autologin" do Moodle (`tool_mobile_get_autologin_key`) e então abre
  a URL resultante em **Chrome Custom Tabs** (navegador do sistema com
  UI customizada), retornando automaticamente para a Home em seguida.
- **[FATO]** Estados exibidos: carregando ("Preparando acesso ao AVA..."),
  erro ("Não foi possível abrir o AVA" + botão "Tentar novamente"), ou
  transição imediata (a tela em si nunca fica "pronta" visualmente — ela
  abre o navegador e volta).
- **[INFERÊNCIA]** Uma nova chave de autologin é solicitada a cada
  acesso a essa tela ("consome a URL para que a próxima visita gere uma
  nova chave") — sugere que a chave é de uso único ou expira rapidamente,
  mas isso não foi confirmado a partir de documentação do Moodle, apenas
  do comportamento do app.

## Fluxo: Notícias e Matéria

- **[FATO]** Lista paginada de notícias (12 por página, conforme
  comentário na API), cada item com título, data, imagem, resumo e
  categorias.
- **[FATO]** Abrir uma notícia carrega o conteúdo completo
  (`GET /[endpoint-noticia-completa]?url=...`), incluindo HTML de corpo e lista
  de imagens com legenda — **[INFERÊNCIA]** a tela de Matéria
  provavelmente renderiza HTML (não confirmado em detalhe neste corte de
  leitura do `MateriaScreen.kt`).
- **[FATO]** Esse endpoint também usa automação de navegador no backend
  (Puppeteer), com latência de [latência típica observada] conforme comentário no código.

## Fluxo: Notificações (dentro do app)

- **[FATO]** Duas fontes de notificação convergem na mesma tela/lista:
  (1) notificações administrativas vindas do painel (via push FCM e/ou
  busca de feed), persistidas em `AdminNotificationsStore`; (2) contexto
  de cursos matriculados/lembretes, via `EnrolledCoursesStore` e
  `MoodleEnrollmentRepository`.
- **[FATO]** Um clique em uma notificação com `actionUrl` abre essa URL
  diretamente (fora do app); sem link, abre o app na tela de
  Notificações.
- **[FATO]** O contador de não lidas é zerado quando o usuário abre essa
  tela (`markAllRead`).

## Comportamento de erro/crash "global" observado (não é uma "funcionalidade" no sentido de produto, mas é um comportamento externamente visível)

- **[FATO]** O app instala handlers globais de exceção não capturada
  tanto no `Application` (`EsjudacApp.installGlobalCrashLogger`) quanto
  na `Activity` (`MainActivity`), e, ao capturar uma exceção não tratada
  **durante a montagem da UI Compose**, tenta exibir uma tela de erro
  amigável (`StartupErrorScreen`) em vez de deixar o app fechar
  abruptamente. Isso é um comportamento de robustez visível ao usuário
  final em cenários de falha de inicialização.
