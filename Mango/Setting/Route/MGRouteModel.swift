import Foundation

extension MGConstant {
    public static let route: String = "XRAY_ROUTE_DATA"
}

public struct MGRouteModel: Codable, Equatable {
    
    public enum DomainStrategy: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        public var id: Self { self }
        case asIs           = "AsIs"
        case ipIfNonMatch   = "IPIfNonMatch"
        case ipOnDemand     = "IPOnDemand"
        public var description: String {
            return self.rawValue
        }
    }
    
    public enum DomainMatcher: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        public var id: Self { self }
        case hybrid, linear
        public var description: String {
            switch self {
            case .hybrid:
                return "Hybrid"
            case .linear:
                return "Linear"
            }
        }
    }
    
    public enum Outbound: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        public var id: Self { self }
        case direct, proxy, block
        public var description: String {
            switch self {
            case .direct:
                return "Direct"
            case .proxy:
                return "Proxy"
            case .block:
                return "Block"
            }
        }
    }
    
    public struct Rule: Codable, Equatable, Identifiable {
        
        public var id: UUID { self.__id__ }
        
        public var domainMatcher: DomainMatcher = .hybrid
        public var type: String = "field"
        public var domain: [String]?
        public var ip: [String]?
        public var port: String?
        public var sourcePort: String?
        public var network: String?
        public var source: [String]?
        public var user: [String]?
        public var inboundTag: [String]?
        public var `protocol`: [String]?
        public var attrs: String?
        public var outboundTag: Outbound = .direct
        public var balancerTag: String?
        
        public var __id__: UUID = UUID()
        public var __name__: String = ""
        public var __enabled__: Bool = false
        
        public var __defaultName__: String {
            "Rule_\(self.__id__.uuidString)"
        }
    }
    
    public struct Balancer: Codable, Equatable {
        var tag: String
        var selector: [String] = []
    }
    
    public var domainStrategy: DomainStrategy = .asIs
    public var domainMatcher: DomainMatcher = .hybrid
    public var rules: [Rule] = []
    public var balancers: [Balancer] = []
    
    public static let `default` = MGRouteModel()
    
    public static var current: MGRouteModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.route) else {
                return .default
            }
            return try JSONDecoder().decode(MGRouteModel.self, from: data)
        } catch {
            return .default
        }
    }
}
