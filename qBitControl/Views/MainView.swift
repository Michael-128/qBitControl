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
                TabView {
                    TorrentListView(isLoggedIn: $serversHelper.isLoggedIn)
                        .tabItem {
                            Label("Tasks", systemImage: "square.and.arrow.down.on.square")
                        }
                        .onChange(of: scenePhase) { phase in
                            viewModel.reconnectIfNeeded(on: phase)
                        }
                    
                    TorrentStatsView()
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
