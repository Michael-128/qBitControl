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
    private var isSeeding: Bool { torrent.progress >= 1.0 }
    private var trackerDomain: String {
        guard let url = URL(string: torrent.tracker), let host = url.host else { return "" }
        return host.replacingOccurrences(of: "tracker.", with: "").replacingOccurrences(of: "www.", with: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: Name + state icon
            HStack(alignment: .top) {
                Text(torrent.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                Spacer()
                Image(systemName: stateIcon)
                    .font(.caption)
                    .foregroundColor(stateColor)
            }

            // Row 2: Progress bar + percentage
            HStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(.systemGray5))
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(stateColor)
                            .frame(width: geo.size.width * CGFloat(min(torrent.progress, 1.0)))
                    }
                }
                .frame(height: 3)

                Text("\(Int(torrent.progress * 100))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(stateColor)
                    .frame(width: 32, alignment: .trailing)
            }

            // Row 3: State + size + ETA
            HStack(spacing: 4) {
                Text(stateText)
                    .foregroundColor(stateColor)
                    .fontWeight(.medium)
                Text("·").foregroundStyle(.tertiary)

                if torrent.progress < 1.0 {
                    Text("\(qBittorrent.getFormatedSize(size: torrent.downloaded))/\(qBittorrent.getFormatedSize(size: torrent.size))")
                    if torrent.eta > 0 && torrent.eta < 8640000 {
                        Text("·").foregroundStyle(.tertiary)
                        Image(systemName: "clock")
                        Text(formatETA(torrent.eta))
                    }
                } else {
                    Text(qBittorrent.getFormatedSize(size: torrent.size))
                    Text("·").foregroundStyle(.tertiary)
                    Text("↑\(qBittorrent.getFormatedSize(size: torrent.uploaded))")
                    Text("·").foregroundStyle(.tertiary)
                    Text("R:\(String(format: "%.2f", torrent.ratio))")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)

            // Row 4: Speed chips + peers + tags
            HStack(spacing: 5) {
                if torrent.dlspeed > 0 {
                    SpeedChip(icon: "arrow.down", speed: torrent.dlspeed, color: .green)
                }
                if torrent.upspeed > 0 {
                    SpeedChip(icon: "arrow.up", speed: torrent.upspeed, color: .blue)
                }

                HStack(spacing: 2) {
                    Image(systemName: "person.2")
                    Text("\(torrent.num_seeds)/\(torrent.num_leechs)")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)

                if isSeeding, let seedingTime = torrent.seeding_time, seedingTime > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "timer")
                        Text(formatDuration(seedingTime))
                    }
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                }

                if !isSeeding && torrent.availability > 0 && torrent.availability < 1.0 {
                    HStack(spacing: 2) {
                        Image(systemName: "chart.pie")
                        Text(String(format: "%.0f%%", torrent.availability * 100))
                    }
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }

                Spacer()

                if !trackerDomain.isEmpty {
                    TagChip(text: trackerDomain, color: .purple)
                }
                if !torrent.category.isEmpty {
                    TagChip(text: torrent.category, color: .indigo)
                }
            }
        }
        .padding(.vertical, 3)
    }

    private func formatETA(_ seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let mins = (seconds % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }

    private func formatDuration(_ seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        if days > 0 { return "\(days)d" }
        if hours > 0 { return "\(hours)h" }
        return "\(seconds / 60)m"
    }
}

struct SpeedChip: View {
    let icon: String
    let speed: Int64
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text("\(qBittorrent.getFormatedSize(size: speed))/s")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct TagChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundColor(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .lineLimit(1)
    }
}
