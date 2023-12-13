//

import SwiftUI

struct TorrentStatsView: View {
    
    @State public var globalTransferInfo: [GlobalTransferInfo] = []
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    func getGlobalTransferInfo() {
        print("fetching")
        qBittorrent.getGlobalTransferInfo {
            info in
            globalTransferInfo.append(info)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let globalTransferInfo = globalTransferInfo.last {
                    List {
                        Section(header: Text("Download")) {
                            ListElement(label: "Total Session Download", value: "\(qBittorrent.getFormatedSize(size: globalTransferInfo.dl_info_data))")
                            ListElement(label: "Total Download Speed", value: "\(qBittorrent.getFormatedSize(size: globalTransferInfo.dl_info_speed))/s")
                            DownloadChartElement(transferData: $globalTransferInfo)
                        }
                        
                        Section(header: Text("Upload")) {
                            ListElement(label: "Total Session Upload", value: "\(qBittorrent.getFormatedSize(size: globalTransferInfo.up_info_data))")
                            ListElement(label: "Total Upload Speed", value: "\(qBittorrent.getFormatedSize(size: globalTransferInfo.up_info_speed))/s")
                            UploadChartElement(transferData: $globalTransferInfo)
                        }
                    }
                } else {
                    List {
                        Section(header: Text("Download")) {
                            ListElement(label: "Total Session Download", value: "\(qBittorrent.getFormatedSize(size: 0))")
                            ListElement(label: "Total Download Speed", value: "\(qBittorrent.getFormatedSize(size: 0))/s")
                            DownloadChartElement(transferData: $globalTransferInfo)
                        }
                        
                        Section(header: Text("Upload")) {
                            ListElement(label: "Total Session Upload", value: "\(qBittorrent.getFormatedSize(size: 0))")
                            ListElement(label: "Total Upload Speed", value: "\(qBittorrent.getFormatedSize(size: 0))/s")
                            UploadChartElement(transferData: $globalTransferInfo)
                        }
                    }
                }
            }.navigationTitle("Statistics")
                .onAppear {
                    getGlobalTransferInfo()
                    
                    timer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true) {
                        _ in
                        getGlobalTransferInfo()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
        }
    }
}
