//
//  ContentView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 25/10/2022.
//

import SwiftUI

struct ServersView: View {
    
    @State private var cookie1 = qBittorrent.getCookie()
    @Binding var isLoggedIn: Bool
    @State private var isLoginFailed = false
    
    @State private var isConnecting: [String: Bool] = [:]
    
    @State private var isServerAddView = false
    
    @State private var servers: [Server] = []
    @State private var defaults = UserDefaults.standard
    
    func refreshServers() -> Void {
        if let server = defaults.object(forKey: "servers") as? Data {
            let decoder = JSONDecoder()
            do {
                servers = try decoder.decode([Server].self, from: server)
            } catch {
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        isServerAddView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Server")
                        }
                    }
                }
                Section(header: Text("Server List")) {
                    ForEach(servers, id: \.id) {
                        server in
                        Button {
                            isConnecting[server.id] = true
                            
                            let cookie = Auth.getCookie(id: server.id)
                            
                            if cookie.contains("SID") {
                                qBittorrent.setURL(url: server.ip)
                                qBittorrent.setCookie(cookie: cookie)
                                isLoggedIn = true
                                return
                            }
                            
                            Auth.getCookie(ip: server.ip, username: server.username, password: server.password, completion: {
                                cookie in
                                //print(cookie)
                                if cookie.contains("SID") {
                                    Auth.setCookie(id: server.id, cookie: cookie)
                                    qBittorrent.setURL(url: server.ip)
                                    qBittorrent.setCookie(cookie: cookie)
                                    isLoggedIn = true
                                } else {
                                    isLoggedIn = false
                                    isLoginFailed = true
                                }
                            })
                        } label: {
                            ServerRowView(id: server.id, friendlyName: server.name, ip: server.ip, username: server.username, password: server.password, servers: $servers, isConnecting: $isConnecting)
                        }
                    }
                }
                
                if(isLoginFailed) {
                    Text("Failed to login!")
                }
            }
            .navigationTitle("qBitControl")
        }.sheet(isPresented: $isServerAddView) {
            ServerAddView(servers: $servers)
        }.onAppear() {
            refreshServers()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
