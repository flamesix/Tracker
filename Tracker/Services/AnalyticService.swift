import Foundation
import YandexMobileMetrica

struct AnalyticService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "b78cbe5e-5602-47ec-8772-f6e2f49671cb") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func reportEvent(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = ["event": event, "screen": screen]
        if let item = item {
            params["item"] = item
        }
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
    }
    
    func trackOpenScreen(screen: String) {
        reportEvent(event: "open", screen: screen)
    }
    
    func trackCloseScreen(screen: String) {
        reportEvent(event: "close", screen: screen)
    }
    
    func trackClick(screen: String, item: String) {
        reportEvent(event: "click", screen: screen, item: item)
    }
}
