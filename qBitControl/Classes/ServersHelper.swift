//

import Foundation

class ServersHelper {
    private var defaults = UserDefaults.standard
    private var servers: [Server] = []
    
    private let serversKey = "servers"
    private let activeServerKey = "activeServer"
    
    func refreshServerList() {
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
    
    func saveSeverList() {
        let encoder = JSONEncoder()
        
        do {
            let encodedServers = try encoder.encode(self.servers)
            defaults.setValue(encodedServers, forKey: self.serversKey)
        } catch {
            print("Servers could not be encoded")
        }
    }
    
    func getServers() -> [Server] {
        refreshServerList()
        return servers
    }
    
    func addServer(server: Server) {
        refreshServerList()
        
        self.servers.append(server)
        
        saveSeverList()
    }
    
    func removeServer(id: String) {
        refreshServerList()
        
        self.servers.removeAll(where: {
            server in
            return server.id == id
        })
        
        saveSeverList()
    }
    
    func connect(server: Server, isSuccess: @escaping (Bool) -> Void) {
        Task {
            await Auth.getCookie(url: server.url, username: server.username, password: server.password, isSuccess: {
                success in
                if(success) {
                    self.setActiveServer(id: server.id)
                }
                
                isSuccess(success)
            })
        }
    }
    
    func setActiveServer(id: String) {
        defaults.setValue("\(id)", forKey: activeServerKey)
    }
    
    func getActiveServer() -> Server? {
        let serverId = defaults.string(forKey: activeServerKey)
        
        if let serverId = serverId {
            refreshServerList()
            
            return self.servers.first(where: {
                server in
                server.id == serverId
            })
        }
        
        return nil
    }
}
