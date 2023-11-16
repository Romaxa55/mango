import SwiftUI

struct MGRouteSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager:    MGPacketTunnelManager
    @ObservedObject     private var routeViewModel:         MGRouteViewModel
    
    init(routeViewModel: MGRouteViewModel) {
        self._routeViewModel = ObservedObject(initialValue: routeViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                Picker("解析策略", selection: $routeViewModel.domainStrategy) {
                    ForEach(MGRouteModel.DomainStrategy.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                Picker("匹配算法", selection: $routeViewModel.domainMatcher) {
                    ForEach(MGRouteModel.DomainMatcher.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
            } header: {
                Text("域名")
            }
            Section {
                ForEach($routeViewModel.rules) { rule in
                    NavigationLink {
                        MGRouteRuleSettingView(rule: rule)
                    } label: {
                        HStack {
                            LabeledContent {
                                Text(rule.outboundTag.wrappedValue.description)
                            } label: {
                                Label {
                                    Text(rule.__name__.wrappedValue)
                                } icon: {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(rule.__enabled__.wrappedValue ? .green : .gray)
                                }
                            }
                        }
                    }
                }
                .onMove { from, to in
                    routeViewModel.rules.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { offsets in
                    routeViewModel.rules.remove(atOffsets: offsets)
                }
                Button("添加规则") {
                    withAnimation {
                        var rule = MGRouteModel.Rule()
                        rule.__name__ = rule.__defaultName__
                        routeViewModel.rules.append(rule)
                    }
                }
            } header: {
                HStack {
                    Text("规则")
                    Spacer()
                    EditButton()
                        .font(.callout)
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .disabled(routeViewModel.rules.isEmpty)
                }
            }
        }
        .onDisappear {
            self.routeViewModel.save {
                guard let status = packetTunnelManager.status, status == .connected else {
                    return
                }
                packetTunnelManager.stop()
                Task(priority: .userInitiated) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        try await packetTunnelManager.start()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
        .lineLimit(1)
        .navigationTitle(Text("路由设置"))
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MGRouteRuleSettingView: View {
    
    @Binding var rule: MGRouteModel.Rule
    
    var body: some View {
        Form {
            Section {
                Picker("Matcher", selection: $rule.domainMatcher) {
                    ForEach(MGRouteModel.DomainMatcher.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                DisclosureGroup {
                    MGRouteRuleStringListEditView(elements: Binding(get: {
                        rule.domain ?? []
                    }, set: { newValue in
                        rule.domain = newValue.isEmpty ? nil : newValue
                    }))
                } label: {
                    LabeledContent("Domain", value: "\(rule.domain?.count ?? 0)")
                }
                DisclosureGroup {
                    MGRouteRuleStringListEditView(elements: Binding(get: {
                        rule.ip ?? []
                    }, set: { newValue in
                        rule.ip = newValue.isEmpty ? nil : newValue
                    }))
                } label: {
                    LabeledContent("IP", value: "\(rule.ip?.count ?? 0)")
                }
                DisclosureGroup {
                    MGRouteRuleStringListEditView(elements:  Binding {
                        let reval = rule.port ?? ""
                        return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                    } set: { newValue in
                        let reval = newValue.joined(separator: ",")
                        rule.port = reval.isEmpty ? nil : reval
                    })
                } label: {
                    LabeledContent("Port", value: rule.port ?? "")
                }
                DisclosureGroup {
                    MGRouteRuleStringListEditView(elements:  Binding {
                        let reval = rule.sourcePort ?? ""
                        return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                    } set: { newValue in
                        let reval = newValue.joined(separator: ",")
                        rule.sourcePort = reval.isEmpty ? nil : reval
                    })
                } label: {
                    LabeledContent("Source Port", value: rule.sourcePort ?? "")
                }
                LabeledContent("Network") {
                    HStack {
                        MGToggleButton(title: "TCP", isOn: Binding(get: {
                            let reval = rule.network ?? ""
                            return reval.components(separatedBy: ",").contains("tcp")
                        }, set: { newValue in
                            let reval = rule.network ?? ""
                            var components = reval.components(separatedBy: ",")
                            components.removeAll(where: { $0 == "tcp" })
                            if newValue {
                                components.insert("tcp", at: 0)
                            }
                            rule.network = components.isEmpty ? nil : String(components.joined(separator: ","))
                        }))
                        MGToggleButton(title: "UDP", isOn: Binding(get: {
                            let reval = rule.network ?? ""
                            return reval.components(separatedBy: ",").contains("udp")
                        }, set: { newValue in
                            let reval = rule.network ?? ""
                            var components = reval.components(separatedBy: ",")
                            components.removeAll(where: { $0 == "udp" })
                            if newValue {
                                components.insert("udp", at: 0)
                            }
                            rule.network = components.isEmpty ? nil : String(components.joined(separator: ","))
                        }))
                    }
                }
                LabeledContent("Protocol") {
                    HStack {
                        MGToggleButton(title: "HTTP", isOn: Binding(get: {
                            let reval = rule.protocol ?? []
                            return reval.contains("http")
                        }, set: { newValue in
                            var reval = rule.protocol ?? []
                            reval.removeAll(where: { $0 == "http" })
                            if newValue {
                                reval.append("http")
                            }
                            rule.protocol = reval.isEmpty ? nil : reval
                        }))
                        MGToggleButton(title: "TLS", isOn: Binding(get: {
                            let reval = rule.protocol ?? []
                            return reval.contains("tls")
                        }, set: { newValue in
                            var reval = rule.protocol ?? []
                            reval.removeAll(where: { $0 == "tls" })
                            if newValue {
                                reval.append("tls")
                            }
                            rule.protocol = reval.isEmpty ? nil : reval
                        }))
                        MGToggleButton(title: "Bittorrent", isOn: Binding(get: {
                            let reval = rule.protocol ?? []
                            return reval.contains("bittorrent")
                        }, set: { newValue in
                            var reval = rule.protocol ?? []
                            reval.removeAll(where: { $0 == "bittorrent" })
                            if newValue {
                                reval.append("bittorrent")
                            }
                            rule.protocol = reval.isEmpty ? nil : reval
                        }))
                    }
                }
                Picker("Outbound", selection: $rule.outboundTag) {
                    ForEach(MGRouteModel.Outbound.allCases) { outbound in
                        Text(outbound.description)
                    }
                }
            } header: {
                Text("Settings")
            }
            Section {
                LabeledContent("Name") {
                    TextField("", text: $rule.__name__)
                        .onSubmit {
                            if rule.__name__.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                rule.__name__ = rule.__defaultName__
                            }
                        }
                }
                Toggle("Enable", isOn: $rule.__enabled__)
            } header: {
                Text("Other")
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .environment(\.editMode, .constant(.active))
        .navigationTitle(Text(rule.__name__))
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MGRouteRuleStringListEditView: View {
    
    @Binding var elements: [String]
    
    @State private var value: String = ""
    
    var body: some View {
        Group {
            ForEach(elements, id: \.self) { element in
                Text(element)
            }
            .onMove { from, to in
                elements.move(fromOffsets: from, toOffset: to)
            }
            .onDelete { offseets in
                elements.remove(atOffsets: offseets)
            }
            
            HStack(spacing: 18) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.green)
                    .offset(CGSize(width: -2, height: 0))
                TextField("Add", text: $value)
                    .onSubmit {
                        let reavl = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !reavl.isEmpty && !elements.contains(reavl) {
                            elements.append(reavl)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            value = ""
                        }
                    }
                    .multilineTextAlignment(.leading)
            }
            .padding(.trailing, 16)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
