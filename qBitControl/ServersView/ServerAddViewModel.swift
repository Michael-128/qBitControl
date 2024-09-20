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
    @Published var isCheckConnection = true;
    
    @Published var isInvalidAlert = false;
    @Published var invalidAlertMessage = "";
    
    init() { }
    init(editServerId: String) {
        self.editServerId = editServerId
        
        if let server = serversHelper.getServer(id: editServerId) {
            friendlyName = server.name
            url = server.url
            username = server.username
            password = server.password
        }
    }
    
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
    
    func addServer(dismiss: DismissAction) -> Void {
        if(!validateInputs()) { return; }
        
        let server = Server(name: friendlyName, url: url, username: username, password: password)
        
        if(!isCheckConnection) {
            if let editServerId = self.editServerId { serversHelper.removeServer(id: editServerId) }
            serversHelper.addServer(server: server)
            dismiss()
        }
        
        serversHelper.checkConnection(server: server, result: {
            didConnect in
            DispatchQueue.main.async {
                if(didConnect) {
                    if let editServerId = self.editServerId { self.serversHelper.removeServer(id: editServerId) }
                    self.serversHelper.addServer(server: server)
                    dismiss()
                } else {
                    self.showAlert(message: "Can't connect to the server.")
                }
            }
        })
    }
}
