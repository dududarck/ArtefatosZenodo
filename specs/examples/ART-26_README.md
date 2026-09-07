# Implementação de referência para porte (Fase 5/6, Tier 2)

A implementação de referência para qualquer porte de lógica/algoritmo
específico (ex.: parsing de datas em `EnrolledCourse.parseEndDate`,
regras de filtragem de cursos encerrados em
`MoodleEnrollmentRepository`, montagem de multipart em
`CertExtRepository`) é o código-fonte Android/Kotlin em:

`../../../ESJUDAC android referencia para criar ios/app/src/main/java/com/example/esjudac/`

Esse código **não é copiado para dentro de `specs/`** — é referenciado
por caminho, para evitar duplicação e desatualização. A identificação
reproduzível do estado exato desse código (hashes SHA-256 por arquivo)
está em `../../research/BASELINE_MANIFEST.md`; a leitura interpretativa
já feita está em `../domain/`, `../technical/` e `../models/`.

Ao portar um trecho específico na Fase 5/6, cite o arquivo e trecho de
origem (ex.: `EnrolledCourse.kt:44-76`) na spec/decisão correspondente,
para manter a rastreabilidade estabelecida em
`../references/rastreabilidade-baseline.md`.
