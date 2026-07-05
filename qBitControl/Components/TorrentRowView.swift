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
    
    var formatter: TorrentFormatting = TorrentFormatter()
    
    let iconLeftPadding = -5.0
    
    let screenWidth = UIScreen.main.bounds.width
    
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
            
            HStack(spacing: 3.5) {
                Group {
                    Image(systemName: "\(formatter.getStateIcon(state: state))")
                        .foregroundColor(formatter.getStateColor(state: state))
                        .font(.footnote)
                    //Text("\(formatter.getState(state: state))")
                        .lineLimit(1)
                }
                Group {
                    Text("\(String(format: "%.1f", progress*100))%")
                        .monospacedDigit()
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.down")
                    Text("\(formatter.getFormatedSize(size: dlspeed))/s")
                        .monospacedDigit()
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.up")
                    Text("\(formatter.getFormatedSize(size: upspeed))/s")
                        .monospacedDigit()
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("\(String(format: "%.2f", ratio))")
                        .monospacedDigit()
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
                    TorrentRowView(name: "Torrent name", progress: 0.789, state: "downloading", dlspeed:10000000, upspeed:1000000, ratio: 0.5, size: 1000000000)
                }
            }
        }
    }
}
