import Foundation

enum ShareLimitAction: String, CaseIterable, Identifiable, Codable {
    case global = "Default"
    case stop = "Stop"
    case remove = "Remove"
    case removeWithContent = "RemoveWithContent"
    case superSeeding = "EnableSuperSeeding"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .global:
            return NSLocalizedString("Default", comment: "")
        case .stop:
            return NSLocalizedString("Pause / Stop", comment: "")
        case .remove:
            return NSLocalizedString("Remove", comment: "")
        case .removeWithContent:
            return NSLocalizedString("Remove with Files", comment: "")
        case .superSeeding:
            return NSLocalizedString("Super Seeding", comment: "")
        }
    }
    
    static func from(integer: Int) -> ShareLimitAction {
        switch integer {
        case 0: return .global
        case 1: return .stop
        case 2: return .remove
        case 3: return .removeWithContent
        case 4: return .superSeeding
        default: return .global
        }
    }
    
    var toInteger: Int {
        switch self {
        case .global: return 0
        case .stop: return 1
        case .remove: return 2
        case .removeWithContent: return 3
        case .superSeeding: return 4
        }
    }
}
