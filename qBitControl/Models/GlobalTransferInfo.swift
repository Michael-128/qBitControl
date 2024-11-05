//


import Foundation

struct GlobalTransferInfo: Decodable, Identifiable {
    let id = UUID()
    var fetchDate: Date = Date.now
    let dl_info_speed: Int64 // integer     Global download rate (bytes/s)
    let dl_info_data: Int64 // integer     Data downloaded this session (bytes)
    let up_info_speed: Int64 // integer     Global upload rate (bytes/s)
    let up_info_data: Int64 // integer     Data uploaded this session (bytes)
    let dl_rate_limit: Int64 // integer     Download rate limit (bytes/s)
    let up_rate_limit: Int64 // integer     Upload rate limit (bytes/s)
    let dht_nodes: Int64 // integer     DHT nodes connected to
    let connection_status: String // string     Connection status. See possible values here below
    
    enum CodingKeys: CodingKey {
        case dl_info_speed
        case dl_info_data
        case up_info_speed
        case up_info_data
        case dl_rate_limit
        case up_rate_limit
        case dht_nodes
        case connection_status
    }
    
    init(fetchDate: Date, dlspeed: Int64, dldata: Int64, dllimit: Int64, upspeed: Int64, updata: Int64, uplimit: Int64, dhtnodes: Int64, connection_status: String) {
        self.fetchDate = fetchDate
        self.dl_info_speed = dlspeed
        self.dl_info_data = dldata
        self.dl_rate_limit = dllimit
        
        self.up_info_speed = upspeed
        self.up_info_data = updata
        self.up_rate_limit = uplimit
        
        self.dht_nodes = dhtnodes
        self.connection_status = connection_status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dl_info_data = try container.decode(Int64.self, forKey: .dl_info_data)
        self.dl_info_speed = try container.decode(Int64.self, forKey: .dl_info_speed)
        self.dl_rate_limit = try container.decode(Int64.self, forKey: .dl_rate_limit)
        
        self.up_info_data = try container.decode(Int64.self, forKey: .up_info_data)
        self.up_info_speed = try container.decode(Int64.self, forKey: .up_info_speed)
        self.up_rate_limit = try container.decode(Int64.self, forKey: .up_rate_limit)
        
        self.dht_nodes = try container.decode(Int64.self, forKey: .dht_nodes)
        self.connection_status = try container.decode(String.self, forKey: .connection_status)
    }
}