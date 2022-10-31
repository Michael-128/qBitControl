//
//  TorrentRowView.swift
//  TorrentAttempt
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
    
    /*func mixGreenAndRed(greenAmount: Double) -> Color {
        // the hues between red and green go from 0…1/3, so we can just divide percentageGreen by 3 to mix between them
        return Color(hue: greenAmount / 3, saturation: 1.0, brightness: 1.0)
    }*/
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "\(qBittorrent.getStateIcon(state: state))")
                    .padding(.trailing, iconLeftPadding)
                    .foregroundColor(qBittorrent.getStateColor(state: state))
                Spacer()
                Text(name)
                    .lineLimit(1)
                Spacer()
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: qBittorrent.getStateColor(state: state)))
            
            HStack(alignment: .center) {
                /*Group {
                    Image(systemName: "\(qBittorrent.getStateIcon(state: state))")
                        .padding(.trailing, iconLeftPadding)
                    Text(qBittorrent.getState(state: state))
                        .font(.footnote)
                        .lineLimit(1)
                }
                
                Spacer()*/
                
                Group {
                    Image(systemName: "arrow.down.circle")
                        .padding(.trailing, iconLeftPadding)
                    Text("\(qBittorrent.getFormatedSize(size: dlspeed))/s")
                        .font(.footnote)
                        .lineLimit(1)
                }
                    .foregroundColor(dlspeed > 0 ? Color.green : Color.gray)
                
                Spacer()
                
                Group {
                    Image(systemName: "arrow.up.circle")
                        .padding(.trailing, iconLeftPadding)
                    Text("\(qBittorrent.getFormatedSize(size: upspeed))/s")
                        .font(.footnote)
                        .lineLimit(1)
                        
                }
                .foregroundColor(upspeed > 0 ? Color.blue : Color.gray)
                
                Spacer()
                
                Group {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .padding(.trailing, iconLeftPadding)
                    Text(String(format: "%.2f", ratio))
                        .font(.footnote)
                        .lineLimit(1)
                }
                .multilineTextAlignment(.trailing)
                //.foregroundColor(ratio > 1.0 ? Color.green : mixGreenAndRed(greenAmount: Double(ratio)))
            }
        }
        
        
    }
}

struct TorrentRowView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentRowView(name: "Torrent name", progress: 0.75, state: "downloading", dlspeed:10000000, upspeed:1000000, ratio: 0.5)
    }
}
