import SwiftUI

struct MGConfigurationShadowsocksView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.shadowsocks.servers[0].address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.shadowsocks.servers[0].port, format: .number)
        }
        LabeledContent("Email") {
            TextField("", text: $vm.shadowsocks.servers[0].email)
        }
        LabeledContent("Password") {
            TextField("", text: $vm.shadowsocks.servers[0].password)
        }
        LabeledContent("Method") {
            Picker("Method", selection: $vm.shadowsocks.servers[0].method) {
                ForEach(MGConfiguration.Shadowsocks.Method.allCases) { method in
                    Text(method.description)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
        Toggle("UOT", isOn: $vm.shadowsocks.servers[0].uot)
    }
}
