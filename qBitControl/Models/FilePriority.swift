//
//  FilePriority.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 14/03/2026.
//

/**
 0     Do not download
 1     Normal priority
 6     High priority
 7     Maximal priority
 */

enum FilePriority: Int8, Codable {
    case unknown = -1
    case doNotDownload = 0
    case normal = 1
    case high = 6
    case max = 7
    
    init(priority: Int) {
        switch priority {
            case 0: self = .doNotDownload
            case 1: self = .normal
            case 6: self = .high
            case 7: self = .max
            default: self = .unknown
        }
    }
}
