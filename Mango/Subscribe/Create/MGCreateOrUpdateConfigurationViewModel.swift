import Foundation

final class MGCreateOrUpdateConfigurationViewModel: ObservableObject {
    
    @Published var vless        = MGConfiguration.VLESS()
    @Published var vmess        = MGConfiguration.VMess()
    @Published var trojan       = MGConfiguration.Trojan()
    @Published var shadowsocks  = MGConfiguration.Shadowsocks()
    
    @Published var transport    = MGConfiguration.Transport.tcp
    @Published var tcp          = MGConfiguration.StreamSettings.TCP()
    @Published var kcp          = MGConfiguration.StreamSettings.KCP()
    @Published var ws           = MGConfiguration.StreamSettings.WS()
    @Published var http         = MGConfiguration.StreamSettings.HTTP()
    @Published var quic         = MGConfiguration.StreamSettings.QUIC()
    @Published var grpc         = MGConfiguration.StreamSettings.GRPC()
    
    @Published var security = MGConfiguration.Security.none
    @Published var tls      = MGConfiguration.StreamSettings.TLS()
    @Published var reality  = MGConfiguration.StreamSettings.Reality()
        
    @Published var descriptive: String = ""
    
    let id: UUID
    let protocolType: MGConfiguration.ProtocolType
    
    init(id: UUID, descriptive: String, protocolType: MGConfiguration.ProtocolType, configurationModel: MGConfiguration.Model?) {
        self.id = id
        self.protocolType = protocolType
        self.descriptive = descriptive
        
        guard let configurationModel = configurationModel else {
            return
        }
        
        configurationModel.vless.flatMap { self.vless = $0 }
        configurationModel.vmess.flatMap { self.vmess = $0 }
        configurationModel.trojan.flatMap { self.trojan = $0 }
        configurationModel.shadowsocks.flatMap { self.shadowsocks = $0 }
        
        self.transport = configurationModel.network
        configurationModel.tcp.flatMap { self.tcp = $0 }
        configurationModel.kcp.flatMap { self.kcp = $0 }
        configurationModel.ws.flatMap { self.ws = $0 }
        configurationModel.http.flatMap { self.http = $0 }
        configurationModel.quic.flatMap { self.quic = $0 }
        configurationModel.grpc.flatMap { self.grpc = $0 }
        
        self.security = configurationModel.security
        configurationModel.tls.flatMap { self.tls = $0 }
        configurationModel.reality.flatMap { self.reality = $0 }
    }
    
    func save() throws {
        let folderURL = MGConstant.configDirectory.appending(component: "\(self.id.uuidString)")
        let attributes = MGConfiguration.Attributes(
            alias: descriptive.trimmingCharacters(in: .whitespacesAndNewlines),
            source: URL(string: "\(protocolType.rawValue)://")!,
            leastUpdated: Date()
        )
        if FileManager.default.fileExists(atPath: folderURL.path(percentEncoded: false)) {
            try FileManager.default.setAttributes([
                MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]
            ], ofItemAtPath: folderURL.path(percentEncoded: false))
        } else {
            try FileManager.default.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true,
                attributes: [
                    MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]
                ]
            )
        }
        let destinationURL = folderURL.appending(component: "config.json")
        let data = try JSONEncoder().encode(self.createConfigurationModel())
        FileManager.default.createFile(atPath: destinationURL.path(percentEncoded: false), contents: data)
    }
    
    private func createConfigurationModel() -> MGConfiguration.Model {
        var model = MGConfiguration.Model(
            protocolType: self.protocolType,
            network: self.transport,
            security: self.security
        )
        switch self.protocolType {
        case .vless:
            model.vless = self.vless
        case .vmess:
            model.vmess = self.vmess
        case .trojan:
            model.trojan = self.trojan
        case .shadowsocks:
            model.shadowsocks = self.shadowsocks
        }
        switch self.transport {
        case .tcp:
            model.tcp = self.tcp
        case .kcp:
            model.kcp = self.kcp
        case .ws:
            model.ws = self.ws
        case .http:
            model.http = self.http
        case .quic:
            model.quic = self.quic
        case .grpc:
            model.grpc = self.grpc
        }
        switch self.security {
        case .none:
            break
        case .tls:
            model.tls = self.tls
        case .reality:
            model.reality = self.reality
        }
        return model
    }
}
