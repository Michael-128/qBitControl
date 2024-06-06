import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var shouldAttemptAutoLogIn: Bool = true
    
    private var defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    private var serversHelper = ServersHelper()
    
    func attemptAutoLogIn() {
        if let activeServer = serversHelper.getActiveServer() {
            serversHelper.connect(server: activeServer) { success in
                DispatchQueue.main.async {
                    self.isLoggedIn = success
                    self.shouldAttemptAutoLogIn = false
                }
            }
        } else {
            DispatchQueue.main.async {
                self.shouldAttemptAutoLogIn = false
            }
        }
    }
    
    func reconnectIfNeeded(on scenePhase: ScenePhase) {
        if scenePhase == .active && isLoggedIn {
            if let activeServer = serversHelper.getActiveServer() {
                serversHelper.connect(server: activeServer) { success in
                    DispatchQueue.main.async {
                        if !success {
                            self.isLoggedIn = false
                        }
                    }
                }
            }
        }
    }
}
