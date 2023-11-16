import Foundation

final class MGLogViewModel: ObservableObject {
    
    @Published var accessLogEnabled: Bool
    @Published var dnsLogEnabled: Bool
    @Published var errorLogSeverity: MGLogModel.Severity
        
    init() {
        let model = MGLogModel.current
        self.accessLogEnabled = model.accessLogEnabled
        self.dnsLogEnabled = model.dnsLogEnabled
        self.errorLogSeverity = model.errorLogSeverity
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGLogModel(
                accessLogEnabled: self.accessLogEnabled,
                dnsLogEnabled: self.dnsLogEnabled,
                errorLogSeverity: self.errorLogSeverity
            )
            guard model != MGLogModel.current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.log)
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
