//
//  TorrentRowView.swift
//  qBitControl
//

import SwiftUI

struct TorrentRowView: View {
    let name: String
    let progress: Float
    let state: String
    let dlspeed: Int64
    let upspeed: Int64
    let ratio: Float
    let size: Int64
    let eta: Int
    
    var formatter: TorrentFormatting = TorrentFormatter()
    
    let iconLeftPadding = -5.0
    
    let screenWidth = UIScreen.main.bounds.width
    
    struct DetailItem: Identifiable {
        let id = UUID()
        let view: AnyView
    }
    
    private func getRowItems() -> [DetailItem] {
        var items: [DetailItem] = []
        
        // 1. Always show progress
        items.append(DetailItem(view: AnyView(
            Text("\(String(format: "%.1f", progress * 100))%")
                .monospacedDigit()
        )))
        
        if progress < 1.0 {
            let isPaused = state == "pausedDL" || state == "stoppedDL" || state.contains("paused") || state.contains("stopped")
            
            if isPaused {
                // Paused but not completed: show ratio instead of DL speed
                items.append(DetailItem(view: AnyView(
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("\(String(format: "%.2f", ratio))")
                            .monospacedDigit()
                    }
                )))
            } else {
                // Not completed and active: show download speed and remaining
                items.append(DetailItem(view: AnyView(
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.down")
                        Text("\(formatter.getFormatedSize(size: dlspeed))/s")
                            .monospacedDigit()
                    }
                )))
                
                if eta > 0 && eta < 8640000 {
                    let remainingText = "\(formatter.getFormattedTime(time: eta)) \(NSLocalizedString("remaining", comment: "remaining time"))"
                    items.append(DetailItem(view: AnyView(
                        Text(remainingText)
                            .monospacedDigit()
                    )))
                }
            }
        } else {
            // Completed: show upload speed (only if active) and ratio
            if upspeed > 0 {
                items.append(DetailItem(view: AnyView(
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                        Text("\(formatter.getFormatedSize(size: upspeed))/s")
                            .monospacedDigit()
                    }
                )))
            }
            
            items.append(DetailItem(view: AnyView(
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("\(String(format: "%.2f", ratio))")
                        .monospacedDigit()
                }
            )))
        }
        
        return items
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
                
                let items = getRowItems()
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    item.view
                    
                    if index < items.count - 1 {
                        Text("•")
                            .foregroundColor(.gray)
                    }
                }
                
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
