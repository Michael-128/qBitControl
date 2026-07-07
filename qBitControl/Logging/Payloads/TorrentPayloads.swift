//
//  TorrentPayloads.swift
//  qBitControl
//

import Foundation
import CryptoKit

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

// Private helpers for anonymization
private extension String {
    func sha256Hash() -> String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func replacingHomeDirectoryWithTilde() -> String {
        let home = NSHomeDirectory()
        if self.hasPrefix(home) {
            return "~" + self.dropFirst(home.count)
        }
        return self
    }
}
