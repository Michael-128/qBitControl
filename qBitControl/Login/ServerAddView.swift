//
//  ServerAddView.swift
//  qBitControl
//

import SwiftUI

struct ServerAddView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var friendlyName = ""
    @State private var url = ""
    @State private var username = ""
    @State private var password = ""
    
    public var serversHelper: ServersHelper
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Information")) {
                    TextField("Name", text: $friendlyName)
                        .autocapitalization(.none)
                    TextField("http(s)://IP:PORT", text: $url)
                        .autocapitalization(.none)
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button {
                        serversHelper.addServer(server: Server(name: friendlyName, url: url, username: username, password: password))
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
