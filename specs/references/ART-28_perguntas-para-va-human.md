# Perguntas Pendentes para o VA-human (levantadas em P0002)

Estas perguntas foram levantadas durante a inspeção read-only da baseline
Android e **não foram respondidas pelo GA** — são preservadas aqui,
explicitamente, para serem tratadas na Fase 0 (ou fase apropriada), em
vez de o GA adivinhar uma resposta. Cada item referencia o documento de
origem.

1. **Nome institucional oficial.** "ESJUD" como marca curta é
   consistente em todas as fontes, mas o nome por extenso diverge entre
   "Escola Superior da Magistratura do Acre" (`strings.xml`) e "Escola
   do Poder Judiciário do Acre" (`README.md`, `LoginScreen.kt`). Qual é
   correto para o produto iOS? — `domain/vocabulario-e-atores.md`.

2. **Funcionalidade "Cronograma".** Descrita no `README.md` como
   funcionalidade original, mas ausente do código-fonte Kotlin atual
   (sem `ScheduleRepository`/tela correspondente). Foi descontinuada,
   substituída, ou é uma lacuna? — `domain/vocabulario-e-atores.md`.

3. **Gestão do segredo `PAINEL_API_KEY`.** Está embutido diretamente no
   código-fonte Kotlin (não em `.env`/`local.properties`/BuildConfig).
   Deve ser rotacionado/gerenciado de outra forma no produto iOS, ou é
   aceitável como valor de baixo risco? — `domain/vocabulario-e-atores.md`.

4. **Senha do usuário em texto puro.** `UserPreferences` grava a senha
   Moodle sem criptografia adicional no DataStore. Isso deve ser
   revisitado (ex.: Keychain no iOS) nas decisões de arquitetura, ou há
   alguma razão de negócio para manter o comportamento? —
   `domain/vocabulario-e-atores.md`, `technical/persistencia-e-dados-locais.md`.

5. **URL de produção da API de Certificados Externos.** Um comentário no
   código cita uma URL alternativa (`http://...:8080/`) divergente da
   constante realmente usada (HTTPS, sem porta). Qual é a URL de
   produção correta? — `technical/integracao-apis.md`.

6. **Expiração/validação local de sessão.** O app nunca expira a sessão
   localmente (`isLoggedIn` depende só de token não vazio). É aceitável
   manter esse comportamento no iOS? — `technical/persistencia-e-dados-locais.md`.

7. **Limpeza de dados no logout.** `logout()` limpa apenas o DataStore
   de sessão/perfil — cursos inscritos e notificações administrativas
   persistem no dispositivo entre usuários diferentes no mesmo aparelho.
   Isso é intencional? — `technical/persistencia-e-dados-locais.md`.

8. **Uso real do `WebViewScraper` no app mobile.** Confirmado que a
   lógica de scraping do backend Node foi portada para lá, mas não foi
   identificado, neste levantamento, qual tela/repositório do app
   efetivamente instancia e usa `WebViewScraper` em tempo de execução
   (os fluxos de formulário de inscrição e matéria de notícia parecem
   depender de scraping feito pelo **backend**, não pelo app). Precisa
   de investigação adicional de código antes de decidir se há algum
   equivalente necessário no iOS. — `technical/comportamentos-especificos-android.md`.

9. **Uso real do `WebViewPdfWriter`.** Mesma situação do item 8: existe
   no código, mencionado no README, mas seu ponto de uso real não foi
   confirmado neste levantamento. — `technical/comportamentos-especificos-android.md`.

10. **Confirmação de inscrição → notificação local.** Não foi confirmado
    neste levantamento se toda inscrição bem-sucedida efetivamente
    dispara `NotificationHelper.sendEnrollmentConfirmation` (o ponto de
    chamada exato em `CoursesScreen`/`CoursesViewModel` não foi lido). —
    `domain/funcionalidades-e-fluxos.md`.

11. **Campo `curso_credenciado` do Certificado Externo.** Não tem uso de
    UI identificado neste levantamento — é exibido/editável, ou é
    metadado administrativo não usado pelo app? —
    `models/modelos-de-dados.md`.

12. **Cobertura de teste da baseline.** Confirmado que só existem os
    testes de template (`ExampleUnitTest`, `ExampleInstrumentedTest`) —
    sem teste real de domínio. Isso deve pesar nas decisões de
    estratégia de teste do iOS (Fase 1/6) de que forma? —
    `technical/dependencias-e-plataforma.md`.

> Nenhuma destas perguntas foi respondida por suposição neste
> levantamento — todas permanecem em aberto para a Fase 0 (ou a fase
> pertinente) decidir, conforme instrução do usuário de preservar
> ambiguidades em vez de adivinhar.

## Resolvidas (Fase 0, Nível 1 — Domínio)

- **Pergunta 1 (nome institucional):** RESOLVIDA. Confirmado pelo
  VA-human: nome por extenso = "Escola do Poder Judiciário do Acre"
  (marca curta "ESJUD" mantida). Ver `research/DECISIONS.md`, D0008.
- **Pergunta 2 (funcionalidade "Cronograma"):** RESOLVIDA. Confirmado
  pelo VA-human: **fora de escopo** do produto iOS completo — o iOS
  replica o Android como ele existe hoje (sem Cronograma), não o README
  desatualizado. Ver `research/DECISIONS.md`, D0009.
- **Pergunta 4 (senha em texto puro):** RESOLVIDA. Confirmado pelo
  VA-human: o iOS usará **Keychain** (armazenamento seguro), divergindo
  deliberadamente da baseline Android por motivo de segurança. Ver
  `research/DECISIONS.md`, D0013.
- **Pergunta 3 (chave PAINEL_API_KEY):** RESOLVIDA. Tratada como
  segredo de baixo risco, mantida embutida no cliente iOS. Ver
  `research/DECISIONS.md`, D0015.
- **Pergunta 5 (URL/mecanismo de distribuição do certificado mTLS):**
  PARCIALMENTE RESOLVIDA. O mecanismo de distribuição (embutido no
  bundle do app) foi confirmado (D0014); a URL exata de produção da API
  de Certificados Externos (divergência entre comentário e constante no
  código) ainda é uma pendência técnica a verificar antes da Fase 1/5.
- **Pergunta 6 (expiração de sessão):** RESOLVIDA. Sem expiração local
  automática, replicando o Android. Ver `research/DECISIONS.md`, D0016.
- **Pergunta 7 (limpeza de dados no logout):** RESOLVIDA. O iOS limpará
  todos os dados locais no logout, divergindo do Android. Ver
  `research/DECISIONS.md`, D0017.
- **Decisões adicionais de Nível 2 (não eram perguntas desta lista, mas
  fecham constraints necessárias à Fase 0):** plataforma-alvo iOS 17+;
  sem prazo institucional rígido; backends existentes tratados como
  contratos fixos e imutáveis (nenhuma mudança de backend no escopo). Ver
  `research/DECISIONS.md`, D0010–D0012.
