//
//  AppLogger.swift
//  qBitControl
//

import Foundation
import os.log

class AppLogger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "MikeMichael.qBitControl"
    
    private static let loggers: [LogCategory: OSLog] = [
        .network: OSLog(subsystem: subsystem, category: "Network"),
        .auth: OSLog(subsystem: subsystem, category: "Auth"),
        .rss: OSLog(subsystem: subsystem, category: "RSS"),
        .torrents: OSLog(subsystem: subsystem, category: "Torrents"),
        .system: OSLog(subsystem: subsystem, category: "System")
    ]
    
    static func log(_ level: LogLevel = .info, _ payload: LoggablePayload) {
        let eventName = payload.eventName
        let parametersString = payload.parameters
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: ", ")
            
        let line = "[\(level.rawValue)] [\(payload.category.rawValue)] \(eventName) -> \(parametersString)"
        
        // 1. Write to System Console (OSLog)
        let osLogType = self.osLogType(for: level)
        let osLog = loggers[payload.category] ?? OSLog.default
        os_log("%{public}@", log: osLog, type: osLogType, line)
        
        // 2. Write to asynchronous LogStore
        Task {
            await LogStore.shared.write(line: line)
        }
    }
    
    private static func osLogType(for level: LogLevel) -> OSLogType {
        switch level {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}
