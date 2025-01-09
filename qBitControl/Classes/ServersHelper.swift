//

import Foundation


class ServersHelper: ObservableObject {
    static public var shared = ServersHelper()
    
    private var defaults = UserDefaults.standard
    private let serversKey = "servers"
    private let activeServerKey = "activeServer"
    
    @Published public var servers: [Server] = []
    @Published public var activeServerId: String?
    @Published public var connectingServerId: String?
    
    @Published public var isLoggedIn = false
    
    init() {
        getServerList()
        getActiveServer()
        
        if let activeServerId = self.activeServerId {
            if let activeServer = self.getServer(id: activeServerId) {
                self.connect(server: activeServer)
            }
        }
    }
    
    func getServerList() {
        let encodedServers = defaults.data(forKey: self.serversKey)
        
        if let encodedServers = encodedServers {
            let decoder = JSONDecoder()
            
            do {
                self.servers = try decoder.decode([Server].self, from: encodedServers)
            } catch {
                print("Servers could not be decoded.")
            }
        }
    }
    
    func getServer(id: String) -> Server? {
        return servers.first(where: {
            server in
            return server.id == id
        })
    }
    
    private func setActiveServer(id: String) {
        self.activeServerId = id
        defaults.setValue("\(id)", forKey: activeServerKey)
    }
    
    private func getActiveServer() {
        let serverId = defaults.string(forKey: activeServerKey)
        
        if let serverId = serverId {
            self.activeServerId = self.servers.first(where: {
                server in
                server.id == serverId
            })?.id
        }
    }
    
    func saveSeverList() {
        let encoder = JSONEncoder()
        
        do {
            let encodedServers = try encoder.encode(self.servers)
            defaults.setValue(encodedServers, forKey: self.serversKey)
        } catch {
            print("Servers could not be encoded")
        }
    }
    
    func addServer(server: Server) {
        self.servers.append(server)
        saveSeverList()
    }
    
    func removeServer(id: String) {
        self.servers.removeAll(where: {
            server in
            return server.id == id
        })
        
        if(id == activeServerId) {
            activeServerId = nil
            isLoggedIn = false
        }
        
        saveSeverList()
    }
    
    func checkConnection(server: Server, result: @escaping (Bool) -> Void) {
        Task {
            await Auth.getCookie(url: server.url, username: server.username, password: server.password, isSuccess: {
                success in
                result(success);
            }, setCookie: false)
        }
    }
    
    func connect(server: Server, result: ((Bool) -> Void)?) {
        connectingServerId = server.id
        
        Task {
            await Auth.getCookie(url: server.url, username: server.username, password: server.password, isSuccess: {
                success in
                DispatchQueue.main.async {
                    if let result = result {
                        result(success)
                    }
                    
                    if(success) {
                        self.setActiveServer(id: server.id)
                        qBittorrent.initialize()
                        self.isLoggedIn = true
                    }
                    
                    self.connectingServerId = nil
                }
            })
        }
    }
    
    func connect(server: Server) {
        connectingServerId = server.id
        
        Task {
            await Auth.getCookie(url: server.url, username: server.username, password: server.password, isSuccess: {
                success in
                DispatchQueue.main.async {
                    if(success) {
                        self.setActiveServer(id: server.id)
                        qBittorrent.initialize()
                        self.isLoggedIn = true
                    }
                    
                    self.connectingServerId = nil
                }
            })
        }
    }
}
