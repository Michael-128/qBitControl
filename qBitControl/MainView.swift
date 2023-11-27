//
//  MainView.swift
//  qBitControl
//

import SwiftUI

struct MainView: View {
    
    @State private var isLoggedIn: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @State private var defaults = UserDefaults.standard
    
    var body: some View {
        if(!isLoggedIn) {
            LoginView(isLoggedIn: $isLoggedIn)
        } else {
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
            /*TabView {
                VStack {
                    TorrentListView(isLoggedIn: $isLoggedIn)
                }.tabItem() {
                    Label("Torrents", systemImage: "square.and.arrow.down.on.square")
                }
                
                /*VStack {
                    RSSView()
                }.tabItem() {
                    Label("RSS", systemImage: "dot.radiowaves.up.forward")
                }*/
                
                VStack {
                    Text("Settings")
                }.tabItem() {
                    Label("Settings", systemImage: "gearshape")
                }
            }*/
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
