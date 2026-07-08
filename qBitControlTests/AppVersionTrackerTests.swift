//
//  AppVersionTrackerTests.swift
//  qBitControlTests
//

import XCTest
@testable import qBitManager

final class AppVersionTrackerTests: XCTestCase {
    
    private var testDefaults: UserDefaults!
    private let suiteName = "AppVersionTrackerTestsSuite"
    
    override func setUp() {
        super.setUp()
        // Use a sandboxed suite to avoid polluting the app's real defaults
        testDefaults = UserDefaults(suiteName: suiteName)
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        super.tearDown()
    }
    
    func test_firstInstall_returnsFirstInstall_andPersistsVersion() {
        let tracker = AppVersionTracker(currentVersion: "1.4.0", defaults: testDefaults)
        
        let result = tracker.determineLaunchType(hasConfiguredServers: false)
        
        XCTAssertEqual(result, .firstInstall)
        XCTAssertEqual(testDefaults.string(forKey: "lastSeenVersion"), "1.4.0")
        
        // Subsequent launch should be normal
        let nextResult = tracker.determineLaunchType(hasConfiguredServers: false)
        XCTAssertEqual(nextResult, .normal)
    }
    
    func test_existingUserMigration_returnsUpdate_andPersistsVersion() {
        let tracker = AppVersionTracker(currentVersion: "1.4.0", defaults: testDefaults)
        
        let result = tracker.determineLaunchType(hasConfiguredServers: true)
        
        XCTAssertEqual(result, .update(from: "legacy"))
        XCTAssertEqual(testDefaults.string(forKey: "lastSeenVersion"), "1.4.0")
        
        // Subsequent launch should be normal
        let nextResult = tracker.determineLaunchType(hasConfiguredServers: true)
        XCTAssertEqual(nextResult, .normal)
    }
    
    func test_normalLaunch_returnsNormal() {
        testDefaults.set("1.4.0", forKey: "lastSeenVersion")
        let tracker = AppVersionTracker(currentVersion: "1.4.0", defaults: testDefaults)
        
        let result = tracker.determineLaunchType(hasConfiguredServers: true)
        
        XCTAssertEqual(result, .normal)
    }
    
    func test_appUpdate_returnsUpdate_andUpdatesPersistedVersion() {
        testDefaults.set("1.3.0", forKey: "lastSeenVersion")
        let tracker = AppVersionTracker(currentVersion: "1.4.0", defaults: testDefaults)
        
        let result = tracker.determineLaunchType(hasConfiguredServers: true)
        
        XCTAssertEqual(result, .update(from: "1.3.0"))
        XCTAssertEqual(testDefaults.string(forKey: "lastSeenVersion"), "1.4.0")
        
        // Subsequent launch should be normal
        let nextResult = tracker.determineLaunchType(hasConfiguredServers: true)
        XCTAssertEqual(nextResult, .normal)
    }
}
