//

import SwiftUI

struct TorrentStatsView: View {
    
    @ObservedObject var qBitDataShared = qBitData.shared
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Download")) {
                        ListElement(label: "Session Download", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.dl_info_data ?? 0))")
                        ListElement(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.dl_info_speed ?? 0))/s")
                        ChartElement(transferData: $qBitDataShared.dlTransferData)
                    }
                    
                    Section(header: Text("Upload")) {
                        ListElement(label: "Session Upload", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.up_info_data ?? 0))")
                        ListElement(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.up_info_speed ?? 0))/s")
                        ChartElement(transferData: $qBitDataShared.upTransferData)
                    }
                    
                    Section(header: Text("Disk")) {
                        ListElement(label: "Free Space", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.free_space_on_disk ?? 0))")
                    }
                    
                    Section(header: Text("All-Time")) {
                        ListElement(label: "Upload", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.alltime_ul ?? 0))")
                        ListElement(label: "Download", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.alltime_dl ?? 0))")
                        ListElement(label: "Ratio", value: "\(qBitDataShared.serverState?.global_ratio ?? "0.00")")
                    }
                }
            }.navigationTitle("Statistics")
        }
    }
}
