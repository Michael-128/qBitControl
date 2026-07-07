//
//  TorrentAddSuccessPayload.swift
//  qBitControl
//

import Foundation

struct TorrentAddSuccessPayload: LoggablePayload {
    let category: LogCategory = .torrents
    let eventName = "torrent_add_success"
    
    let filename: String
    
    var parameters: [String: Any] {
        return [
            "filename_hash": filename.sha256Hash()
        ]
    }
}
