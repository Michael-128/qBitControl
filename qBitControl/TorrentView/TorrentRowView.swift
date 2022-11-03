//
//  TorrentRowView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 26/10/2022.
//

import SwiftUI

struct TorrentRowView: View {
    let name: String
    let progress: Float
    let state: String
    let dlspeed: Int64
    let upspeed: Int64
    let ratio: Float
    
    let iconLeftPadding = -5.0
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(name)
                    .lineLimit(1)
                Spacer()
            }.padding(.bottom, -1)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: qBittorrent.getStateColor(state: state)))
            
            HStack(spacing: 3.5) {
                Group {
                    Image(systemName: "\(qBittorrent.getStateIcon(state: state))")
                        .foregroundColor(qBittorrent.getStateColor(state: state))
                        .font(.footnote)
                    //Text("\(qBittorrent.getState(state: state))")
                        .lineLimit(1)
                }
                Group {
                    Text("\(String(format: "%.1f", progress*100))%")
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.down")
                    Text("\(qBittorrent.getFormatedSize(size: dlspeed))/s")
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.up")
                    Text("\(qBittorrent.getFormatedSize(size: upspeed))/s")
                    Text("•")
                }
                Group {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("\(String(format: "%.2f", ratio))")
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
                    TorrentRowView(name: "Torrent name", progress: 0.789, state: "downloading", dlspeed:10000000, upspeed:1000000, ratio: 0.5)
                }
            }
        }
    }
}
