//

import SwiftUI
import Charts

struct ChartDemo: View {
    
    public var transferData: [GlobalTransferInfo] = [
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0), dlspeed: 0, dldata: 10000000, dllimit: 0, upspeed: 0, updata: 200000, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-2, dlspeed: 10000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-4, dlspeed: 15000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-6, dlspeed: 20000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-8, dlspeed: 30000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-10, dlspeed: 40000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-12, dlspeed: 35000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-14, dlspeed: 30000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-16, dlspeed: 5000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-18, dlspeed: 10000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-20, dlspeed: 15000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-22, dlspeed: 20000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-24, dlspeed: 30000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-26, dlspeed: 20000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-28, dlspeed: 10000, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
        GlobalTransferInfo(fetchDate: Date(timeIntervalSince1970: 0)-30, dlspeed: 0, dldata: 100000, dllimit: 0, upspeed: 0, updata: 0, uplimit: 0, dhtnodes: 0, connection_status: "connected"),
    ]
    
    var body: some View {
        VStack {
            Chart(transferData.suffix(30)) {
                transferData in
                AreaMark(
                    x: .value("Time", transferData.fetchDate.timeIntervalSince1970),
                    y: .value("Download", transferData.dl_info_speed),
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

