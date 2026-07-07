//
//  TorrentAddInitiatedPayload.swift
//  qBitControl
//

import Foundation

struct TorrentAddInitiatedPayload: LoggablePayload {
    let category: LogCategory = .torrents
    let eventName = "torrent_add_initiated"
    
    let filename: String
    let savePath: String
    
    var parameters: [String: Any] {
        let anonymizedFilename = filename.sha256Hash()
        let sanitizedPath = savePath.replacingHomeDirectoryWithTilde()
        
        return [
            "filename_hash": anonymizedFilename,
            "save_path": sanitizedPath
        ]
    }
}
