//

import SwiftUI
import Charts

struct StatsChartView: View {
    
    @Binding public var transferData: [TransferInfo]
    
    var body: some View {
        VStack {
            Chart(transferData.suffix(30)) {
                transferData in
                AreaMark(
                    x: .value("Time", transferData.fetchDate.timeIntervalSinceNow),
                    y: .value("Transfer", transferData.info_speed),
                    stacking: .standard
                ).interpolationMethod(.monotone)
                    .mask { RectangleMark() }
            }.chartXScale(domain: -30...0)
                .chartYAxis {
                    AxisMarks {
                        value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(qBittorrent.getFormatedSize(size: value.as(Int64.self)!))/s")
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(String(abs(value.as(Int.self)!)))s")
                        }
                    }
                }
        }.padding(10)
    }
}
