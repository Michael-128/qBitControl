//
//  ServerAddView.swift
//  qBitControl
//

import SwiftUI

class ServerAddViewModel: ObservableObject {
    var serversHelper: ServersHelper
    
    @Published var friendlyName = ""
    @Published var url = ""
    @Published var username = ""
    @Published var password = ""
    @Published var isCheckConnection = true;
    
    @Published var isInvalidAlert = false;
    @Published var invalidAlertMessage = "";
    
    init(serversHelper: ServersHelper) {
        self.serversHelper = serversHelper
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
            serversHelper.addServer(server: server)
            dismiss()
        }
        
        serversHelper.checkConnection(server: server, result: {
            didConnect in
            DispatchQueue.main.async {
                if(didConnect) {
                    self.serversHelper.addServer(server: server)
                    dismiss()
                } else {
                    self.showAlert(message: "Can't connect to the server.")
                }
            }
        })
    }
}
