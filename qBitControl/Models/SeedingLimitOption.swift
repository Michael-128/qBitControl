//
//  SeedingLimitOption.swift
//  qBitControl
//

import Foundation

enum SeedingLimitOption: String, CaseIterable, Identifiable {
    case global = "Global"
    case unlimited = "Unlimited"
    case custom = "Custom"
    
    var id: String { self.rawValue }
}

extension SeedingLimitOption {
    // Map from qBittorrent API values to our Enum
    static func from(ratioLimit: Float) -> SeedingLimitOption {
        if ratioLimit == -2 { return .global }
        if ratioLimit == -1 { return .unlimited }
        return .custom
    }

    static func from(timeLimit: Int) -> SeedingLimitOption {
        if timeLimit == -2 { return .global }
        if timeLimit == -1 { return .unlimited }
        return .custom
    }

    // Map from our Enum and input string back to API values
    func toRatioLimit(customValue: String) -> Float {
        switch self {
        case .global: return -2
        case .unlimited: return -1
        case .custom: return Float(customValue) ?? -1
        }
    }

    func toTimeLimit(customValue: String) -> Int {
        switch self {
        case .global: return -2
        case .unlimited: return -1
        case .custom: return Int(customValue) ?? -1
        }
    }
}
