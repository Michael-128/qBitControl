//

import Foundation
import SwiftUI

class AppInfo: ObservableObject {
    static let shared = AppInfo()
    
    @Published public var version: String
    @Published public var build: String
    
    init() {
        let infoDictionary = Bundle.main.infoDictionary
        
        version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        build = infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
