//
//  LogStore.swift
//  qBitControl
//

import Foundation

actor LogStore {
    static let shared = LogStore()
    
    private let maxFileSize: Int = 1_000_000 // 1 MB limit per file
    private let maxFileCount = 3
    private let logFolderName = "Logs"
    private let activeLogFileName = "current_log.txt"
    
    private var logsDirectory: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDir = paths[0].appendingPathComponent("MikeMichael.qBitControl", isDirectory: true)
        let logsDir = appSupportDir.appendingPathComponent(logFolderName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: logsDir.path) {
            try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true, attributes: nil)
        }
        return logsDir
    }
    
    private var activeLogFileURL: URL {
        return logsDirectory.appendingPathComponent(activeLogFileName)
    }
    
    func write(line: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let sanitizedLine = LogAnonymizer.anonymize(line)
        let outputLine = "[\(timestamp)] \(sanitizedLine)\n"
        
        guard let data = outputLine.data(using: .utf8) else { return }
        
        self.rollFilesIfNeeded(upcomingDataSize: data.count)
        
        let fileURL = activeLogFileURL
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
        } else {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
    
    func getLogFileURLs() -> [URL] {
        var urls: [URL] = []
        let fileManager = FileManager.default
        let dir = logsDirectory
        
        let active = activeLogFileURL
        if fileManager.fileExists(atPath: active.path) {
            urls.append(active)
        }
        
        for i in 1..<maxFileCount {
            let rotatedURL = dir.appendingPathComponent("current_log_\(i).txt")
            if fileManager.fileExists(atPath: rotatedURL.path) {
                urls.append(rotatedURL)
            }
        }
        return urls
    }
    
    func loadAllLogs() -> String {
        let urls = getLogFileURLs()
        var combinedLogs = ""
        
        for url in urls.reversed() {
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                combinedLogs += contents
            }
        }
        return combinedLogs
    }
    
    func clearAllLogs() {
        let fileManager = FileManager.default
        let urls = getLogFileURLs()
        for url in urls {
            try? fileManager.removeItem(at: url)
        }
    }
    
    func exportCombinedLogsURL() -> URL? {
        let contents = loadAllLogs()
        let tempDir = FileManager.default.temporaryDirectory
        let exportURL = tempDir.appendingPathComponent("qBitControl_Sanitized_Logs.txt")
        do {
            try contents.write(to: exportURL, atomically: true, encoding: .utf8)
            return exportURL
        } catch {
            return nil
        }
    }
    
    private func rollFilesIfNeeded(upcomingDataSize: Int) {
        let fileURL = activeLogFileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let size = attributes[.size] as? Int else { return }
        
        if size + upcomingDataSize > maxFileSize {
            let fileManager = FileManager.default
            let dir = logsDirectory
            
            let oldestURL = dir.appendingPathComponent("current_log_\(maxFileCount - 1).txt")
            if fileManager.fileExists(atPath: oldestURL.path) {
                try? fileManager.removeItem(at: oldestURL)
            }
            
            for i in (1..<(maxFileCount - 1)).reversed() {
                let source = dir.appendingPathComponent("current_log_\(i).txt")
                let destination = dir.appendingPathComponent("current_log_\(i + 1).txt")
                if fileManager.fileExists(atPath: source.path) {
                    try? fileManager.moveItem(at: source, to: destination)
                }
            }
            
            let dest1 = dir.appendingPathComponent("current_log_1.txt")
            try? fileManager.moveItem(at: fileURL, to: dest1)
        }
    }
}
