//
//  LoggablePayload.swift
//  qBitControl
//

import Foundation

enum LogCategory: String {
    case network = "NETWORK"
    case auth = "AUTH"
    case rss = "RSS"
    case torrents = "TORRENT"
    case system = "SYSTEM"
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
}

protocol LoggablePayload {
    var category: LogCategory { get }
    var eventName: String { get }
    var parameters: [String: Any] { get }
}
