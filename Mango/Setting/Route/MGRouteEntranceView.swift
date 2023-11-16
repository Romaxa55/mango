import SwiftUI

struct MGRouteEntranceView: View {
    
    @StateObject private var routeViewModel = MGRouteViewModel()
    
    var body: some View {
        NavigationLink {
            MGRouteSettingView(routeViewModel: routeViewModel)
        } label: {
            Label("路由设置", systemImage: "arrow.triangle.branch")
        }
    }
}
