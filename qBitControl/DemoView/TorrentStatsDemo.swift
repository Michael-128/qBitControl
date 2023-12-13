//

import SwiftUI

struct TorrentStatsDemo: View {
    
    @State public var globalTransferInfo: [GlobalTransferInfo] = []
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Download")) {
                        ListElement(label: "Total Session Download", value: "\(qBittorrent.getFormatedSize(size: 299000))")
                        ListElement(label: "Total Download Speed", value: "\(qBittorrent.getFormatedSize(size: 0))/s")
                        ChartDemo()
                    }
                    
                    Section(header: Text("Upload")) {
                        ListElement(label: "Total Session Upload", value: "\(qBittorrent.getFormatedSize(size: 192000))")
                        ListElement(label: "Total Upload Speed", value: "\(qBittorrent.getFormatedSize(size: 0))/s")
                        ChartDemo()
                    }
                }
            }.navigationTitle("Statistics")
        }
    }
}
