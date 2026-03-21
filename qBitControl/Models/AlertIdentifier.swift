//


import Foundation

struct AlertIdentifier: Identifiable {
    enum Choice {
        case resumeCurrent, resumeAll, pauseAll
    }
        
    var id: Choice
}
