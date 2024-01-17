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
    @State private var isCheckConnection = true;
    
    @State private var isInvalidAlert = false;
    @State private var invalidAlertMessage = "";
    
    public var serversHelper: ServersHelper
    
    func showAlert(message: String) {
        invalidAlertMessage = message;
        isInvalidAlert = true;
    }
    
    func validateInputs() -> Bool {
        if(!(url.contains("https://") || url.contains("http://"))) {
            showAlert(message: "Include protocol in the URL - 'https://' or 'http://' depending on your setup.")
            return false;
        }
        
        return true;
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Information")) {
                    TextField("Server Name (optional)", text: $friendlyName)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("http(s)://IP:PORT", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                        .autocorrectionDisabled()
                    
                    
                }
                
                Section {
                    Toggle(isOn: $isCheckConnection, label: {
                        Text("Check Connection")
                    })
                }
                
                Section {
                    Button {
                        if(!validateInputs()) { return; }
                        
                        let server = Server(name: friendlyName, url: url, username: username, password: password)
                        
                        if(!isCheckConnection) {
                            serversHelper.addServer(server: server)
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        serversHelper.checkConnection(server: server, result: {
                            didConnect in
                            
                            if(didConnect) {
                                serversHelper.addServer(server: server)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showAlert(message: "Can't connect to the server.")
                            }
                        })
                    } label: {
                        Text("ADD")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                }.listRowBackground(Color.blue)
            }
            .alert(isPresented: $isInvalidAlert) {
                Alert(title: Text("Invalid server informations"), message: Text(invalidAlertMessage))
            }
            .toolbar() {
                Button {presentationMode.wrappedValue.dismiss()} label: {Text("Cancel")}
            }
            .navigationTitle("Add Server")
        }
    }
}
