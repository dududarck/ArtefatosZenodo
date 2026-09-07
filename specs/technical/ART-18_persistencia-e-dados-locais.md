# Persistência e Dados Locais — evidenciado a partir do Android (ESJUDAC)

> Ver legenda de marcadores em `../domain/vocabulario-e-atores.md`.
> Fonte: `data/local/*.kt`.

## Mecanismo de persistência usado

- **[FATO]** O app usa exclusivamente **AndroidX DataStore (Preferences)**
  para persistência local estruturada — não há uso de Room/SQLite nem de
  arquivos de banco de dados observado no código lido.
- **[FATO]** Três instâncias de DataStore, cada uma com seu próprio nome
  de arquivo lógico:
  1. `esjudac_prefs` (`UserPreferences.kt`) — sessão do usuário e perfil
     de inscrição.
  2. `enrolled_courses` (`EnrolledCoursesStore.kt`) — cursos em que o
     usuário se inscreveu, serializados manualmente como JSON dentro de
     uma única chave string.
  3. `admin_notifications` (`AdminNotificationsStore.kt`) — notificações
     administrativas recebidas, também serializadas como JSON em uma
     única chave string, mais um contador de não lidas.
- **[INFERÊNCIA]** O padrão de "serializar uma lista inteira como JSON em
  uma única chave" (em vez de usar um schema relacional) é uma escolha
  deliberada de simplicidade (evita Room), mas implica que toda leitura/
  escrita reprocessa a lista inteira — aceitável para os volumes de dados
  esperados (dezenas de cursos/notificações por usuário), mas é uma
  característica de implementação, não um requisito de domínio.

## `UserPreferences` (sessão + perfil)

Campos persistidos (nomes de chave conforme código):

| Chave | Conteúdo | Sensibilidade |
|---|---|---|
| `moodle_token` | Token de sessão do Moodle | Sensível (credencial de sessão) |
| `moodle_username` | Nome de usuário Moodle | — |
| `moodle_full_name`, `moodle_email`, `moodle_picture_url` | Perfil do usuário | Dado pessoal |
| `user_cpf` | CPF do usuário | Dado pessoal sensível (documento de identificação) |
| `moodle_user_id` | ID numérico do usuário no Moodle | — |
| `moodle_password` | **Senha do Moodle em texto puro** | **[FATO] Altamente sensível — ver nota de segurança em `../domain/vocabulario-e-atores.md`** |
| `profile_pcd`, `profile_genero`, `profile_raca`, `profile_vinculo`, `profile_ocupacao`, `profile_local`, `profile_setor` | Perfil reutilizado nas inscrições em curso | Dado pessoal (alguns são dados sensíveis conforme LGPD: raça, PCD) |
| `device_push_token` | Token do dispositivo para o painel de notificações (FCM ou UUID de fallback) | — |

- **[FATO]** `UserSession.isLoggedIn` é derivado apenas de `token` não
  vazio — não há expiração/validação local de token; a validade real só
  é conhecida quando uma chamada de API falha por autenticação.
- **[PERGUNTA-VA]** O app nunca invalida a sessão localmente por tempo;
  isso é aceitável para o produto iOS ou deve ser revisitado (ex.: refresh
  de token, expiração local)? Decisão pertence às fases de arquitetura,
  não a este levantamento.

## `EnrolledCoursesStore` (cursos inscritos, para lembretes)

- **[FATO]** Cada curso guarda: id, nome, área, modalidade, data da
  atividade, carga horária, local, `endEpochDay` (data de fim como dia
  epoch), `enrolledEpochDay` (data da inscrição), `lastNotifiedEpochDay`
  e `notificationsSent` — os três últimos existem para controlar a
  cadência dos lembretes locais, não para exibição direta ao usuário.
- **[FATO]** IDs vindos do Moodle usam prefixo `"moodle_"`; cursos
  inscritos localmente pelo app (via API ESJUD) não têm esse prefixo —
  usado para diferenciar a origem ao sincronizar com a lista atual do
  Moodle (`removeStalesMoodle`).
- **[FATO]** Expurgo automático de cursos expirados há mais de 30 dias
  (`pruneOld`), executado tanto pelo Worker periódico quanto,
  presumivelmente, em outros pontos de entrada do app.
- **[FATO]** `EnrolledCourse.parseEndDate` implementa um parser
  heurístico de datas em português (formatos "dd/MM/yyyy a dd/MM/yyyy",
  "MM/yyyy", nomes de mês por extenso em PT-BR) — evidência de que as
  datas retornadas pelos backends de curso/cronograma **não têm um
  formato único e estruturado**, exigindo tolerância a variação textual.
  Isso é uma restrição real do domínio (dados de origem heterogêneos),
  não uma escolha arbitrária de implementação.

## `AdminNotificationsStore` (notificações administrativas)

- **[FATO]** Guarda até 100 notificações mais recentes (`take(100)`
  aplicado ao inserir via push), com deduplicação por `id`.
- **[FATO]** Contador de não lidas é incrementado apenas por itens
  genuinamente novos (comparação de IDs), tanto ao sincronizar a lista
  completa via feed quanto ao inserir uma única notificação via push.

## Escopo e retenção de dados pessoais (observação transversal)

- **[FATO]** Dados pessoais (CPF, nome completo, e-mail, foto de perfil,
  senha) permanecem no dispositivo indefinidamente até `logout()` (que
  chama `context.dataStore.edit { it.clear() }` apenas no DataStore de
  `esjudac_prefs`) — os outros dois DataStores (`enrolled_courses`,
  `admin_notifications`) **não são limpos no logout**, conforme leitura
  do código de `AuthRepository.logout()`.
- **[AMBIGUIDADE]** Não está confirmado se isso é intencional (ex.:
  preservar lembretes de curso entre relogins do mesmo usuário no mesmo
  aparelho) ou uma lacuna, já que um segundo usuário no mesmo dispositivo
  herdaria notificações e cursos inscritos do usuário anterior.
  **[PERGUNTA-VA]** confirmar o comportamento esperado de limpeza de
  dados no logout para o produto iOS.
