import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @ObservedObject var serversHelper = ServersHelper.shared
    @Environment(\.scenePhase) var scenePhase
    
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
    
    
    func mainTabView() -> some View {
        TabView {
            TorrentListView()
                .tabItem {
                    Label("Tasks", systemImage: "square.and.arrow.down.on.square")
                }
                .onChange(of: scenePhase) { phase in
                    viewModel.reconnectIfNeeded(on: phase)
                }
            
            RSSView()
                .tabItem {
                    Label("RSS", systemImage: "dot.radiowaves.up.forward")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            ServersView()
                .tabItem {
                    Label("Servers", systemImage: "server.rack")
                }
        }
    }
}
