import SwiftUI

struct MGCreateOrUpdateConfigurationView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    @Environment(\.dismiss) private var dismiss
        
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Description") {
                        TextField("", text: $vm.descriptive)
                    }
                    switch vm.protocolType {
                    case .vless:
                        MGConfigurationVLESSView(vm: vm)
                    case .vmess:
                        MGConfigurationVMessView(vm: vm)
                    case .trojan:
                        MGConfigurationTrojanView(vm: vm)
                    case .shadowsocks:
                        MGConfigurationShadowsocksView(vm: vm)
                    }
                } header: {
                    Text("Server")
                }
                Section {
                    MGConfigurationTransportView(vm: vm)
                } header: {
                    Text("Transport")
                }
                Section {
                    MGConfigurationSecurityView(vm: vm)
                } header: {
                    Text("Security")
                }
            }
            .lineLimit(1)
            .multilineTextAlignment(.trailing)
            .navigationTitle(Text(vm.protocolType.description))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        do {
                            try vm.save()
                            dismiss()
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    } label: {
                        Text("Done")
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}
