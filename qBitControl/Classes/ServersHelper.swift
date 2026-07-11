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
    
    // For unit testing tracking
    public var reauthAttemptCount = 0
    public var refreshClientCallCount = 0
    
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
                AppLogger.log(.error, GeneralErrorPayload(category: .system, eventName: "servers_decode_failed", errorDescription: "Servers could not be decoded: \(error.localizedDescription)"))
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
            AppLogger.log(.error, GeneralErrorPayload(category: .system, eventName: "servers_encode_failed", errorDescription: "Servers could not be encoded: \(error.localizedDescription)"))
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
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth, customHeaders: server.customHeaders)
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
        qBitData.shared.stopPolling()
        
        if server.id != activeServerId {
            self.clearCache()
        }
        connectingServerId = server.id
        
        Task {
            defer {
                self.connectingServerId = nil
                qBitData.shared.startPolling()
            }
            
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth, customHeaders: server.customHeaders)
            let newClient = qBittorrentClient(networkClient: networkClient)
            do {
                try await newClient.login(username: server.username, password: server.password)
                
                self.client = newClient
                self.setActiveServer(id: server.id)
                
                await fetchMetadata()
                
                self.isLoggedIn = true
                await qBitData.shared.getMainData()
                result?(true)
            } catch {
                result?(false)
            }
        }
    }
    
    func connect(server: Server) {
        qBitData.shared.stopPolling()
        
        if server.id != activeServerId {
            self.clearCache()
        }
        connectingServerId = server.id
        
        Task {
            defer {
                self.connectingServerId = nil
                qBitData.shared.startPolling()
            }
            
            let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth, customHeaders: server.customHeaders)
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
                
                self.client = loggedInClient
                self.setActiveServer(id: server.id)
                await self.fetchMetadata()
                
                self.isLoggedIn = true
                await qBitData.shared.getMainData()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .auth, eventName: "auto_connect_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func refreshClient() async {
        refreshClientCallCount += 1
        guard let activeId = activeServerId, let server = getServer(id: activeId) else { return }

        let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth, customHeaders: server.customHeaders)
        let newClient = qBittorrentClient(networkClient: networkClient)

        do {
            try await newClient.login(username: server.username, password: server.password)
            self.client = newClient
            self.isLoggedIn = true
            AppLogger.log(.info, SystemEventPayload(category: .system, eventName: "client_refresh_success", message: "Successfully refreshed client for server: \(server.name)"))
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .system, eventName: "client_refresh_failed", errorDescription: error.localizedDescription))
        }
    }

    func reauthenticate() async throws {
        reauthAttemptCount += 1
        guard let activeId = activeServerId, let server = getServer(id: activeId) else {
            throw NetworkError.unauthorized
        }
        
        let networkClient = NetworkClient(baseURL: server.url, basicAuth: server.basicAuth, customHeaders: server.customHeaders)
        let newClient = qBittorrentClient(networkClient: networkClient)
        
        do {
            try await newClient.login(username: server.username, password: server.password)
            self.client = newClient
            self.isLoggedIn = true
            AppLogger.log(.info, SystemEventPayload(category: .auth, eventName: "silent_reauth_success", message: "Successfully silently reauthenticated server: \(server.name)"))
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .auth, eventName: "silent_reauth_failed", errorDescription: error.localizedDescription))
            
            if let networkError = error as? NetworkError, networkError == .unauthorized {
                // Permanent auth failure (e.g. password changed) -> Log out and show login screen
                self.isLoggedIn = false
                self.client = nil
                self.clearCache()
            }
            throw error
        }
    }
    
    func fetchMetadata() async {
        guard let client = client else { return }
        do {
            self.preferences = try await client.getPreferences()
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .system, eventName: "fetch_preferences_failed", errorDescription: error.localizedDescription))
        }
        do {
            self.categories = try await client.getCategories()
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_categories_failed", errorDescription: error.localizedDescription))
        }
        do {
            self.tags = try await client.getTags()
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_tags_failed", errorDescription: error.localizedDescription))
        }
    }
    
    func refreshCategories() {
        Task {
            do {
                if let client = client {
                    self.categories = try await client.getCategories()
                }
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "refresh_categories_failed", errorDescription: error.localizedDescription))
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
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "refresh_tags_failed", errorDescription: error.localizedDescription))
            }
        }
    }
}
