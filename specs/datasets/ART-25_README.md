# Datasets de teste — ESJUD iOS (Fase 6)

Ground truth para o Test Map da Fase 6. Duas procedências, sempre
marcadas no cabeçalho de cada arquivo:

- **REAL** — corpo de resposta efetivamente observado contra o backend
  de **produção** durante os diagnósticos das Fases 5/6 (registrado em
  `research/RESEARCH_LOG.md` / `research/DECISIONS.md`, D0065–D0067,
  P0025–P0026). Nenhum dado pessoal real de terceiros: o CPF usado nos
  diagnósticos é o de teste `111.111.111-11` / pessoa "super teste",
  fornecido pelo próprio backend de homologação como registro de teste.
- **SINTÉTICO** — construído para casar exatamente com o contrato de
  DTO descrito em `specs/technical/integracao-apis.md`, quando não há
  amostra real capturada. Valores fictícios, estrutura fiel.

Os testes (`aplicativo ios/Tests/`) carregam estes arquivos pelo
caminho do repositório (derivado de `#filePath`), mantendo **uma única
cópia** — não há duplicação dentro do bundle de teste.

| Arquivo | Procedência | Usado por (VAL) |
|---|---|---|
| `certificados-producao-real.json` | REAL (D0066, `GET /api/certificados/11111111111`, 15 itens, 3045 bytes) | VAL-15 |
| `cert-ext-obter-pessoa-nao-encontrada.json` | REAL (D0065, 56 bytes, CPF sem máscara) | VAL-25 |
| `cert-ext-obter-pessoa-encontrada.json` | REAL (D0067, CPF com máscara) | VAL-25 |
| `cert-ext-listar.json` | SINTÉTICO (contrato `ListarCertExtResponse`, cobre `id_situacao` 1 e não-1) | VAL-21, VAL-22 |
| `cert-ext-item-minimo.json` | SINTÉTICO (campos opcionais ausentes) | VAL-22 |
| `moodle-token-sucesso.json` | SINTÉTICO (padrão Moodle `login/token.php`) | VAL-1 |
| `moodle-token-erro.json` | SINTÉTICO (HTTP 200 + `error`/`errorcode`) | VAL-1 |
| `moodle-site-info.json` | SINTÉTICO (`core_webservice_get_site_info`) | VAL-2, VAL-26 |
| `cursos.json` | SINTÉTICO (contrato `CursosApiResponse`, com "Curso: …." a limpar) | VAL-11 |
| `inscricao-formulario-409.json` | SINTÉTICO (corpo com `message`) | VAL-12 |
| `inscricao-formulario-sucesso.json` | SINTÉTICO (`FormularioInscricao` completo) | VAL-41 |
| `inscricao-formulario-400.json` | REAL (P0033, `cpf` vazio → HTTP 400, 87 B, corpo verbatim de produção) | VAL-42 |
| `noticias-lista.json` | SINTÉTICO (`NoticiasApiResponse`, paginada) | VAL-28 |
| `noticias-materia-nao-encontrada.json` | SINTÉTICO (`{success:true, noticia:null}`) | VAL-29 |
| `certidao-validate.json` | SINTÉTICO (`ValidateResult`) | VAL-19 |
| `admin-feed.json` | SINTÉTICO (`FeedResponse`, ids para dedup) | VAL-30, VAL-31 |
