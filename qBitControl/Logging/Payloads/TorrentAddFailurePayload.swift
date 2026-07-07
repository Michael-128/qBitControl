//
//  TorrentAddFailurePayload.swift
//  qBitControl
//

import Foundation

struct TorrentAddFailurePayload: LoggablePayload {
    let category: LogCategory = .torrents
    let eventName = "torrent_add_failed"
    
    let filename: String
    let errorDescription: String
    
    var parameters: [String: Any] {
        return [
            "filename_hash": filename.sha256Hash(),
            "error": errorDescription
        ]
    }
}
