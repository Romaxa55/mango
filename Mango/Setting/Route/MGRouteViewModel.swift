import Foundation

final class MGRouteViewModel: ObservableObject {
    
    @Published var domainStrategy: MGRouteModel.DomainStrategy
    @Published var domainMatcher: MGRouteModel.DomainMatcher
    @Published var rules: [MGRouteModel.Rule]
    
    init() {
        let model = MGRouteModel.current
        self.domainStrategy = model.domainStrategy
        self.domainMatcher = model.domainMatcher
        self.rules = model.rules
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGRouteModel(
                domainStrategy: self.domainStrategy,
                domainMatcher: self.domainMatcher,
                rules: self.rules
            )
            guard model != .current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.route)
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
