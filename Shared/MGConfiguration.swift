import Foundation

public struct MGConfiguration: Identifiable {
    
    public static let currentStoreKey = "XRAY_CURRENT"
    
    public static let key = FileAttributeKey("NSFileExtendedAttributes")
    
    public let id: String
    public let creationDate: Date
    public let attributes: Attributes
    
    init(uuidString: String) throws {
        guard let uuid = UUID(uuidString: uuidString) else {
            throw NSError.newError("配置文件不存在")
        }
        let folderURL = MGConstant.configDirectory.appending(component: "\(uuid.uuidString)", directoryHint: .isDirectory)
        guard FileManager.default.fileExists(atPath: folderURL.path(percentEncoded: false)) else {
            throw NSError.newError("配置文件不存在")
        }
        let attributes = try FileManager.default.attributesOfItem(atPath: folderURL.path(percentEncoded: false))
        guard let creationDate = attributes[.creationDate] as? Date,
              let extends = attributes[MGConfiguration.key] as? [String: Data],
              let data = extends[MGConfiguration.Attributes.key] else {
            throw NSError.newError("配置文件解析失败")
        }
        self.id = uuid.uuidString
        self.creationDate = creationDate
        self.attributes = try JSONDecoder().decode(MGConfiguration.Attributes.self, from: data)
    }
}

extension MGConfiguration {
    
    public struct Attributes: Codable {
        
        public static let key = "Configuration.Attributes"
        
        public let alias: String
        public let source: URL
        public let leastUpdated: Date
    }
}

extension MGConfiguration {
    
    public enum ProtocolType: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case vless, vmess, trojan, shadowsocks
        
        public var description: String {
            switch self {
            case .vless:
                return "VLESS"
            case .vmess:
                return "VMess"
            case .trojan:
                return "Trojan"
            case .shadowsocks:
                return "Shadowsocks"
            }
        }
    }
    
    public enum Transport: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case tcp, kcp, ws, http, quic, grpc

        public var description: String {
            switch self {
            case .tcp:
                return "TCP"
            case .kcp:
                return "mKCP"
            case .ws:
                return "WebSocket"
            case .http:
                return "HTTP/2"
            case .quic:
                return "QUIC"
            case .grpc:
                return "gRPC"
            }
        }
    }
    
    public enum Encryption: String, Identifiable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case aes_128_gcm        = "aes-128-gcm"
        case chacha20_poly1305  = "chacha20-poly1305"
        case auto               = "auto"
        case none               = "none"
        case zero               = "zero"
        
        public var description: String {
            switch self {
            case .aes_128_gcm:
                return "AES-128-GCM"
            case .chacha20_poly1305:
                return "Chacha20-Poly1305"
            case .auto:
                return "Auto"
            case .none:
                return "None"
            case .zero:
                return "Zero"
            }
        }
                
        public static let vmess: [MGConfiguration.Encryption] = [.chacha20_poly1305, .aes_128_gcm, .auto, .none, .zero]
        public static let quic:  [MGConfiguration.Encryption] = [.chacha20_poly1305, .aes_128_gcm, .none]
    }
    
    public enum Security: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case none, tls, reality
        
        public var description: String {
            switch self {
            case .none:
                return "None"
            case .tls:
                return "TLS"
            case .reality:
                return "Reality"
            }
        }
    }
    
    public enum HeaderType: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case none           = "none"
        case srtp           = "srtp"
        case utp            = "utp"
        case wechat_video   = "wechat-video"
        case dtls           = "dtls"
        case wireguard      = "wireguard"
            
        public var description: String {
            switch self {
            case .none:
                return "None"
            case .srtp:
                return "SRTP"
            case .utp:
                return "UTP"
            case .wechat_video:
                return "Wecaht Video"
            case .dtls:
                return "DTLS"
            case .wireguard:
                return "Wireguard"
            }
        }
    }
    
    public enum Flow: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case none                       = "none"
        case xtls_rprx_vision           = "xtls-rprx-vision"
        case xtls_rprx_vision_udp443    = "xtls-rprx-vision-udp443"
        
        public var description: String {
            switch self {
            case .none:
                return "None"
            case .xtls_rprx_vision:
                return "XTLS-RPRX-Vision"
            case .xtls_rprx_vision_udp443:
                return "XTLS-RPRX-Vision-UDP443"
            }
        }
    }
    
    public enum Fingerprint: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case chrome     = "chrome"
        case firefox    = "firefox"
        case safari     = "safari"
        case ios        = "ios"
        case android    = "android"
        case edge       = "edge"
        case _360       = "360"
        case qq         = "qq"
        case random     = "random"
        case randomized = "randomized"
        
        public var description: String {
            switch self {
            case .chrome:
                return "Chrome"
            case .firefox:
                return "Firefox"
            case .safari:
                return "Safari"
            case .ios:
                return "iOS"
            case .android:
                return "Android"
            case .edge:
                return "Edge"
            case ._360:
                return "360"
            case .qq:
                return "QQ"
            case .random:
                return "Random"
            case .randomized:
                return "Randomized"
            }
        }
    }
    
    public enum ALPN: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
        
        case h2         = "h2"
        case http1_1    = "http/1.1"
        
        public var description: String {
            switch self {
            case .h2:
                return "H2"
            case .http1_1:
                return "HTTP/1.1"
            }
        }
    }
    
    public struct StreamSettings: Codable {
        public struct TLS: Codable {
            public var serverName: String = ""
            public var allowInsecure: Bool = false
            public var alpn: [ALPN] = ALPN.allCases
            public var fingerprint: Fingerprint = .chrome
        }
        public struct Reality: Codable {
            public var show: Bool = false
            public var fingerprint: Fingerprint = .chrome
            public var serverName: String = ""
            public var publicKey: String = ""
            public var shortId: String = ""
            public var spiderX: String = ""
        }
        public struct TCP: Codable {
            public struct Header: Codable {
                public var type: HeaderType = .none
            }
            public var header = Header()
        }
        public struct KCP: Codable {
            public struct Header: Codable {
                public var type: HeaderType = .none
            }
            public var mtu: Int = 1350
            public var tti: Int = 20
            public var uplinkCapacity: Int = 5
            public var downlinkCapacity: Int = 20
            public var congestion: Bool = false
            public var readBufferSize: Int = 1
            public var writeBufferSize: Int = 1
            public var header = Header()
            public var seed: String = ""
        }
        public struct WS: Codable {
            public var path: String = "/"
            public var headers: [String: String] = [:]
        }
        public struct HTTP: Codable {
            public var host: [String] = []
            public var path: String = "/"
        }
        public struct QUIC: Codable {
            public struct Header: Codable {
                public var type: HeaderType = .none
            }
            public var security = Encryption.none
            public var key: String = ""
            public var header = Header()
        }
        public struct GRPC: Codable {
            public var serviceName: String = ""
            public var multiMode: Bool = false
        }
    }
    
    public struct VLESS: Codable {
        public struct User: Codable {
            public var id: String = ""
            public var encryption: String = "none"
            public var flow = Flow.none
        }
        public var address: String = ""
        public var port: Int = 443
        public var users: [User] = [User()]
    }
    
    public struct VMess: Codable {
        public struct User: Codable {
            public var id: String = ""
            public var alterId: Int = 0
            public var security = Encryption.auto
        }
        public var address: String = ""
        public var port: Int = 443
        public var users: [User] = [User()]
    }
    
    public struct Trojan: Codable {
        public struct Server: Codable {
            public var address: String = ""
            public var port: Int = 443
            public var password: String = ""
            public var email: String = ""
        }
        public var servers: [Server] = [Server()]
    }
    
    public struct Shadowsocks: Codable {
        public enum Method: String, Identifiable, CustomStringConvertible, Codable, CaseIterable {
            public var id: Self { self }
            case _2022_blake3_aes_128_gcm       = "2022-blake3-aes-128-gcm"
            case _2022_blake3_aes_256_gcm       = "2022-blake3-aes-256-gcm"
            case _2022_blake3_chacha20_poly1305 = "2022-blake3-chacha20-poly1305"
            case aes_256_gcm                    = "aes-256-gcm"
            case aes_128_gcm                    = "aes-128-gcm"
            case chacha20_poly1305              = "chacha20-poly1305"
            case chacha20_ietf_poly1305         = "chacha20-ietf-poly1305"
            case plain                          = "plain"
            case none                           = "none"
            public var description: String {
                switch self {
                case ._2022_blake3_aes_128_gcm:
                    return "2022-Blake3-AES-128-GCM"
                case ._2022_blake3_aes_256_gcm:
                    return "2022-Blake3-AES-256-GCM"
                case ._2022_blake3_chacha20_poly1305:
                    return "2022-Blake3-Chacha20-Poly1305"
                case .aes_256_gcm:
                    return "AES-256-GCM"
                case .aes_128_gcm:
                    return "AES-128-GCM"
                case .chacha20_poly1305:
                    return "Chacha20-Poly1305"
                case .chacha20_ietf_poly1305:
                    return "Chacha20-ietf-Poly1305"
                case .none:
                    return "None"
                case .plain:
                    return "Plain"
                }
            }
        }
        public struct Server: Codable {
            public var address: String = ""
            public var port: Int = 443
            public var password: String = ""
            public var email: String = ""
            public var method = Method.none
            public var uot: Bool = false
            public var level: Int = 0
        }
        public var servers: [Server] = [Server()]
    }
}

extension MGConfiguration {
    
    public struct Model: Codable {
        
        public var protocolType : MGConfiguration.ProtocolType
        public var vless        : MGConfiguration.VLESS?
        public var vmess        : MGConfiguration.VMess?
        public var trojan       : MGConfiguration.Trojan?
        public var shadowsocks  : MGConfiguration.Shadowsocks?
        
        public var network  : MGConfiguration.Transport
        public var tcp      : MGConfiguration.StreamSettings.TCP? = nil
        public var kcp      : MGConfiguration.StreamSettings.KCP? = nil
        public var ws       : MGConfiguration.StreamSettings.WS? = nil
        public var http     : MGConfiguration.StreamSettings.HTTP? = nil
        public var quic     : MGConfiguration.StreamSettings.QUIC? = nil
        public var grpc     : MGConfiguration.StreamSettings.GRPC? = nil
        
        public var security : MGConfiguration.Security
        public var tls      : MGConfiguration.StreamSettings.TLS? = nil
        public var reality  : MGConfiguration.StreamSettings.Reality? = nil
    }
}

extension MGConfiguration {
    
    public enum RouteDomainStrategy: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
                
        case asIs, ipIfNonMatch, ipOnDemand
        
        public var description: String {
            switch self {
            case .asIs:
                return "AsIs"
            case .ipIfNonMatch:
                return "IPIfNonMatch"
            case .ipOnDemand:
                return "IPOnDemand"
            }
        }
    }
    
    public enum RoutePredefinedRule: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        
        public var id: Self { self }
                
        case global, rule, direct
        
        public var description: String {
            switch self {
            case .global:
                return "全局"
            case .rule:
                return "规则"
            case .direct:
                return "直连"
            }
        }
    }
}
