# Cobertura de Achados Críticos (🔴) — Fase 6

> BLOQUEIA o gate 6→7 enquanto houver 🔴 sem linha aqui. Uma linha por
> achado crítico da matriz de cobertura da Fase 2
> (`specs/design/coverage-matrix.md`), com o teste que pegaria sua
> regressão **ou** o motivo declarado de não haver um.
>
> Os 8 críticos e suas resoluções V(1)→V(2) estão registrados na
> decisão de Fase 3 (`research/RESEARCH_LOG.md`, `research/DECISIONS.md`)
> e em `specs/technical/architecture.md` § "Resolução dos achados da
> Fase 2".

| 🔴 id | Achado | Resolução V(2) | Teste de regressão | Detecção (mutação que faria o teste falhar) |
|---|---|---|---|---|
| **AS-02** | `push-transport`: init do Firebase pode falhar e derrubar o recebimento de notificações | Falha de init degrada para modo somente-feed (`admin-feed` continua funcionando via polling) | `AdminFeedTests.pollIfStale_refetches_when_stale` + `AdminFeedTests.fetchFeed_merges_and_counts_unread` — provam que o caminho de feed/polling entrega conteúdo **sem** qualquer dependência de `push-transport`/Firebase. Integração real do bridge Firebase = **débito D0051** (sem `GoogleService-Info.plist`), fora do gate. | Se `pollIfStale` passasse a exigir um token de push para buscar, ou se `fetchFeed` só populasse a store quando `push-transport` estivesse inicializado, os testes falhariam. |
| **AR-03** | `persistence`: risco de gravar dado sensível na store não segura | `SecureStore` aceita só `Credential`; `LocalStore` genérico `<T: Codable>` sem sobrecarga para `Credential` — separação garantida em compilação | `PersistenceTests.localStore_roundtrip` + `PersistenceTests.persistedSessionMeta_never_contains_secret` (VAL-6/VAL-39). A separação de tipos em si é verificada pelo **compilador** (não há API para passar `Credential` a `LocalStore`). | Se alguém adicionasse `extension LocalStore { func save(_ c: Credential) }` ou incluísse `token`/`password` em `PersistedSessionMeta`, o teste de "meta sem segredo" falharia e a revisão de tipos pegaria a sobrecarga. |
| **SE-01** | `persistence`: Keychain sem classe de acessibilidade explícita | `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` explícito em `SecureStore.save` | **Sem teste automático** — a API de teste (sem device/simulador com Keychain provisionado de forma estável em CI) não relê o atributo `kSecAttrAccessible` de volta. Verificado por **revisão de código** (VAL-40) e, indiretamente, pelo teste manual VAL-4 (sessão sobrevive a relançamento após primeiro unlock). | N/A (sem teste); mitigação: o literal está numa única linha de `SecureStore.save`, coberta por revisão no gate. |
| **SE-02** | `networking`: sem certificate pinning adicional (risco de MITM com CA comprometida) | **Aceito** com justificativa KISS/YAGNI → vira a premissa **A-11** (validação de trust via mecanismo padrão do SO é suficiente para o perfil de risco) | **Sem teste de regressão** — é uma decisão de *não* implementar pinning, aceita explicitamente pelo VA-human na Fase 3. Não há comportamento novo a proteger. Coberto por `premise-coverage.md` (A-11). | N/A — achado aceito, não resolvido por código. |
| **RS-01** | `networking`/`courses`/`news`: chamadas longas (Puppeteer-backed) sem timeout/cancelamento explícito | `execute`/`executeRaw` recebem `timeout` por chamada e repassam ao `URLRequest`; endpoints Puppeteer-backed passam 30s explícito | `NetworkingTests.timeout_is_forwarded_to_urlrequest` (VAL-10) + `NetworkingTests.http_error_and_transport_error_paths` (o `URLProtocol` stub simula erro de transporte e o resultado é `NetworkError.transport`). Cancelamento estruturado é herdado de `session.data(for:)` (Swift Concurrency). | Se `execute` ignorasse o parâmetro `timeout` (ex.: `URLRequest(url:)` sem `timeoutInterval:`), o teste de repasse falharia. |
| **RS-03** | `networking`: falha de certificado mTLS degrada silenciosamente como erro HTTP genérico (comportamento da baseline Android) | `NetworkError.certificateUnavailable`, caso distinto; `.mTLSClient` sem provider ⇒ retorna esse erro **antes** de disparar a requisição | `NetworkingTests.mtls_without_provider_returns_certificateUnavailable` (VAL-7) — assere igualdade com `.certificateUnavailable` e **des**igualdade com qualquer `.httpStatus`/`.transport`. | Se o curto-circuito fosse removido (deixando a chamada mTLS seguir sem identidade e voltar como `.httpStatus(400)`), o teste falharia na asserção de tipo do erro. |
| **OB-01** | Ausência de diagnóstico estruturado em produção sem alterar código | Novo módulo **M-23 `diagnostics`** — fachada fina sobre `os_log`/`Logger`, zero dependência nova | `DiagnosticsTests.log_does_not_crash_for_all_modules_and_levels` — exercita `log(category:level:message:)` para cada `Module` e cada `LogLevel`. (M-23 foi **adicionado** na Fase 3, não removido — módulo vivo, precisa de teste.) | Se `Module`/`LogLevel` perdesse um caso ou `log` passasse a lançar/crashar para uma combinação, o teste falharia. |
| **LG-01** | `certidao`: campo `period` da API é polimórfico (número no modo retroativo, string em ano/mês) e estava implícito | `enum Period` com `Encodable` customizado cobrindo as 3 formas de fio | `CertidaoTests.period_encodes_number_for_retroativo`, `..._encodes_string_for_ano`, `..._encodes_year_month_string_for_mes`, `CertidaoTests.generate_body_shape` (VAL-17). | Se `Period.encode` passasse a emitir sempre string (ex.: `"\(meses)"` no caso retroativo), o teste `period_encodes_number_for_retroativo` falharia ao desserializar o valor como `Int`. |

## Notas

- **AR-01, SC-01, PE-02, RE-02, UX-02/A-10, UX-03, LG-02, LG-03,
  MEC-01, AS-04/A-9** são achados **🟡 importantes aceitos** na Fase 3,
  não críticos — não entram neste gate. Os que viraram premissa numerada
  (A-9, A-10) estão em `premise-coverage.md`.
- Nenhum 🔴 foi resolvido por **remoção de módulo** — portanto nenhuma
  linha usa "módulo removido na Fase 3" como justificativa.
