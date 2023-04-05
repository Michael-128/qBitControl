//
//  MainView.swift
//  qBitControl
//

import SwiftUI

struct MainView: View {
    
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        if(!isLoggedIn) {
            ServersView(isLoggedIn: $isLoggedIn)
        } else {
            TabView {
                VStack {
                    TorrentListView(isLoggedIn: $isLoggedIn)
                }.tabItem() {
                    Label("Torrents", systemImage: "square.and.arrow.down.on.square")
                }
                
                VStack {
                    RSSView()
                }.tabItem() {
                    Label("RSS", systemImage: "dot.radiowaves.up.forward")
                }
                
                VStack {
                    Text("Settings")
                }.tabItem() {
                    Label("Settings", systemImage: "gearshape")
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
