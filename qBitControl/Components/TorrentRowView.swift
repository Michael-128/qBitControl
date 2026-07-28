//
//  TorrentRowView.swift
//  qBitControl
//

import SwiftUI

struct TorrentRowView: View, Equatable {
    let name: String
    let progress: Float
    let state: String
    let dlspeed: Int64
    let upspeed: Int64
    let ratio: Float
    let size: Int64
    let eta: Int
    
    static func == (lhs: TorrentRowView, rhs: TorrentRowView) -> Bool {
        return lhs.name == rhs.name &&
               lhs.progress == rhs.progress &&
               lhs.state == rhs.state &&
               lhs.dlspeed == rhs.dlspeed &&
               lhs.upspeed == rhs.upspeed &&
               lhs.ratio == rhs.ratio &&
               lhs.size == rhs.size &&
               lhs.eta == rhs.eta
    }
    
    var formatter: TorrentFormatting = TorrentFormatter()
    
    let iconLeftPadding = -5.0
    
    let screenWidth = UIScreen.main.bounds.width
    
    @ViewBuilder
    private func rowDetailsView() -> some View {
        Text("\(String(format: "%.1f", progress * 100))%")
            .monospacedDigit()
        
        if progress < 1.0 {
            let isPaused = state == "pausedDL" || state == "stoppedDL" || state.contains("paused") || state.contains("stopped")
            
            if isPaused {
                Text("•").foregroundColor(.gray)
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("\(String(format: "%.2f", ratio))")
                        .monospacedDigit()
                }
            } else {
                Text("•").foregroundColor(.gray)
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                    Text("\(formatter.getFormatedSize(size: dlspeed))/s")
                        .monospacedDigit()
                }
                
                if eta > 0 && eta < 8640000 {
                    Text("•").foregroundColor(.gray)
                    Text("\(formatter.getFormattedTime(time: eta)) \(NSLocalizedString("remaining", comment: "remaining time"))")
                        .monospacedDigit()
                }
            }
        } else {
            if upspeed > 0 {
                Text("•").foregroundColor(.gray)
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                    Text("\(formatter.getFormatedSize(size: upspeed))/s")
                        .monospacedDigit()
                }
            }
            
            Text("•").foregroundColor(.gray)
            HStack(spacing: 2) {
                Image(systemName: "arrow.up.arrow.down")
                Text("\(String(format: "%.2f", ratio))")
                    .monospacedDigit()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .bottom) {
                Text(name)
                    .lineLimit(1)
                Spacer()
            }.padding(.bottom, -1)
            
            SmoothProgressBar(
                progress: Double(progress),
                dlSpeed: dlspeed,
                totalSize: size,
                state: state
            )
            
            HStack(spacing: 5) {
                // Status Icon
                Image(systemName: "\(formatter.getStateIcon(state: state))")
                    .foregroundColor(formatter.getStateColor(state: state))
                    .font(.footnote)
                
                rowDetailsView()
                
                Spacer()
            }
                .font(.caption)
                .padding(.top, 1)
                .lineLimit(1)
        }
    }
}

struct TorrentRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                NavigationLink {
                    //MainView()
                } label: {
                    TorrentRowView(name: "Torrent name", progress: 0.789, state: "downloading", dlspeed:10000000, upspeed:1000000, ratio: 0.5, size: 1000000000, eta: 3600)
                }
            }
        }
    }
}
