//


import Foundation

struct SheetIdentifier: Identifiable {
    enum Choice {
        case showAbout
        case showLogs
    }
        
    var id: Choice
}