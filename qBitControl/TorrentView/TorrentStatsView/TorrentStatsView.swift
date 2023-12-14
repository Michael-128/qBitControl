//

import SwiftUI

struct TorrentStatsView: View {
    
    @State public var globalTransferInfo: [GlobalTransferInfo] = []
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    @State private var torrents: [Torrent] = []
    
    @State private var totalUpload: Int64?
    @State private var totalDownload: Int64?
    @State private var totalRatio: Float?
    
    func getTorrents() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            torrents = torrent
            
            totalUpload = torrent.compactMap {torrent in torrent.uploaded}.reduce(into: 0) {sum, upload in sum += upload}
            totalDownload = torrent.compactMap {torrent in torrent.downloaded}.reduce(into: 0) {sum, download in sum += download}
            totalRatio = torrent.compactMap {torrent in torrent.ratio}.reduce(into: 0.0) {sum, ratio in sum += ratio} / Float(torrents.count)
        }
    }
    
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
                List {
                    if let globalTransferInfo = globalTransferInfo.last {
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
                    } else {
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
                    
                    if let totalUpload = totalUpload, let totalDownload = totalDownload, let totalRatio = totalRatio {
                        Section(header: Text("All Time"), footer: Text("The displayed data is calculated only from torrents that are currently on the list.")) {
                            ListElement(label: "Total Upload", value: "\(qBittorrent.getFormatedSize(size: totalUpload))")
                            ListElement(label: "Total Download", value: "\(qBittorrent.getFormatedSize(size: totalDownload))")
                            ListElement(label: "Total Ratio", value: "\((totalRatio*100).rounded()/100)")
                        }
                    }
                }
            }.navigationTitle("Statistics")
                .onAppear {
                    getGlobalTransferInfo()
                    getTorrents()
                    
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
