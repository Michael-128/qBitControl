//
//  ServersHelper.swift
//  qBitControl
//

import Foundation

@MainActor
class ServersHelper: ObservableObject {
    static public var shared = ServersHelper()
    
    private var defaults = UserDefaults.standard
    private let serversKey = "servers"
    private let activeServerKey = "activeServer"
    
    @Published public var servers: [Server] = []
    @Published public var activeServerId: String?
    @Published public var connectingServerId: String?
    
    @Published public var isLoggedIn = false
    @Published public var client: TorrentClientProtocol?
    
    @Published public var preferences: qBitPreferences?
    @Published public var categories: [String: Category] = [:]
    @Published public var tags: [String] = []
    
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
            client = nil
            clearCache()
        }
        
        saveSeverList()
    }
    
    func checkConnection(server: Server, result: @escaping (Bool) -> Void) {
        Task {
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth)
            let tempClient = qBittorrentClient(networkClient: networkClient)
            do {
                try await tempClient.login(username: server.username, password: server.password)
                result(true)
            } catch {
                result(false)
            }
        }
    }
    
    func clearCache() {
        qBitData.shared.cacheManager.torrents = [:]
        qBitData.shared.rid = 0
        qBitData.shared.resetTransferHistory()
        
        RSSNodeViewModel.shared.rssRootNode = RSSNode()
        
        self.preferences = nil
        self.categories = [:]
        self.tags = []
    }
    
    func connect(server: Server, result: ((Bool) -> Void)?) {
        if server.id != activeServerId {
            self.clearCache()
        }
        connectingServerId = server.id
        
        Task {
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth)
            let newClient = qBittorrentClient(networkClient: networkClient)
            do {
                try await newClient.login(username: server.username, password: server.password)
                
                self.client = newClient
                self.setActiveServer(id: server.id)
                
                await fetchMetadata()
                
                self.isLoggedIn = true
                result?(true)
            } catch {
                result?(false)
            }
            self.connectingServerId = nil
        }
    }
    
    func connect(server: Server) {
        if server.id != activeServerId {
            self.clearCache()
        }
        connectingServerId = server.id
        
        Task {
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth)
            let newClient = qBittorrentClient(networkClient: networkClient)
            do {
                let loggedInClient = try await withThrowingTaskGroup(of: qBittorrentClient.self) { group in
                    group.addTask {
                        try await newClient.login(username: server.username, password: server.password)
                        return newClient
                    }
                    
                    group.addTask {
                        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                        throw NetworkError.timeout
                    }
                    
                    let firstResult = try await group.next()
                    group.cancelAll()
                    
                    guard let client = firstResult else {
                        throw NetworkError.invalidResponse
                    }
                    return client
                }
                
                // Mutating and invoking actor-isolated methods safely on the MainActor
                self.client = loggedInClient
                self.setActiveServer(id: server.id)
                await self.fetchMetadata()
                
                self.isLoggedIn = true
            } catch {
                print("Auto-connect failed: \(error)")
            }
            self.connectingServerId = nil
        }
    }
    
    func fetchMetadata() async {
        guard let client = client else { return }
        do {
            self.preferences = try await client.getPreferences()
        } catch {
            print("Failed to fetch preferences: \(error)")
        }
        do {
            self.categories = try await client.getCategories()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
        do {
            self.tags = try await client.getTags()
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }
    
    func refreshCategories() {
        Task {
            do {
                if let client = client {
                    self.categories = try await client.getCategories()
                }
            } catch {
                print("Failed to refresh categories: \(error)")
            }
        }
    }
    
    func refreshTags() {
        Task {
            do {
                if let client = client {
                    self.tags = try await client.getTags()
                }
            } catch {
                print("Failed to refresh tags: \(error)")
            }
        }
    }
}
