import Foundation

final class MGSniffingViewModel: ObservableObject {
    
    @Published var enabled: Bool
    @Published var destOverride: [String]
    @Published var metadataOnly: Bool
    @Published var routeOnly: Bool
    @Published var excludedDomains: [String]
    
    @Published var domain: String = ""
        
    init() {
        let model = MGSniffingModel.current
        self.enabled = model.enabled
        self.destOverride = {
            if model.destOverride.count == 1 && model.destOverride[0] == "fakedns+others" {
                return ["http", "tls", "quic", "fakedns"]
            } else {
                return model.destOverride
            }
        }()
        self.metadataOnly = model.metadataOnly
        self.routeOnly = model.routeOnly
        self.excludedDomains = model.excludedDomains
    }
    
    static func setupDefaultSettingsIfNeeded() {
        guard UserDefaults.shared.data(forKey: MGConstant.sniffing) == nil else {
            return
        }
        do {
            UserDefaults.shared.set(try JSONEncoder().encode(MGSniffingModel.default), forKey: MGConstant.sniffing)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func submitDomain() {
        let temp = self.domain.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            self.domain = ""
        }
        guard !temp.isEmpty else {
            return
        }
        guard !self.excludedDomains.contains(where: { $0 == temp }) else {
            return
        }
        self.excludedDomains.append(temp)
    }
    
    func delete(domain: String) {
        self.excludedDomains.removeAll(where: { $0 == domain })
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGSniffingModel(
                enabled: self.enabled,
                destOverride: {
                    if self.destOverride.count == 4 {
                        return ["fakedns+others"]
                    } else {
                        return self.destOverride
                    }
                }(),
                metadataOnly: self.metadataOnly,
                routeOnly: self.routeOnly,
                excludedDomains: self.excludedDomains
            )
            guard model != MGSniffingModel.current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.sniffing)
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
