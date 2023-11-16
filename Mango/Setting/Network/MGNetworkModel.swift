import Foundation

extension MGConstant {
    public static let network: String = "NETWORK_DATA"
}

public struct MGNetworkModel: Codable, Equatable {
    
    public let hideVPNIcon: Bool
    public let ipv6Enabled: Bool
    public let inboundPort: Int
    
    public static let `default` = MGNetworkModel(
        hideVPNIcon: false,
        ipv6Enabled: false,
        inboundPort: 8080
    )
    
    public static var current: MGNetworkModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.network) else {
                return .default
            }
            return try JSONDecoder().decode(MGNetworkModel.self, from: data)
        } catch {
            return .default
        }
    }
}
