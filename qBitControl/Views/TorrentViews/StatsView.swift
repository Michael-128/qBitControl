//

import SwiftUI

struct StatsView: View {
    
    @ObservedObject var qBitDataShared = qBitData.shared
    
    @State private var timer: Timer?
    private var fetchInterval: TimeInterval = 2
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        NavigationLink {
                            LogsView()
                        } label: {
                            Label("Application Logs", systemImage: "doc.text")
                        }
                        NavigationLink {
                            PeerLogsView()
                        } label: {
                            Label("Peer Logs", systemImage: "person.2")
                        }
                    }

                    Section(header: Text("Download")) {
                        CustomLabelView(label: "Session Download", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.dl_info_data ?? 0))")
                        CustomLabelView(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.dl_info_speed ?? 0))/s")
                        StatsChartView(transferData: $qBitDataShared.dlTransferData, color: .green)
                    }
                    
                    Section(header: Text("Upload")) {
                        CustomLabelView(label: "Session Upload", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.up_info_data ?? 0))")
                        CustomLabelView(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.up_info_speed ?? 0))/s")
                        StatsChartView(transferData: $qBitDataShared.upTransferData)
                    }
                    
                    Section(header: Text("Disk")) {
                        CustomLabelView(label: "Free Space", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.free_space_on_disk ?? 0))")
                    }
                    
                    Section(header: Text("All-Time")) {
                        CustomLabelView(label: "Upload", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.alltime_ul ?? 0))")
                        CustomLabelView(label: "Download", value: "\(qBittorrent.getFormatedSize(size: qBitDataShared.serverState?.alltime_dl ?? 0))")
                        CustomLabelView(label: "Ratio", value: "\(qBitDataShared.serverState?.global_ratio ?? "0.00")")
                    }
                }
            }.navigationTitle("Statistics")
        }
    }
}

struct LogsView: View {
    @State private var logs: [LogEntry] = []
    @State private var isLoading = true
    @State private var showNormal = true
    @State private var showInfo = true
    @State private var showWarning = true
    @State private var showCritical = true

    var body: some View {
        List {
            Section {
                Toggle("Normal", isOn: $showNormal)
                Toggle("Info", isOn: $showInfo)
                Toggle("Warning", isOn: $showWarning)
                Toggle("Critical", isOn: $showCritical)
            }

            Section(header: Text("\(logs.count) entries")) {
                ForEach(logs) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.logLevel)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(entry.logColor)
                            Spacer()
                            Text(entry.formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(entry.message)
                            .font(.caption)
                            .lineLimit(5)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Logs")
        .overlay {
            if isLoading { ProgressView() }
        }
        .refreshable { fetchLogs() }
        .onAppear { fetchLogs() }
        .onChange(of: showNormal) { _ in fetchLogs() }
        .onChange(of: showInfo) { _ in fetchLogs() }
        .onChange(of: showWarning) { _ in fetchLogs() }
        .onChange(of: showCritical) { _ in fetchLogs() }
    }

    private func fetchLogs() {
        isLoading = true
        Task {
            let result = await qBittorrent.getLogs(
                normal: showNormal, info: showInfo,
                warning: showWarning, critical: showCritical
            )
            await MainActor.run {
                logs = result.reversed()
                isLoading = false
            }
        }
    }
}

struct PeerLogsView: View {
    @State private var logs: [PeerLogEntry] = []
    @State private var isLoading = true

    var body: some View {
        List {
            Section(header: Text("\(logs.count) entries")) {
                ForEach(logs) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: entry.blocked ? "xmark.shield.fill" : "checkmark.shield")
                                .foregroundColor(entry.blocked ? .red : .green)
                                .font(.caption)
                            Text(entry.ip)
                                .font(.subheadline.monospaced())
                            Spacer()
                            Text(entry.formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        if let reason = entry.reason, !reason.isEmpty {
                            Text(reason)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                    .contextMenu {
                        Button {
                            qBittorrent.banPeers(peers: ["\(entry.ip):0"])
                        } label: {
                            Label("Ban IP", systemImage: "hand.raised")
                        }
                        Button {
                            UIPasteboard.general.string = entry.ip
                        } label: {
                            Label("Copy IP", systemImage: "doc.on.doc")
                        }
                    }
                }
            }
        }
        .navigationTitle("Peer Logs")
        .overlay { if isLoading { ProgressView() } }
        .refreshable { await fetchPeerLogs() }
        .task { await fetchPeerLogs() }
    }

    private func fetchPeerLogs() async {
        isLoading = true
        let result = await qBittorrent.getPeerLog()
        await MainActor.run {
            logs = result.reversed()
            isLoading = false
        }
    }
}
