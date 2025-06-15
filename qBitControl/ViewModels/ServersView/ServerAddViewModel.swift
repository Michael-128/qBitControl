//
//  ServerAddView.swift
//  qBitControl
//

import SwiftUI

class ServerAddViewModel: ObservableObject {
    @ObservedObject var serversHelper = ServersHelper.shared
    
    var editServerId: String?
    
    @Published var friendlyName = ""
    @Published var url = ""
    @Published var username = ""
    @Published var password = ""
    @Published var basicAuth: Server.BasicAuth?
    @Published var isCheckConnection = true;
    
    @Published var isInvalidAlert = false;
    @Published var invalidAlertMessage = "";
    
    @Published var isCheckingConnection = false;
    
    public var addButtonColor: Color { self.isCheckingConnection ? Color.gray : Color.blue }
    
    private var alertQueue: [String] = [];
    
    init() { }
    init(editServerId: String) {
        self.editServerId = editServerId
        
        if let server = serversHelper.getServer(id: editServerId) {
            friendlyName = server.name
            url = server.url
            username = server.username
            password = server.password
            basicAuth = server.basicAuth
        }
    }
    
    func validateInputs() -> Bool {
        if(!(url.contains("https://") || url.contains("http://"))) {
            showAlert(message: "Include protocol in the URL - 'https://' or 'http://' depending on your setup.")
            return false;
        }
        
        return true;
    }
    
    func validateIsConnecting() -> Bool {
        if (self.isCheckingConnection) {
            //showAlert(message: "Adding, Please wait")
            return false;
        }
        
        return true;
    }
    
    func showAlert(message: String?) {
        if let message = message {
            alertQueue.append(message)
        }
        
        guard !isInvalidAlert, let message = alertQueue.first else {
            return;
        }
        
        alertQueue.removeFirst()
        invalidAlertMessage = message
        isInvalidAlert = true
    }
    
    func alertDismissed() {
        DispatchQueue.main.async {
            self.showAlert(message: nil)
        }
    }
    
    func addServer(server: Server) {
        serversHelper.addServer(server: server)
    }
    
    func addServer(dismiss: DismissAction) -> Void {
        if(!validateInputs()) { return; }
        if(!validateIsConnecting()) { return; }
        
        let server = Server(name: friendlyName, url: url, username: username, password: password, basicAuth: basicAuth)
        
        if(!isCheckConnection) {
            if let editServerId = self.editServerId { serversHelper.removeServer(id: editServerId) }
            addServer(server: server)
            dismiss()
        }
        
        self.isCheckingConnection = true
        
        serversHelper.checkConnection(server: server, result: {
            didConnect in
            DispatchQueue.main.async {
                if(didConnect) {
                    if let editServerId = self.editServerId { self.serversHelper.removeServer(id: editServerId) }
                    self.addServer(server: server)
                    dismiss()
                } else {
                    self.showAlert(message: "Can't connect to the server.")
                }
                self.isCheckingConnection = false
            }
        })
    }
}
