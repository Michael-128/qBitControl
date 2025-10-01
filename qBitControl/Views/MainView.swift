import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @ObservedObject var serversHelper = ServersHelper.shared
    @Environment(\.scenePhase) var scenePhase
    
    let tabs = [
        TabItem(label: "Tasks", systemImage: "square.and.arrow.down.on.square") { AnyView(TorrentListView()) },
        TabItem(label: "RSS", systemImage: "dot.radiowaves.up.forward") { AnyView(RSSView()) },
        TabItem(label: "Stats", systemImage: "chart.line.uptrend.xyaxis") { AnyView(StatsView()) },
        TabItem(label: "Servers", systemImage: "server.rack") { AnyView(ServersView()) },
    ]
    
    func mainTabView() -> some View {
        TabView {
            ForEach(tabs, id: \.label) { tab in
                tab.content()
                    .tabItem {
                        Label(tab.label, systemImage: tab.systemImage)
                    }
            }
        }.onChange(of: scenePhase) { phase in
            viewModel.reconnectIfNeeded(on: phase)
        }
    }
    
    var body: some View {
        Group {
            if serversHelper.connectingServerId != nil && !serversHelper.isLoggedIn {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                Text("qBitControl")
                    .font(.largeTitle)
            } else if !serversHelper.isLoggedIn {
                ServersView()
                    .onAppear {
                        LocalNetworkPermissionService().triggerDialog()
                    }
                    .navigationTitle("qBitControl")
            } else {
                if #available(iOS 26.0, *) {
                    mainTabView()
                        .tabBarMinimizeBehavior(.onScrollDown)
                } else {
                    mainTabView()
                }
            }
        }
    }
}
