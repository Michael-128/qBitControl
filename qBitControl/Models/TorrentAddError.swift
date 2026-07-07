//
//  TorrentAddError.swift
//  qBitControl
//

import Foundation

enum TorrentAddError: LocalizedError, Identifiable {
    case invalidFileOrMagnet
    case unauthorized
    case timeout
    case duplicate
    case unknown(Int)
    
    var id: String {
        switch self {
        case .invalidFileOrMagnet: return "invalidFileOrMagnet"
        case .unauthorized: return "unauthorized"
        case .timeout: return "timeout"
        case .duplicate: return "duplicate"
        case .unknown(let code): return "unknown_\(code)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidFileOrMagnet:
            return NSLocalizedString("The torrent file or magnet URL is invalid or unsupported.", comment: "Torrent invalid file/magnet error")
        case .unauthorized:
            return NSLocalizedString("Unauthorized. Please re-login to the server.", comment: "Torrent add unauthorized error")
        case .timeout:
            return NSLocalizedString("Request timed out. Please check your network connection.", comment: "Torrent add timeout error")
        case .duplicate:
            return NSLocalizedString("This torrent is already in your download list.", comment: "Torrent add duplicate error")
        case .unknown(let statusCode):
            return String(format: NSLocalizedString("Server returned error code %d.", comment: "Torrent add unknown error"), statusCode)
        }
    }
}
