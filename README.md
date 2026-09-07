# Pacote de Artefatos de Pesquisa — Aplicação da Pipeline IACDM na Reengenharia Android→iOS do ESJUDAC

## Sobre este repositório

Este repositório contém os artefatos de documentação de processo gerados durante a
aplicação da metodologia IACDM (*Interactive Adversarial Convergence Development
Methodology*) na reengenharia do aplicativo móvel institucional ESJUDAC (Escola do
Poder Judiciário do Acre / TJAC), da plataforma Android nativa (Kotlin) para iOS
nativo (Swift), conduzida com uso intensivo de IA generativa.

Este pacote acompanha o artigo *"Aplicação da Pipeline IACDM: Reengenharia de
Aplicativo Móvel Android para iOS com Uso de Vibe Coding"*, submetido a [venue a
confirmar]. Ele existe para permitir a **verificação independente** do processo
descrito no artigo — cada afirmação quantitativa do artigo (número de decisões,
fases, achados, testes) é rastreável a um registro específico neste pacote.

## O que este repositório NÃO contém

- **Código-fonte da aplicação iOS ou Android**: por se tratar de sistema
  institucional do TJAC operando sobre contratos de API de produção, o
  código-fonte não é disponibilizado publicamente.
- **Segredos, credenciais ou certificados**: nenhuma chave de API, senha,
  certificado ou arquivo de configuração sensível está presente neste pacote.
- **Dados pessoais reais**: um número de CPF de conta de teste institucional,
  originalmente presente nos registros brutos do estudo, foi substituído por
  `111.111.111-11` (sequência inválida perante o algoritmo oficial de dígitos
  verificadores, nunca emitida pela Receita Federal) em todas as ocorrências,
  preservando a legibilidade técnica dos registros sem expor dado real.

## Estrutura do pacote

```
research/
├── RESEARCH_LOG.md              # Diário de pesquisa cronológico (P0001-P0048)
├── DECISIONS.md                 # Registro de decisões (D0001-D0096)
├── GATES.md                     # Registro dos gates de convergência de cada fase
├── BASELINE.md                  # Identificação da baseline Android
├── BASELINE_MANIFEST.md         # Manifesto de hashes SHA-256 da baseline (sem conteúdo)
├── PROMPT_LOG/                  # Prompts individuais recebidos (P0001-P0048)
└── METRICS/
    ├── README.md
    ├── PARTIAL_RESULTS_SUMMARY.md
    ├── PARTIAL_RESULTS_CURRENT.md
    ├── PARTIAL_RESULTS_TABLE.csv    # Métricas com ID rastreável (M###)
    └── FINDINGS_CURRENT.csv         # Achados com ID rastreável (F-###)

specs/
├── domain/                      # Vocabulário, atores, funcionalidades
├── technical/                   # Arquitetura, dependências, integrações
├── models/                      # Modelos de dados
├── validation/                  # Critérios de validação e cobertura
├── datasets/                    # Fixtures de teste (reais/sintéticos, sanitizados)
├── design/                      # Matriz de cobertura de design
├── examples/                    # Exemplos de referência
└── references/                  # Lições aprendidas, rastreabilidade

metrics-scripts/
└── LaunchPerformanceTests.swift # Protocolo de medição de TTI (XCTest)
```

## Licença

O conteúdo textual deste repositório está licenciado sob
[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.pt_BR).

## Como citar

```bibtex
@dataset{IacdmEsjudDataset2026,
  author       = {Almeida, Allan Diego and Ferreira, Eduardo Souza and Costa, Catarina de Souza},
  title        = {{Research artifacts: IACDM pipeline applied to Android-to-iOS
                   mobile app reengineering (ESJUD case study)}},
  year         = {2026},
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.XXXXXXX}
}
```

*(DOI a ser preenchido após a publicação do depósito.)*
