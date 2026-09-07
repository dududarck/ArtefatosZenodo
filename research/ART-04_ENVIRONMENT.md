# Ambiente

Todos os valores abaixo foram coletados diretamente do sistema no momento
indicado, por meio de comandos de shell ou leitura de arquivos existentes.
Nenhum valor foi assumido, estimado ou inventado. Onde não foi possível
verificar objetivamente, o campo está marcado como **indisponível**.

Timestamp da coleta: 2026-08-26T21:52:28Z (UTC) até 2026-08-26T22:0xZ (UTC),
sessão única de coleta (ver `RESEARCH_LOG.md`, entrada P0001).

| Item | Valor | Método de verificação |
|---|---|---|
| macOS (ProductVersion) | 26.6.1 (Build 25G76) | `sw_vers` |
| Arquitetura/hardware | arm64 (Apple Silicon), kernel Darwin 25.6.0 | `uname -m`, `uname -a` |
| Claude Code (CLI) | 2.1.241 | `claude --version` |
| Modelo Claude ativo | Sonnet 5 (ID declarado: `claude-sonnet-5`) | Declarado pelo próprio ambiente/harness na sessão em curso (system prompt do agente); não verificado por fonte externa independente |
| Versus (server.js) | 0.16.4 | string `version: "0.16.4"` encontrada em `.versus/server.js` (leitura, sem execução) |
| Node.js | v26.7.0 | `node --version` |
| npm | 11.19.0 | `npm --version` |
| Git | 2.50.1 (Apple Git-155) | `git --version` |
| VS Code (app instalado) | 1.134.0 | `CFBundleShortVersionString` em `/Applications/Visual Studio Code.app/Contents/Info.plist` |
| VS Code CLI (`code`) | indisponível — comando `code` não encontrado no PATH da shell (`command not found: code`) | `code --version` (exit 127) |
| Caminho do workspace | `/Users/allandiegoafonsoalmeida/Documents/projeto converter android para ios` | `pwd` / caminho de invocação da sessão |
| Xcode (versão completa) | indisponível — apenas Command Line Tools instaladas, sem Xcode.app associado | `xcodebuild -version` retornou erro: "xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance" |
| Swift | swift-driver 1.148.6 / Apple Swift 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101), alvo arm64-apple-macosx26.0 | `swift --version` |

## Observações objetivas relevantes

- O ambiente de build iOS **não está completo** para gerar/rodar um app
  iOS real: há toolchain Swift (via Command Line Tools) mas não há Xcode
  instalado. Isso significa que, quando a implementação for permitida
  pela metodologia, XCTest e execução real em simulador/dispositivo via
  Xcode não estarão disponíveis até que o Xcode seja instalado — este é
  um pré-requisito de ambiente a ser satisfeito antes da Fase 5/6, não
  uma conclusão antecipada sobre a arquitetura do app.
- O identificador de "modelo Claude ativo" é uma informação autodeclarada
  pelo ambiente de execução (harness), não uma medição independente;
  está registrada como tal.
- Nenhum destes valores foi copiado de documentação genérica ou memória —
  todos foram obtidos por execução de comando ou leitura de arquivo nesta
  sessão.

## Itens solicitados e não aplicáveis/verificáveis nesta coleta

- Não há um artefato de versão separado para "Versus Claude" além da
  string de versão embutida em `.versus/server.js` citada acima.

## Atualização — 2026-08-29T21:40:49Z (retomada da Fase 5, P0007)

A Fase 5 havia sido pausada em 2026-08-29T21:38:32Z (D0029,
`RESEARCH_LOG.md` P0006) porque o ambiente, no momento da checagem
original (P0002), apontava o developer directory ativo para
`/Library/Developer/CommandLineTools` (apenas Command Line Tools, sem
Xcode.app), impedindo compilação real de um alvo iOS/SwiftUI.

O usuário instalou e configurou o Xcode completo. Nova verificação
objetiva executada nesta sessão:

| Item | Valor | Comando |
|---|---|---|
| Developer directory ativo | `/Applications/Xcode.app/Contents/Developer` (corrigido de `/Library/Developer/CommandLineTools`) | `xcode-select -p` |
| Xcode | 26.6 (Build 17F113) | `xcodebuild -version` |
| Swift | swift-driver 1.148.6 / Apple Swift 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101), alvo arm64-apple-macosx26.0 | `swift --version` |
| SDK iOS (dispositivo) | iOS 26.5 (`iphoneos26.5`) | `xcodebuild -showsdks` |
| SDK iOS (simulador) | iOS 26.5 (`iphonesimulator26.5`) | `xcodebuild -showsdks` |

**Conclusão:** verificação Automated-AV (compilação real via
`xcodebuild`) está agora genuinamente disponível neste ambiente. A
Fase 5 é retomada a partir deste timestamp (2026-08-29T21:40:49Z), conforme decisão
registrada em `research/DECISIONS.md` (D0030) e
`research/RESEARCH_LOG.md` (P0007).
