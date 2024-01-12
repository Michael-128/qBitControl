//
//  MainView.swift
//  qBitControl
//

import SwiftUI

struct MainView: View {
    
    @State private var isLoggedIn: Bool = false
    @State private var isDemo: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @State private var defaults = UserDefaults.standard
    
    @State private var shouldAttempAutoLogIn = true
    
    var body: some View {
        if(shouldAttempAutoLogIn) {
            Text("qBitControl").onAppear {
                let serversHelper = ServersHelper()
                let activeServer = serversHelper.getActiveServer()
                
                if let activeServer = activeServer {
                    serversHelper.connect(server: activeServer, isSuccess: {
                        success in
                        isLoggedIn = success
                    })
                }
                
                shouldAttempAutoLogIn = false
            }
        } else if(!isLoggedIn) {
            ServersView(isLoggedIn: $isLoggedIn).onAppear {
                LocalNetworkPermissionService().triggerDialog()
            }.navigationTitle("qBitControl")
        } else {
            TabView {
                VStack {
                    TorrentListView(isLoggedIn: $isLoggedIn).onChange(of: scenePhase, perform: {
                        phase in
                        print(phase)
                        if(phase == .active && isLoggedIn) {
                            let serversHelper = ServersHelper()
                            let activeServer = serversHelper.getActiveServer()
                            
                            if let activeServer = activeServer {
                                serversHelper.connect(server: activeServer, isSuccess: {
                                    success in
                                    if(!success) {
                                        isLoggedIn = false
                                    }
                                })
                            }
                        }
                    })
                }.tabItem() {
                    Label("Tasks", systemImage: "square.and.arrow.down.on.square")
                }
                
                /*VStack {
                    RSSView()
                }.tabItem() {
                    Label("RSS", systemImage: "dot.radiowaves.up.forward")
                }*/
                
                VStack {
                    TorrentStatsView()
                }.tabItem() {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                VStack {
                    ServersView(isLoggedIn: $isLoggedIn)
                }.tabItem() {
                    Label("Servers", systemImage: "server.rack")
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
