//
//  ContentView.swift
//  qBitControl
//

import SwiftUI

struct ServersView: View {
    
    @State private var serversHelper = ServersHelper()
    @State private var isConnecting: [String: Bool] = [:]
    
    @State private var isServerAddView = false
    
    @State private var servers: [Server] = []
    @State private var activeServerId: String = ""
    
    @Binding public var isLoggedIn: Bool
    @State private var isTroubleConnecting = false
    
    func refreshServerList() { self.servers = serversHelper.getServers() }
    func refreshActiveServer() {
        if let activeServer = serversHelper.getActiveServer() {
            activeServerId = activeServer.id
        }
    }
    
    var body: some View {
        NavigationStack {
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
                if(!servers.isEmpty) {
                    Section(header: Text("Server List")) {
                        ForEach(servers, id: \.id) {
                            server in
                            Button {
                                isConnecting[server.id] = true
                                
                                serversHelper.connect(server: server, isSuccess: {
                                    success in
                                    if(!success) {
                                        isTroubleConnecting = true
                                    }
                                    
                                    isLoggedIn = success
                                    isConnecting[server.id] = false
                                    
                                    refreshActiveServer()
                                })
                            } label: {
                                ServerRowView(id: server.id, friendlyName: server.name, url: server.url, username: server.username, password: server.password, activeServerId: $activeServerId, serversHelper: serversHelper, refreshServerList: refreshServerList, isConnecting: $isConnecting)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Servers")
        }.sheet(isPresented: $isServerAddView) {
            ServerAddView(serversHelper: serversHelper)
        }.onChange(of: isServerAddView, perform: {
            isServerAddView in
            if(isServerAddView) { return }
            refreshServerList()
        }).onAppear() {
            refreshServerList()
            refreshActiveServer()
        }.alert(isPresented: $isTroubleConnecting, content: {
            Alert(title: Text("Couldn't connect to the server."), message: Text("Check if the URL, username and password is correct. Make sure local network access is enabled:\nSettings > Privacy & Security > Local Network > qBitControl"))
        })
    }
}
