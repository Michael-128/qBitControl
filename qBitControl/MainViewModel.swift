import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @ObservedObject var serversHelper = ServersHelper.shared

    func reconnectIfNeeded(on scenePhase: ScenePhase) {
        if scenePhase == .active && serversHelper.isLoggedIn {
            if let activeServerId = serversHelper.activeServerId {
                if let activeServer = serversHelper.getServer(id: activeServerId) {
                    serversHelper.connect(server: activeServer)
                }
            }
        }
    }
}
