# Cobertura de Premissas Numeradas — Fase 6

> BLOQUEIA o gate 6→7 porque `specs/technical/architecture.md` **numera**
> suas premissas (A-1..A-11). Uma linha por premissa: o teste que
> **falharia** se a premissa deixasse de valer no sistema construído,
> ou o motivo declarado de não haver um.
>
> "Uma premissa só está protegida quando um teste mede o seu colapso."
> Criticar a plausibilidade de uma premissa na Fase 2 não é o mesmo que
> medir se ela se mantém no sistema.

| id | Premissa | Teste que falha se a premissa cair | Observação |
|---|---|---|---|
| **A-1** | Os 5 backends são contratos fixos e imutáveis; nenhuma mudança de backend no escopo | **Sem teste de código** — é uma restrição de *processo/escopo*, não uma propriedade do binário. Protegida por `TC-1` em `criterios-de-validacao.md` (nenhum stub de teste inventa endpoint novo) e por revisão. Se um teste precisasse de um endpoint inexistente na baseline, a revisão pegaria. | Restrição de escopo (D0012). |
| **A-2** | O `.p12` mTLS pode ser embutido no bundle do app iOS | `BundledCertificateProviderTests` só roda no app target (não no Package) — **GAP no Package**. Compensado: a Fase 5 confirmou por `ls` no `.app` instalado que `cliente_api_esjud.p12` está fisicamente no bundle (D0073) e o smoke test P0 real exerceu chamadas mTLS com sucesso (Certidão/Cursos PASS). | Verificação empírica real já existe (Fase 5), fora do Package de teste. |
| **A-3** | O `painel-web` aceita `platform:"ios"` e envia push agnóstico de plataforma via Firebase Admin | **Sem teste no app iOS** — é propriedade do backend, verificada por leitura de `devicesRepo.js`/`push.js` na Fase 0 (D0021), não reexecutável aqui. O lado iOS que depende disso (registro de device / recepção) está coberto indiretamente por `AdminFeedTests` (o feed é o caminho garantido independente do push). | Propriedade de backend fixo; fora do alcance de teste do cliente. |
| **A-4** | Ausência de bloco `apns` no payload não impede a entrega ao Firebase SDK iOS com comportamento padrão | **Sem teste** — depende de entrega real de push (débito D0051, sem `GoogleService-Info.plist`). Registrado como item de escopo pendente para a Fase 6/7, nunca "concluído". | Dívida técnica externa. |
| **A-5** | iOS não garante execução periódica em segundo plano; a estratégia é notificação local agendada por data | `CourseRemindersTests` verifica que o agendamento é derivado de `endEpochDay`/`daysRemaining` e da cadência `shouldNotify` (dados + data), **não** de um tick periódico. `DateParsingTests` protege o cálculo da data-alvo. Se o módulo passasse a depender de `BGTaskScheduler` periódico, `scheduleReminders` mudaria de assinatura e os testes de `trackEnrollment`/`prune` quebrariam. | `TC-3`. |
| **A-6** | Logout limpa **todos** os dados locais do usuário (diverge do Android) | `AuthTests.logout_clears_keychain_account_and_localstore_keys` (VAL-5) — após `logout()`, `currentSession()` devolve `nil` e as chaves `auth.currentAccount`/`auth.sessionMeta` somem da `LocalStore` isolada. A orquestração da limpeza de `course-reminders`/`admin-feed` é do app-shell (M-13) — coberta por **teste manual** (UC-11, PASS em D0073). | Parte unit + parte manual. |
| **A-7** | Sessão não expira localmente por tempo — só logout manual ou falha de auth | `AuthTests.currentSession_returns_session_when_stores_populated` não tem nenhuma checagem de validade temporal; não existe TTL no código. Se alguém adicionasse expiração por timestamp em `currentSession()`, um teste com meta "antiga" ainda deveria restaurar — e passaria a falhar. | Cobertura por ausência de lógica de expiração + teste manual VAL-4. |
| **A-8** | A chave `X-Api-Key` do Painel é segredo de baixo risco, aceitável embutir no cliente | `NetworkingTests.apiKeyHeader_injects_x_api_key` (VAL-8) protege o **mecanismo** (a chave vai no header correto). O julgamento de risco em si é decisão do VA-human (D0015), não testável. | Mecanismo testado; risco = decisão humana. |
| **A-9** | A busca por CPF na API de Certificado Externo retorna uma pessoa única/inequívoca | `CertExtTests.obterPessoa_success_single_person` decodifica `data` como **um** objeto `PessoaExtData` (não array). Se a API passasse a retornar múltiplas pessoas, `ObterPessoaExtResponse.data` (objeto único) falharia a decodificação — o teste com um fixture "lista" falharia, tornando a quebra da premissa visível. | Aceito na Fase 3 (AS-04). |
| **A-10** | A preservação de estado padrão do SwiftUI basta para sobreviver à suspensão do app durante a seleção de arquivo PDF | **Sem teste automático** (sem automação de UI — decisão P0032). Coberto por **teste manual exploratório**: edge case "interromper o app durante o seletor de arquivo do Certificado Externo e retornar" no roteiro do Step 5. | Aceito na Fase 3 (UX-02). |
| **A-11** | Validação de trust do servidor via mecanismo padrão do SO (sem pinning) é suficiente para o perfil de risco | **Sem teste de regressão** — é a aceitação explícita do achado SE-02. Não há pinning a proteger. Um teste não pode "medir" a ausência de um risco aceito; o que se pode afirmar é que nenhum código de teste desabilita a validação de trust (nenhum `URLProtocol` stub mexe em `serverTrust`; nenhum `NSAllowsArbitraryLoads`). | Decisão de não-implementação (D pós-Fase 3). |

## Resumo

- Premissas com teste que mede o colapso: **A-5, A-6, A-7, A-8, A-9**
  (+ mecanismo parcial), e A-2 por evidência empírica da Fase 5.
- Premissas sem teste de código, com motivo declarado: **A-1** (escopo),
  **A-3/A-4** (backend fixo / débito externo D0051), **A-10** (teste
  manual), **A-11 / SE-02** (não-implementação aceita).
