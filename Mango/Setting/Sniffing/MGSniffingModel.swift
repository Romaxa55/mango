import Foundation

extension MGConstant {
    public static let sniffing: String = "XRAY_SNIFFIN_DATA"
}

public struct MGSniffingModel: Codable, Equatable {
    
    public let enabled: Bool
    public let destOverride: [String]
    public let metadataOnly: Bool
    public let routeOnly: Bool
    public let excludedDomains: [String]
    
    public static let `default` = MGSniffingModel(
        enabled: true,
        destOverride: ["http", "tls"],
        metadataOnly: false,
        routeOnly: false,
        excludedDomains: []
    )
    
    public static var current: MGSniffingModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.sniffing) else {
                return .default
            }
            return try JSONDecoder().decode(MGSniffingModel.self, from: data)
        } catch {
            return .default
        }
    }
}
