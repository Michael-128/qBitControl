import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Group {
           if viewModel.shouldAttemptAutoLogIn {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .onAppear {
                        viewModel.attemptAutoLogIn()
                    }
                Text("qBitControl")
                    .font(.largeTitle)
            } else if !viewModel.isLoggedIn {
                ServersView(isLoggedIn: $viewModel.isLoggedIn)
                    .onAppear {
                        LocalNetworkPermissionService().triggerDialog()
                    }
                    .navigationTitle("qBitControl")
            } else {
                TabView {
                    TorrentListView(isLoggedIn: $viewModel.isLoggedIn)
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
                    
                    ServersView(isLoggedIn: $viewModel.isLoggedIn)
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
