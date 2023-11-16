import SwiftUI

struct MGConfigurationVMessView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.vmess.address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.vmess.port, format: .number)
        }
        LabeledContent("ID") {
            TextField("", text: $vm.vmess.users[0].id)
        }
        LabeledContent("Alert ID") {
            TextField("", value: $vm.vmess.users[0].alterId, format: .number)
        }
        Picker("Security", selection: $vm.vmess.users[0].security) {
            ForEach(MGConfiguration.Encryption.vmess) { encryption in
                Text(encryption.description)
            }
        }
    }
}
