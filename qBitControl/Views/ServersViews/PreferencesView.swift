import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showSaveAlert = false
    @State private var saveSuccess = false

    var body: some View {
        NavigationView {
            Form {
                downloadsSection
                speedLimitsSection
                queueingSection
                slowTorrentsSection
                schedulerSection
                ratioSection
                seedingTimeSection
                bittorrentSection
                connectionLimitsSection
                networkSection
                dhtSection
                ipFilterSection
                rssSection
            }
            .navigationTitle("Server Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save { success in
                            saveSuccess = success
                            showSaveAlert = true
                            if success {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Save Preferences", isPresented: $showSaveAlert) {
                if saveSuccess {
                    Button("OK", role: .cancel) {}
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                if saveSuccess {
                    Text("Preferences saved successfully.")
                } else {
                    Text(viewModel.saveError ?? "Failed to save preferences.")
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }

    // MARK: - Downloads

    private var downloadsSection: some View {
        Section(header: Text("Downloads")) {
            HStack {
                Text("Default Save Path")
                Spacer()
                TextField("/downloads", text: $viewModel.savePath)
                    .multilineTextAlignment(.trailing)
            }
            Toggle("Automatic Torrent Management", isOn: $viewModel.autoTmmEnabled)
            Toggle("Enable Temp Path", isOn: $viewModel.tempPathEnabled)
            if viewModel.tempPathEnabled {
                HStack {
                    Text("Temp Path")
                    Spacer()
                    TextField("/tmp", text: $viewModel.tempPath)
                        .multilineTextAlignment(.trailing)
                }
            }
            Toggle("Start Torrents Paused", isOn: $viewModel.startPausedEnabled)
            Toggle("Pre-allocate Disk Space", isOn: $viewModel.preallocateAll)
            Toggle("Append .!qB Extension", isOn: $viewModel.incompleteFilesExt)
        }
    }

    // MARK: - Speed Limits

    private var speedLimitsSection: some View {
        Section(header: Text("Speed Limits")) {
            HStack {
                Text("Download Limit (KB/s)")
                Spacer()
                TextField("0 = unlimited", text: $viewModel.dlLimit)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            HStack {
                Text("Upload Limit (KB/s)")
                Spacer()
                TextField("0 = unlimited", text: $viewModel.upLimit)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            HStack {
                Text("Alt Download Limit (KB/s)")
                Spacer()
                TextField("0 = unlimited", text: $viewModel.altDlLimit)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            HStack {
                Text("Alt Upload Limit (KB/s)")
                Spacer()
                TextField("0 = unlimited", text: $viewModel.altUpLimit)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
        }
    }

    // MARK: - Queueing

    private var queueingSection: some View {
        Section(header: Text("Queueing")) {
            Toggle("Enable Queueing", isOn: $viewModel.queueingEnabled)
            if viewModel.queueingEnabled {
                HStack {
                    Text("Max Active Downloads")
                    Spacer()
                    TextField("1", text: $viewModel.maxActiveDownloads)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Max Active Torrents")
                    Spacer()
                    TextField("3", text: $viewModel.maxActiveTorrents)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Max Active Uploads")
                    Spacer()
                    TextField("1", text: $viewModel.maxActiveUploads)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }

    // MARK: - Slow Torrents

    private var slowTorrentsSection: some View {
        Section(header: Text("Slow Torrents")) {
            Toggle("Don't Count Slow Torrents", isOn: $viewModel.dontCountSlowTorrents)
            if viewModel.dontCountSlowTorrents {
                HStack {
                    Text("Download Rate Threshold (KiB/s)")
                    Spacer()
                    TextField("2", text: $viewModel.slowTorrentDlRateThreshold)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Upload Rate Threshold (KiB/s)")
                    Spacer()
                    TextField("2", text: $viewModel.slowTorrentUlRateThreshold)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Inactive Timer (seconds)")
                    Spacer()
                    TextField("60", text: $viewModel.slowTorrentInactiveTimer)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }

    // MARK: - Scheduler

    private var schedulerSection: some View {
        Section(header: Text("Speed Scheduler")) {
            Toggle("Enable Scheduler", isOn: $viewModel.schedulerEnabled)
            if viewModel.schedulerEnabled {
                Picker("Days", selection: $viewModel.schedulerDays) {
                    Text("Every Day").tag(0)
                    Text("Monday").tag(1)
                    Text("Tuesday").tag(2)
                    Text("Wednesday").tag(3)
                    Text("Thursday").tag(4)
                    Text("Friday").tag(5)
                    Text("Saturday").tag(6)
                    Text("Sunday").tag(7)
                    Text("Weekdays").tag(8)
                    Text("Weekends").tag(9)
                }
                HStack {
                    Text("From")
                    Spacer()
                    TextField("HH", text: $viewModel.scheduleFromHour)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                    Text(":")
                    TextField("MM", text: $viewModel.scheduleFromMin)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                }
                HStack {
                    Text("To")
                    Spacer()
                    TextField("HH", text: $viewModel.scheduleToHour)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                    Text(":")
                    TextField("MM", text: $viewModel.scheduleToMin)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                }
            }
        }
    }

    // MARK: - Ratio

    private var ratioSection: some View {
        Section(header: Text("Ratio")) {
            Toggle("Set Max Ratio", isOn: $viewModel.maxRatioEnabled)
            if viewModel.maxRatioEnabled {
                HStack {
                    Text("Max Ratio")
                    Spacer()
                    TextField("1.00", text: $viewModel.maxRatio)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }

    // MARK: - Seeding Time

    private var seedingTimeSection: some View {
        Section(header: Text("Seeding Time")) {
            Toggle("Set Max Seeding Time", isOn: $viewModel.maxSeedingTimeEnabled)
            if viewModel.maxSeedingTimeEnabled {
                HStack {
                    Text("Max Seeding Time (min)")
                    Spacer()
                    TextField("1440", text: $viewModel.maxSeedingTime)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }

    // MARK: - BitTorrent

    private var bittorrentSection: some View {
        Section(header: Text("BitTorrent")) {
            Picker("Protocol", selection: $viewModel.bittorrentProtocol) {
                Text("TCP and uTP").tag(0)
                Text("TCP").tag(1)
                Text("uTP").tag(2)
            }
            Picker("Encryption", selection: $viewModel.encryption) {
                Text("Prefer Encryption").tag(0)
                Text("Force Encryption").tag(1)
                Text("Disable Encryption").tag(2)
            }
            Toggle("Anonymous Mode", isOn: $viewModel.anonymousMode)
        }
    }

    // MARK: - Connection Limits

    private var connectionLimitsSection: some View {
        Section(header: Text("Connection Limits")) {
            HStack {
                Text("Max Upload Slots")
                Spacer()
                TextField("4", text: $viewModel.maxUploads)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Max Upload Slots / Torrent")
                Spacer()
                TextField("4", text: $viewModel.maxUploadsPerTorrent)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    // MARK: - Network

    private var networkSection: some View {
        Section(header: Text("Network")) {
            HStack {
                Text("Listen Port")
                Spacer()
                TextField("6881", text: $viewModel.listenPort)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            Toggle("UPnP / NAT-PMP", isOn: $viewModel.upnpEnabled)
            HStack {
                Text("Max Connections")
                Spacer()
                TextField("500", text: $viewModel.maxConnections)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Max Connections / Torrent")
                Spacer()
                TextField("50", text: $viewModel.maxConnectionsPerTorrent)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    // MARK: - DHT / PEX / LSD

    private var dhtSection: some View {
        Section(header: Text("Peer Discovery")) {
            Toggle("DHT", isOn: $viewModel.dhtEnabled)
            Toggle("PEX", isOn: $viewModel.pexEnabled)
            Toggle("LSD", isOn: $viewModel.lsdEnabled)
        }
    }

    // MARK: - IP Filter

    private var ipFilterSection: some View {
        Section(header: Text("IP Filter")) {
            Toggle("Enable IP Filtering", isOn: $viewModel.ipFilterEnabled)
            if viewModel.ipFilterEnabled {
                HStack {
                    Text("Filter Path")
                    Spacer()
                    TextField("ipfilter.dat", text: $viewModel.ipFilterPath)
                        .multilineTextAlignment(.trailing)
                }
                Toggle("Apply to Trackers", isOn: $viewModel.ipFilterTrackers)
            }
            VStack(alignment: .leading) {
                Text("Banned IPs")
                TextField("One IP per line", text: $viewModel.bannedIPs, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
        }
    }

    // MARK: - RSS

    private var rssSection: some View {
        Section(header: Text("RSS")) {
            HStack {
                Text("Refresh Interval (min)")
                Spacer()
                TextField("30", text: $viewModel.rssRefreshInterval)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Max Articles / Feed")
                Spacer()
                TextField("100", text: $viewModel.rssMaxArticlesPerFeed)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            Toggle("Auto Download RSS Articles", isOn: $viewModel.rssAutoDownloadingEnabled)
        }
    }
}
