//
//  ServerAddView.swift
//  TorrentAttempt
//
//  Created by Michał Grzegoszczyk on 30/10/2022.
//

import SwiftUI

struct ServerAddView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var friendlyName = ""
    @State private var ip = ""
    @State private var username = ""
    @State private var password = ""
    
    @State private var defaults = UserDefaults.standard
    
    @Binding var servers: [Server]
    
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
                Section(header: Text("Information")) {
                    TextField("Name", text: $friendlyName)
                        .autocapitalization(.none)
                    TextField("IP:PORT", text: $ip)
                        .autocapitalization(.none)
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button {
                        /*if !ip.hasPrefix("http://") || !ip.hasPrefix("https://") {
                            return
                        }*/
                        
                        var loadedServers: [Server] = []
                        
                        if let servers = defaults.object(forKey: "servers") as? Data {
                            let decoder = JSONDecoder()
                            do {
                                loadedServers = try decoder.decode([Server].self, from: servers)
                            } catch {
                                print(error)
                            }
                        }
                        
                        let server = Server(name: friendlyName, ip: ip, username: username, password: password)
                        
                        loadedServers.append(server)
                        
                        let encoder = JSONEncoder()
                        
                        do {
                            let encodedServers = try encoder.encode(loadedServers)
                            defaults.set(encodedServers, forKey: "servers")
                            refreshServers()
                        } catch {
                            print(error)
                        }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("ADD")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                }.listRowBackground(Color.blue)
            }
            .toolbar() {
                Button {presentationMode.wrappedValue.dismiss()} label: {Text("Cancel")}
            }
            .navigationTitle("Add Server")
        }
    }
}

struct ServerAddView_Previews: PreviewProvider {
    static var previews: some View {
        ServerAddView(servers: .constant([]))
    }
}
