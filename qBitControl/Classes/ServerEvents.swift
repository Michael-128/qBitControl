//

import Foundation


class ServerEvents {
    static private var onChangeActions: [ServerAction] = []
    
    static func addOnChangeAction(action: ServerAction) {
        removeOnChangeAction(name: action.name)
        
        onChangeActions.append(action)
    }
    
    static func removeOnChangeAction(name: String) {
        onChangeActions.removeAll {
            action in
            return action.name == name
        }
    }
    
    static func callOnChangeActions() {
        onChangeActions.forEach {
            action in
            action.action()
        }
    }
}
