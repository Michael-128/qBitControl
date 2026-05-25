import SwiftUI

struct TorrentPropertiesView: View {
    let hash: String
    @State private var props: TorrentProperties?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let props = props {
                List {
                    Section(header: Text("General")) {
                        if let comment = props.comment, !comment.isEmpty {
                            CustomLabelView(label: "Comment", lineLimit: 3, value: comment)
                        }
                        if let createdBy = props.created_by, !createdBy.isEmpty {
                            CustomLabelView(label: "Created By", value: createdBy)
                        }
                        if let creationDate = props.creation_date, creationDate > 0 {
                            CustomLabelView(label: "Creation Date", value: formatDate(creationDate))
                        }
                        if let isPrivate = props.isPrivate {
                            CustomLabelView(label: "Private", value: isPrivate ? "Yes" : "No")
                        }
                    }

                    Section(header: Text("Transfer")) {
                        if let totalDownloaded = props.total_downloaded {
                            CustomLabelView(label: "Total Downloaded", value: qBittorrent.getFormatedSize(size: totalDownloaded))
                        }
                        if let totalUploaded = props.total_uploaded {
                            CustomLabelView(label: "Total Uploaded", value: qBittorrent.getFormatedSize(size: totalUploaded))
                        }
                        if let wasted = props.total_wasted, wasted > 0 {
                            CustomLabelView(label: "Wasted", value: qBittorrent.getFormatedSize(size: wasted))
                        }
                        if let ratio = props.share_ratio {
                            CustomLabelView(label: "Share Ratio", value: String(format: "%.3f", ratio))
                        }
                        if let dlAvg = props.dl_speed_avg, dlAvg > 0 {
                            CustomLabelView(label: "Avg Download Speed", value: "\(qBittorrent.getFormatedSize(size: dlAvg))/s")
                        }
                        if let upAvg = props.up_speed_avg, upAvg > 0 {
                            CustomLabelView(label: "Avg Upload Speed", value: "\(qBittorrent.getFormatedSize(size: upAvg))/s")
                        }
                    }

                    Section(header: Text("Time")) {
                        if let elapsed = props.time_elapsed, elapsed > 0 {
                            CustomLabelView(label: "Time Active", value: formatDuration(elapsed))
                        }
                        if let seedingTime = props.seeding_time, seedingTime > 0 {
                            CustomLabelView(label: "Seeding Time", value: formatDuration(seedingTime))
                        }
                        if let addDate = props.addition_date, addDate > 0 {
                            CustomLabelView(label: "Added On", value: formatDate(addDate))
                        }
                        if let compDate = props.completion_date, compDate > 0 {
                            CustomLabelView(label: "Completed On", value: formatDate(compDate))
                        }
                        if let lastSeen = props.last_seen, lastSeen > 0 {
                            CustomLabelView(label: "Last Seen Complete", value: formatDate(lastSeen))
                        }
                    }

                    Section(header: Text("Pieces")) {
                        if let pieceSize = props.piece_size, pieceSize > 0 {
                            CustomLabelView(label: "Piece Size", value: qBittorrent.getFormatedSize(size: pieceSize))
                        }
                        if let have = props.pieces_have, let total = props.pieces_num, total > 0 {
                            CustomLabelView(label: "Pieces", value: "\(have) / \(total)")
                        }
                    }

                    Section(header: Text("Connections")) {
                        if let conn = props.nb_connections, let limit = props.nb_connections_limit {
                            CustomLabelView(label: "Connections", value: "\(conn) / \(limit == -1 ? "∞" : "\(limit)")")
                        }
                        if let seeds = props.seeds, let seedsTotal = props.seeds_total {
                            CustomLabelView(label: "Seeds", value: "\(seeds) (\(seedsTotal) total)")
                        }
                        if let peers = props.peers, let peersTotal = props.peers_total {
                            CustomLabelView(label: "Peers", value: "\(peers) (\(peersTotal) total)")
                        }
                        if let reannounce = props.reannounce, reannounce > 0 {
                            CustomLabelView(label: "Next Announce", value: formatDuration(reannounce))
                        }
                    }
                }
            } else if isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Properties")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadProperties() }
        .refreshable { loadProperties() }
    }

    private func loadProperties() {
        isLoading = true
        qBittorrent.getTorrentProperties(hash: hash) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let p) = result {
                    props = p
                }
            }
        }
    }

    private func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let mins = (seconds % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
}
