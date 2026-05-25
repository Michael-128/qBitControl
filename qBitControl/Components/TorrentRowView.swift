//
//  TorrentRowView.swift
//  qBitControl
//

import SwiftUI

struct TorrentRowView: View {
    let torrent: Torrent

    private var stateColor: Color { qBittorrent.getStateColor(state: torrent.state) }
    private var stateText: String { qBittorrent.getState(state: torrent.state) }
    private var stateIcon: String { qBittorrent.getStateIcon(state: torrent.state) }

    var body: some View {
        HStack(spacing: 10) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(stateColor)
                .frame(width: 4)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(torrent.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(stateColor)
                            .frame(width: geo.size.width * CGFloat(min(torrent.progress, 1.0)), height: 4)
                    }
                }
                .frame(height: 4)

                // Status line
                HStack(spacing: 4) {
                    Image(systemName: stateIcon)
                        .foregroundColor(stateColor)
                    Text(stateText)
                        .foregroundColor(stateColor)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Text(progressText)

                    if torrent.eta > 0 && torrent.eta < 8640000 && torrent.progress < 1.0 {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Image(systemName: "clock")
                        Text(formatETA(torrent.eta))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                // Speed & info line
                HStack(spacing: 4) {
                    if torrent.dlspeed > 0 {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.green)
                        Text("\(qBittorrent.getFormatedSize(size: torrent.dlspeed))/s")
                    }
                    if torrent.upspeed > 0 {
                        if torrent.dlspeed > 0 { Text("·").foregroundStyle(.tertiary) }
                        Image(systemName: "arrow.up")
                            .foregroundColor(.blue)
                        Text("\(qBittorrent.getFormatedSize(size: torrent.upspeed))/s")
                    }
                    if torrent.dlspeed == 0 && torrent.upspeed == 0 {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(String(format: "%.2f", torrent.ratio))
                    }

                    Text("·")
                        .foregroundStyle(.tertiary)
                    Image(systemName: "person.2")
                    Text("\(torrent.num_seeds)↑ \(torrent.num_leechs)↓")

                    Spacer()

                    if !torrent.category.isEmpty {
                        Text(torrent.category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    private var progressText: String {
        if torrent.progress >= 1.0 {
            return qBittorrent.getFormatedSize(size: torrent.size)
        } else {
            return "\(qBittorrent.getFormatedSize(size: torrent.downloaded)) / \(qBittorrent.getFormatedSize(size: torrent.size))"
        }
    }

    private func formatETA(_ seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let mins = (seconds % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
}
