//

import SwiftUI

struct StatsView: View {
    
    @ObservedObject var qBitDataShared = qBitData.shared
    var formatter: TorrentFormatting = TorrentFormatter()
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Download")) {
                        CustomLabelView(label: "Session Download", value: "\(formatter.getFormatedSize(size: qBitDataShared.serverState?.dl_info_data ?? 0))")
                        CustomLabelView(label: "Download Speed", value: "\(formatter.getFormatedSize(size: Int64(getDelayedSpeed(from: qBitDataShared.dlTransferData))))/s")
                        StatsChartView(transferData: $qBitDataShared.dlTransferData, color: .green)
                    }
                    
                    Section(header: Text("Upload")) {
                        CustomLabelView(label: "Session Upload", value: "\(formatter.getFormatedSize(size: qBitDataShared.serverState?.up_info_data ?? 0))")
                        CustomLabelView(label: "Upload Speed", value: "\(formatter.getFormatedSize(size: Int64(getDelayedSpeed(from: qBitDataShared.upTransferData))))/s")
                        StatsChartView(transferData: $qBitDataShared.upTransferData)
                    }
                    
                    Section(header: Text("Disk")) {
                        CustomLabelView(label: "Free Space", value: "\(formatter.getFormatedSize(size: qBitDataShared.serverState?.free_space_on_disk ?? 0))")
                    }
                    
                    Section(header: Text("All-Time")) {
                        CustomLabelView(label: "Upload", value: "\(formatter.getFormatedSize(size: qBitDataShared.serverState?.alltime_ul ?? 0))")
                        CustomLabelView(label: "Download", value: "\(formatter.getFormatedSize(size: qBitDataShared.serverState?.alltime_dl ?? 0))")
                        CustomLabelView(label: "Ratio", value: "\(qBitDataShared.serverState?.global_ratio ?? "0.00")")
                    }
                }
            }.navigationTitle("Statistics")
        }
    }
    
    private func getDelayedSpeed(from transferData: [TransferInfo], delay: TimeInterval = 4.0) -> Int {
        let targetDate = Date().addingTimeInterval(-delay)
        return transferData.min(by: {
            abs($0.fetchDate.timeIntervalSince(targetDate)) < abs($1.fetchDate.timeIntervalSince(targetDate))
        })?.info_speed ?? 0
    }
}
