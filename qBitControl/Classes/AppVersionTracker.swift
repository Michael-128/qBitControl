//
//  AppVersionTracker.swift
//  qBitControl
//

import Foundation

class AppVersionTracker {
    let currentVersion: String
    private let defaults: UserDefaults
    private let lastSeenKey = "lastSeenVersion"
    
    enum LaunchType: Equatable {
        case firstInstall
        case update(from: String)
        case normal
    }
    
    init(currentVersion: String, defaults: UserDefaults = .standard) {
        self.currentVersion = currentVersion
        self.defaults = defaults
    }
    
    /// Determines the launch type and immediately persists the new version to prevent duplicate prompt runs.
    func determineLaunchType(hasConfiguredServers: Bool) -> LaunchType {
        let lastSeen = defaults.string(forKey: lastSeenKey)
        
        // Safety First: Write the current version immediately.
        // Even if the UI crashes or fails to present the prompt, we prevent any looping.
        defaults.set(currentVersion, forKey: lastSeenKey)
        
        guard let lastSeenVersion = lastSeen else {
            if hasConfiguredServers {
                // Existing user updating to this version for the first time
                return .update(from: "legacy")
            } else {
                // Brand new install
                return .firstInstall
            }
        }
        
        if lastSeenVersion != currentVersion {
            return .update(from: lastSeenVersion)
        }
        
        return .normal
    }
}
