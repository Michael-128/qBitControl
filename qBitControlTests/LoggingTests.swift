//
//  LoggingTests.swift
//  qBitControlTests
//

import XCTest
@testable import qBitManager

final class LoggingTests: XCTestCase {
    
    // MARK: - LogAnonymizer Tests
    
    func testAnonymize_withPasswordQueryParam_redactsPassword() {
        let input = "GET /api/v2/auth/login?username=admin&password=mySecretPassword123&other=param"
        let output = LogAnonymizer.anonymize(input)
        
        XCTAssertTrue(output.contains("password=[REDACTED]"))
        XCTAssertFalse(output.contains("mySecretPassword123"))
        XCTAssertTrue(output.contains("username=admin"))
    }
    
    func testAnonymize_withBasicAuthHeader_redactsHeader() {
        let input = "Headers: [Authorization: Basic YWRtaW46MTIzNDU=, User-Agent: Swift]"
        let output = LogAnonymizer.anonymize(input)
        
        XCTAssertTrue(output.contains("Authorization: Basic [REDACTED]"))
        XCTAssertFalse(output.contains("YWRtaW46MTIzNDU="))
    }
    
    func testAnonymize_withInlineURLCredentials_redactsCredentials() {
        let input = "Connection target URL: http://my_user:secret_pwd@192.168.1.100:8080/api/v2"
        let output = LogAnonymizer.anonymize(input)
        
        XCTAssertTrue(output.contains("http://my_user:[REDACTED]@192.168.1.100:8080"))
        XCTAssertFalse(output.contains("secret_pwd"))
    }
    
    func testAnonymize_withRegularString_doesNotRedact() {
        let input = "[INFO] telemetry_fetch_completed -> size: 1024"
        let output = LogAnonymizer.anonymize(input)
        
        XCTAssertEqual(input, output)
    }
    
    // MARK: - Payload Sanitization Tests
    
    func testTorrentAddPayload_hashesFilename() {
        let filename = "Ubuntu-22.04-Desktop.iso"
        let payload = TorrentAddInitiatedPayload(filename: filename, savePath: "/Users/michal/Downloads")
        
        let params = payload.parameters
        XCTAssertNotNil(params["filename_hash"])
        
        let hash = params["filename_hash"] as? String
        XCTAssertEqual(hash?.count, 64) // SHA-256 length is 64 hex characters
        XCTAssertFalse(payload.parameters.values.contains(where: { String(describing: $0).contains(filename) }))
    }
    
    func testTorrentAddPayload_sanitizesSavePath() {
        let savePath = NSHomeDirectory() + "/Downloads/Movies"
        let payload = TorrentAddInitiatedPayload(filename: "file.torrent", savePath: savePath)
        
        let params = payload.parameters
        let sanitized = params["save_path"] as? String
        
        XCTAssertEqual(sanitized, "~/Downloads/Movies")
        XCTAssertFalse(sanitized?.contains(NSHomeDirectory()) ?? true)
    }
    
    // MARK: - LogStore Tests
    
    func testLogStore_respectsFileLimitsAndRotates() async {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        // Setup sandbox folder & limits override
        await LogStore.shared.setLogsDirectoryOverride(tempURL)
        await LogStore.shared.setMaxFileSizeOverride(100) // 100 bytes is extremely small (about 1-2 lines)
        
        // Write enough lines to force rotation multiple times
        await LogStore.shared.write(line: "Line 1: A very long log statement that will exceed the 100 byte limit instantly.")
        await LogStore.shared.write(line: "Line 2: Another extremely long log line to push it past the limits and force rotation.")
        await LogStore.shared.write(line: "Line 3: Yet another log line for the new active file.")
        
        let urls = await LogStore.shared.getLogFileURLs()
        
        // We should have at least 2 files (current_log.txt and current_log_1.txt)
        XCTAssertGreaterThanOrEqual(urls.count, 2)
        
        let activeURL = tempURL.appendingPathComponent("current_log.txt")
        let rotatedURL = tempURL.appendingPathComponent("current_log_1.txt")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: activeURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: rotatedURL.path))
        
        // Verify loading combined logs in correct order (newest first)
        let combined = await LogStore.shared.loadAllLogs()
        XCTAssertTrue(combined.contains("Line 3"))
        XCTAssertTrue(combined.contains("Line 2"))
        
        // Clean up
        await LogStore.shared.clearAllLogs()
        await LogStore.shared.setLogsDirectoryOverride(nil)
        await LogStore.shared.setMaxFileSizeOverride(nil)
        try? FileManager.default.removeItem(at: tempURL)
    }
}

// Private helper extensions on LogStore actor for testing injection
private extension LogStore {
    func setLogsDirectoryOverride(_ url: URL?) {
        self.logsDirectoryOverride = url
    }
    
    func setMaxFileSizeOverride(_ size: Int?) {
        self.maxFileSizeOverride = size
    }
}
