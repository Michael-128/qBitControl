//


import Foundation

struct AlertIdentifier: Identifiable {
    enum Choice {
        case resumeAll, pauseAll
    }
        
    var id: Choice
}