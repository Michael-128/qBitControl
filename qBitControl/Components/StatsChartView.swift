//

import SwiftUI
import Charts

struct StatsChartView: View {
    
    @Binding public var transferData: [TransferInfo]
    public var color: Color = .blue
    var formatter: TorrentFormatting = TorrentFormatter()
    
    var body: some View {
        VStack {
            TimelineView(.periodic(from: .now, by: 0.1)) { timeline in
                let now = timeline.date
                
                Chart(transferData.suffix(30)) { item in
                    let relativeTime = item.fetchDate.timeIntervalSince(now)
                    AreaMark(
                        x: .value("Time", relativeTime),
                        y: .value("Transfer", item.info_speed),
                        stacking: .standard
                    ).interpolationMethod(.monotone)
                        .mask { RectangleMark() }
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [self.color.opacity(0.4), self.color.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    LineMark(
                        x: .value("Time", relativeTime),
                        y: .value("Transfer", item.info_speed)
                    ).interpolationMethod(.monotone)
                        .mask { RectangleMark() }
                        .foregroundStyle(self.color)
                }
                .chartXScale(domain: -34 ... -4)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(formatter.getFormatedSize(size: value.as(Int64.self)!))/s")
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(String(abs(value.as(Int.self)!)))s")
                        }
                    }
                }
            }
        }.padding(10)
    }
}
