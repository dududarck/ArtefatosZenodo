# Modelos de Dados — evidenciado a partir do Android (ESJUDAC)

> Ver legenda de marcadores em `../domain/vocabulario-e-atores.md`. Estes
> são os modelos de dados **tal como existem no Kotlin da baseline**
> (`data/model/*.kt`, `data/remote/*ApiModels.kt`) — apresentados aqui
> como evidência para a modelagem do domínio que será decidida nas fases
> seguintes, não como o esquema definitivo do iOS.

## Sessão do usuário — `UserSession`

| Campo | Tipo (Kotlin) | Observação |
|---|---|---|
| token | String | Token de sessão Moodle |
| username, fullName, email, pictureUrl | String | Perfil |
| cpf | String | Documento de identificação |
| moodleUserId | Long | ID no Moodle |
| password | String | **Senha em texto puro — ver nota de segurança** |

Derivado: `isLoggedIn` = `token.isNotEmpty()`.

## Curso disponível para inscrição — `Course`

`index, periodo, curso, area, modalidade, dataAtividade, projeto,
publico, cargaHoraria, vagas, local, urlFragment?` — todos `String`
exceto `index: Int`. Mapeado a partir de `CursoApiItem` (API), com
limpeza de texto no campo `curso` (remoção de prefixo/sufixo).

## Curso inscrito, persistido localmente — `EnrolledCourse`

`id, nome, area, modalidade, dataAtividade, cargaHoraria, local` (String)
+ `endEpochDay, enrolledEpochDay, lastNotifiedEpochDay: Long`,
`notificationsSent: Int`. Campos derivados: `isStillActive`,
`daysRemaining`. Contém lógica própria de parsing heurístico de datas em
PT-BR (`parseEndDate`).

## Certificado — `Certificate`

`index: Int, pessoa, periodo, atividade, tipo: String`. **[FATO]** campo
`pessoa` sempre vazio na prática (API não o preenche).

## Certidão gerada — `CertidaoGerada` (não persistido, resultado de operação)

`pdfBytes: ByteArray, numero: String?, nomePessoa: String?,
totalCursos: Int?, totalHoras: Double?` — os quatro últimos vêm de
headers HTTP customizados da resposta, não do corpo.

## Notícia — `Noticia` / `MateriaCompleta` / `ImagemItem`

- `Noticia`: `titulo, url, data, imagemPrincipal?, resumo?,
  categorias: List<String>`.
- `MateriaCompleta`: `titulo, url, dataPublicacao, autor?, descricao?,
  imagemPrincipal?, conteudoHTML: String, imagens: List<ImagemItem>`.
- `ImagemItem`: `src, alt, legenda?`.

## Notificação administrativa — `AdminNotification`

`id, title, message, type (padrão "comunicado"), target (padrão "all"),
targetLabel (padrão "Todos os usuários"), actionUrl?, createdAt,
createdBy (padrão "ESJUD")` — todos `String`.

**[INFERÊNCIA]** os valores padrão de `type`/`target` sugerem um esquema
de segmentação de destinatários no painel administrativo (por tipo de
comunicado e por público-alvo) que não é totalmente exercido pelo app
mobile (que apenas exibe o que recebe) — o esquema completo de
segmentação vive no `painel-web`, fora do escopo desta baseline.

## Modelos do Moodle — `MoodleTokenResponse`, `MoodleSiteInfo`, `MoodleAutoLoginKey`, `MoodleUserCourse`

Ver `../technical/integracao-apis.md` para os endpoints correspondentes.
Ponto notável: `MoodleUserCourse` traz datas em **epoch segundos**
(padrão Moodle), convertidas para **epoch dias** (`endEpochDay`) para
uniformizar com `EnrolledCourse`.

## Modelos do formulário de inscrição — `FormularioInscricaoResponse` e relacionados

Estrutura condicional documentada em comentário no próprio código-fonte
(tabela de regras de exibição por vínculo) — reproduzida aqui como
evidência direta:

| Vínculo | Campo de localização exibido | Campo de ocupação exibido |
|---|---|---|
| Não (`vinculo = N`) | `local.label` / `local.opcoes` | `ocupacaoSemVinculo` |
| Sim (`vinculo = S`) | `setor.label` / `setor.opcoes` | `ocupacaoComVinculo` |

Campo `lotacao` é retornado pela API mas **não é exibido no app**
(confirmado por comentário no código) — evidência de que o contrato da
API é mais amplo do que o que a UI atual utiliza.

## Modelos de Certificado Externo — `CertExtApiModels.kt`

- `ObterPessoaExtResponse`: `status: Boolean, data: PessoaExtData?,
  message: String?`. `PessoaExtData`: `nomePessoa, cpfPessoa: String`
  (JSON: `nome_pessoa`, `cpf_pessoa`).
- `ListarCertExtResponse`: `status: Boolean, data: List<CertExtItem>`.
- `CertExtItem`: `idCertificado: Int, nomeCurso: String,
  cargaHoraria: Int, nomeInstituicao: String, cursoCredenciado: String
  (padrão "N"), arquivoUrl: String, idSituacao: Int (padrão 1),
  situacao: String, parecer: String?, dataCadastro: String`. Derivado:
  `podeExcluir = (idSituacao == 1)` — **[FATO]** confirma exatamente a
  regra de negócio já citada em `../domain/funcionalidades-e-fluxos.md`
  ("só pode excluir certificado em análise").
- `RegistrarCertExtResponse`: `status: Boolean, reason: String?,
  errors: List<String>?, message: String?`.
- `ExcluirCertExtResponse`: `status: Boolean, message: String?`.
- **[AMBIGUIDADE]** `curso_credenciado` (String "S"/"N", inferido pelo
  padrão "N") não tem uso identificado em nenhuma tela lida até agora —
  **[PERGUNTA-VA]** confirmar se é exibido/editável na UI ou é um campo
  de metadado administrativo não utilizado pelo app mobile.

## Modelos de Certidão de Cursos — `CertidaoApiModels.kt`

- `ValidateCertidaoResponse`: `success, valida: Boolean,
  certificateNumber: String?, person: CertidaoPerson?,
  summary: CertidaoSummary?, message: String?, validatedAt: String?`.
- `CertidaoPerson`: `nome, cpf: String`. `CertidaoSummary`:
  `totalCourses: Int, totalHours: Double`.
- `PeriodoConfig` (modelo de domínio local, não vindo da API): três
  modos de período — `RETROATIVO` (N meses para trás, padrão 24),
  `ANO_ESPECIFICO` (um ano), `MES_ESPECIFICO` (mês+ano) — cada modo
  serializa de forma diferente para a API (`toApiValue()`): número
  (retroativo) ou string (`"AAAA"` ou `"AAAA-MM"`). **[FATO]** essa é a
  única enumeração de "tipo de período" observada na baseline; qualquer
  UI de seleção de período no iOS precisa cobrir os três modos para ter
  paridade funcional, mas a forma de apresentação é decisão de Fase 1.

## Resultado genérico de UI — `UiResult<T>`

`sealed interface` com `Idle`, `Loading`, `Success(data: T)`,
`Error(message: String)` — padrão de máquina de estados usado por
praticamente todos os ViewModels para representar o ciclo de vida de uma
operação assíncrona. **[INFERÊNCIA]** este é um padrão de apresentação
(equivalente a um enum associado / result type), não um modelo de
domínio — mas é relevante citá-lo porque molda a forma de todas as telas
e pode informar a escolha de padrão de estado de UI no SwiftUI (ex.:
enum com casos associados, `@Observable`/`ObservableObject`), sem que
isso seja uma decisão tomada aqui.
