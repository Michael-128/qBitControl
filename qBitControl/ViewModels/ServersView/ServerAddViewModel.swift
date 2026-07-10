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
    
    @Published var isInvalidAlert = false
    @Published var invalidAlertMessage = ""
    
    @Published var isConnectionAlert = false
    
    @Published var isCheckingConnection = false
    
    private var alertQueue: [String] = []
    private var pendingServer: Server?
    
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
        if !(url.contains("https://") || url.contains("http://")) {
            showAlert(message: "Include protocol in the URL — 'https://' or 'http://' depending on your setup.")
            return false
        }
        return true
    }
    
    func showAlert(message: String?) {
        if let message = message {
            alertQueue.append(message)
        }
        
        guard !isInvalidAlert, let message = alertQueue.first else {
            return
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
    
    func addServer(dismiss: DismissAction) {
        sanitizeInputs()
        
        if !validateInputs() { return }
        if isCheckingConnection { return }
        
        let server = Server(name: friendlyName, url: url, username: username, password: password, basicAuth: basicAuth)
        pendingServer = server
        
        self.isCheckingConnection = true
        
        serversHelper.checkConnection(server: server, result: { didConnect in
            DispatchQueue.main.async {
                self.isCheckingConnection = false
                if didConnect {
                    self.commitServer(dismiss: dismiss)
                } else {
                    self.isConnectionAlert = true
                }
            }
        })
    }
    
    func saveAnyway(dismiss: DismissAction) {
        commitServer(dismiss: dismiss)
    }
    
    private func commitServer(dismiss: DismissAction) {
        guard let server = pendingServer else { return }
        if let editServerId = self.editServerId { serversHelper.removeServer(id: editServerId) }
        addServer(server: server)
        pendingServer = nil
        dismiss()
    }
    
    private func sanitizeInputs() {
        url = url.replacingOccurrences(of: "/+$", with: "", options: .regularExpression)
    }
}
