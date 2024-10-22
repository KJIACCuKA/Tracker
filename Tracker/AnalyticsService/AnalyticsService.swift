import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "8f4335b9-9bb8-4a31-9f06-fa6af57b12c5") else {
            return
        }

        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
