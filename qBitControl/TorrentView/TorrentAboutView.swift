//

import Foundation
import SwiftUI

struct TorrentAboutView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var appInfo = AppInfo.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                Text("qBitControl \(appInfo.version) (\(appInfo.build))")
                    .font(.title)
                Text("qBitControl is the definitive remote client for managing your qBittorrent downloads on iOS devices.")
                    .multilineTextAlignment(.center)
                List {
                    Link("GitHub", destination: URL(string: "https://github.com/Michael-128/qBitControl")!)
                    Link("Patreon", destination: URL(string: "https://patreon.com/michael128")!)
                    Link("Report a bug", destination: URL(string: "https://github.com/Michael-128/qBitControl/issues")!)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
