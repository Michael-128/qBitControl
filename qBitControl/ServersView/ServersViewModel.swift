import SwiftUI
import Combine

class ServersViewModel: ObservableObject {
    @Published var servers: [Server] = []
    @Published var activeServerId: String = ""
    @Published var isConnecting: [String: Bool] = [:]
    @Published var isServerAddView = false
    @Published var isTroubleConnecting = false
    @Binding var isLoggedIn: Bool

    public var serversHelper = ServersHelper()

    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
        refreshServerList()
        refreshActiveServer()
    }

    func refreshServerList() {
        servers = serversHelper.getServers()
    }

    func refreshActiveServer() {
        if let activeServer = serversHelper.getActiveServer() {
            activeServerId = activeServer.id
        }
    }

    func connectToServer(server: Server) {
        isConnecting[server.id] = true
        serversHelper.connect(server: server) { success in
            DispatchQueue.main.async {
                if !success {
                    self.isTroubleConnecting = true
                }
                if success {
                    self.isLoggedIn = true
                }
                self.isConnecting[server.id] = false
                self.refreshActiveServer()
            }
        }
    }
}
