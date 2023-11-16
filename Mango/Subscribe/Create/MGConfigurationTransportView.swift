import SwiftUI

struct MGConfigurationTransportView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
        
    var body: some View {
        Picker("Transport", selection: $vm.transport) {
            ForEach(MGConfiguration.Transport.allCases) { type in
                Text(type.description)
            }
        }
        switch vm.transport {
        case .tcp:
            EmptyView()
        case .kcp:
            LabeledContent("MTU") {
                TextField("", value: $vm.kcp.mtu, format: .number)
            }
            LabeledContent("TTI") {
                TextField("", value: $vm.kcp.tti, format: .number)
            }
            LabeledContent("Uplink Capacity") {
                TextField("", value: $vm.kcp.uplinkCapacity, format: .number)
            }
            LabeledContent("Downlink Capacity") {
                TextField("", value: $vm.kcp.downlinkCapacity, format: .number)
            }
            Toggle("Congestion", isOn: .constant(false))
            LabeledContent("Read Buffer Size") {
                TextField("", value: $vm.kcp.readBufferSize, format: .number)
            }
            LabeledContent("Write Buffer Size") {
                TextField("", value: $vm.kcp.writeBufferSize, format: .number)
            }
            Picker("Header Type", selection: $vm.kcp.header.type) {
                ForEach(MGConfiguration.HeaderType.allCases) { type in
                    Text(type.description)
                }
            }
            LabeledContent("Seed") {
                TextField("", text: $vm.kcp.seed)
            }
        case .ws:
            LabeledContent("Host") {
                TextField("", text: Binding(get: {
                    vm.ws.headers["Host"] ?? ""
                }, set: { value in
                    vm.ws.headers["Host"] = value.trimmingCharacters(in: .whitespacesAndNewlines)
                }))
            }
            LabeledContent("Path") {
                TextField("", text: $vm.ws.path)
            }
        case .http:
            LabeledContent("Host") {
                TextField("", text: Binding(get: {
                    vm.http.host.first ?? ""
                }, set: { value in
                    vm.http.host = [value.trimmingCharacters(in: .whitespacesAndNewlines)]
                }))
            }
            LabeledContent("Path") {
                TextField("", text: $vm.http.path)
            }
        case .quic:
            Picker("Security", selection: $vm.quic.security) {
                ForEach(MGConfiguration.Encryption.quic) { encryption in
                    Text(encryption.description)
                }
            }
            LabeledContent("Key") {
                TextField("", text: $vm.quic.key)
            }
            Picker("Header Type", selection: $vm.quic.header.type) {
                ForEach(MGConfiguration.HeaderType.allCases) { type in
                    Text(type.description)
                }
            }
        case .grpc:
            LabeledContent("Service Name") {
                TextField("", text: $vm.grpc.serviceName)
            }
            Toggle("Multi-Mode", isOn: $vm.grpc.multiMode)
        }
    }
}
