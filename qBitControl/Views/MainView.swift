import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @ObservedObject var serversHelper = ServersHelper.shared
    @Environment(\.scenePhase) var scenePhase
    @State var selectedTab: TabItem.Tab = .search
    
    let tabs = [
        TabItem(label: "Tasks", systemImage: "square.and.arrow.down.on.square", value: .tasks) { AnyView(TorrentListView()) },
        TabItem(label: "RSS", systemImage: "dot.radiowaves.up.forward", value: .rss) { AnyView(RSSView()) },
        TabItem(label: "Stats", systemImage: "chart.line.uptrend.xyaxis", value: .stats) { AnyView(StatsView()) },
        TabItem(label: "Servers", systemImage: "server.rack", value: .servers) { AnyView(ServersView()) },
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
    
    @ViewBuilder
    func mainTabViewLG() -> some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.label) { tab in
                    Tab(tab.label, systemImage: tab.systemImage, value: tab.value) {
                        tab.content()
                    }
                }
            }.onChange(of: scenePhase) { phase in
                viewModel.reconnectIfNeeded(on: phase)
            }
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
                    mainTabViewLG()
                        .tabBarMinimizeBehavior(.onScrollDown)
                } else {
                    mainTabView()
                }
            }
        }
    }
}
