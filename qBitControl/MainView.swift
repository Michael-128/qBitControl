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
    
    var body: some View {
        if(isDemo) { DemoView(isDemo: $isDemo) }
        else if(!isLoggedIn) {
            LoginView(isDemo: $isDemo, isLoggedIn: $isLoggedIn)
                .onAppear(perform: {
                    LocalNetworkPermissionService().triggerDialog()
                })
        } else {
            TabView {
                VStack {
                    TorrentListView(isLoggedIn: $isLoggedIn).onChange(of: scenePhase, perform: {
                        phase in
                        print(phase)
                        if(phase == .active && isLoggedIn) {
                            let data = defaults.value(forKey: "server") as? Data
                            
                            if let data = data {
                                let decoder = JSONDecoder()
                                do {
                                    let server = try decoder.decode(Server.self, from: data)
                                    
                                    Task {
                                        await Auth.getCookie(url: server.url, username: server.username, password: server.password, isSuccess: {
                                            isSuccess in
                                            if(!isSuccess) {
                                                isLoggedIn = false
                                            }
                                        })
                                    }
                                } catch {}
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
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
