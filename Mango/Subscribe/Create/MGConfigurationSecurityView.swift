import SwiftUI

struct MGConfigurationSecurityView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        Picker("Security", selection: $vm.security) {
            ForEach(MGConfiguration.Security.allCases) { type in
                Text(type.description)
            }
        }
        switch vm.security {
        case .tls:
            LabeledContent("Server Name") {
                TextField("", text: $vm.tls.serverName)
            }
            LabeledContent("ALPN") {
                HStack {
                    ForEach(MGConfiguration.ALPN.allCases) { alpn in
                        MGToggleButton(
                            title: alpn.description,
                            isOn: Binding(
                                get: {
                                    vm.tls.alpn.contains(alpn)
                                },
                                set: { value in
                                    if value {
                                        vm.tls.alpn.append(alpn)
                                    } else {
                                        vm.tls.alpn.removeAll(where: { $0 == alpn })
                                    }
                                }
                            )
                        )
                    }
                }
            }
            LabeledContent("Fingerprint") {
                Picker("", selection: $vm.tls.fingerprint) {
                    ForEach(MGConfiguration.Fingerprint.allCases) { fingerprint in
                        Text(fingerprint.description)
                    }
                }
            }
            Toggle("Allow Insecure", isOn: $vm.tls.allowInsecure)
        case .reality:
            LabeledContent("Server Name") {
                TextField("", text: $vm.reality.serverName)
            }
            LabeledContent("Fingerprint") {
                Picker("", selection: $vm.reality.fingerprint) {
                    ForEach(MGConfiguration.Fingerprint.allCases) { fingerprint in
                        Text(fingerprint.description)
                    }
                }
            }
            LabeledContent("Public Key") {
                TextField("", text: $vm.reality.publicKey)
            }
            LabeledContent("Short ID") {
                TextField("", text: $vm.reality.shortId)
            }
            LabeledContent("SpiderX") {
                TextField("", text: $vm.reality.spiderX)
            }
        case .none:
            EmptyView()
        }
    }
}
