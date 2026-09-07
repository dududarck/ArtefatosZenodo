import XCTest

final class LaunchPerformanceTests: XCTestCase {

    // TTI - Cold Start: mede o tempo até a app ficar interativa
    // a partir de uma inicialização fria (processo não residente em memória).
    func testColdStartTTI() throws {
        let app = XCUIApplication()
        // measure() por padrão faz 5 iterações (recomendado N=30 no protocolo:
        // ajuste com XCTMeasureOptions abaixo)
        let options = XCTMeasureOptions()
        options.iterationCount = 30

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)],
                options: options) {
            app.launch()
        }
        // Resultados: Xcode > Report Navigator > Test > clique na métrica
        // "Time to Initial Display" / "Time to Application Responsive"
        // Exportável via: xcrun xcresulttool get --format json --path <caminho.xcresult>
    }

    // TTI - Warm Start: app já foi carregada uma vez nesta sessão (processo residente)
    func testWarmStartTTI() throws {
        let app = XCUIApplication()
        app.launch()   // 1a chamada "aquece" o processo
        app.terminate()

        let options = XCTMeasureOptions()
        options.iterationCount = 30

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)],
                options: options) {
            app.activate()  // reativa em vez de cold-launch
        }
    }
}
