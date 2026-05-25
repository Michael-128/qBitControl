import SwiftUI

struct PrefBitTorrentView: View {
    @ObservedObject var vm: PreferencesViewModel

    var body: some View {
        Form {
            Section(header: Text("Protocol")) {
                Picker("Protocol", selection: $vm.bittorrentProtocol) {
                    Text("TCP and uTP").tag(0)
                    Text("TCP").tag(1)
                    Text("uTP").tag(2)
                }
                Picker("Encryption", selection: $vm.encryption) {
                    Text("Prefer Encryption").tag(0)
                    Text("Force Encryption").tag(1)
                    Text("Disable Encryption").tag(2)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("DHT", isOn: $vm.dhtEnabled)
                    Text("Distributed Hash Table — find peers without trackers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("PEX", isOn: $vm.pexEnabled)
                    Text("Peer Exchange — discover peers from other peers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("LSD", isOn: $vm.lsdEnabled)
                    Text("Local Service Discovery — find peers on local network")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Anonymous Mode", isOn: $vm.anonymousMode)
                    Text("Hide client identity from trackers and peers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Privacy")
            } footer: {
                Text("Disabling DHT/PEX/LSD is recommended for private trackers")
            }

            Section(header: Text("Torrent Queueing")) {
                Toggle("Enable Queueing", isOn: $vm.queueingEnabled)
                if vm.queueingEnabled {
                    HStack {
                        Text("Max Active Downloads")
                        Spacer()
                        TextField("3", text: $vm.maxActiveDownloads)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Max Active Uploads")
                        Spacer()
                        TextField("3", text: $vm.maxActiveUploads)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Max Active Torrents")
                        Spacer()
                        TextField("5", text: $vm.maxActiveTorrents)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Max Checking Torrents")
                        Spacer()
                        TextField("1", text: $vm.maxActiveCheckingTorrents)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Don't Count Slow Torrents", isOn: $vm.dontCountSlowTorrents)
                        Text("Stalled torrents (no activity) won't count towards active limits")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if vm.dontCountSlowTorrents {
                        HStack {
                            Text("DL Threshold (KiB/s)")
                            Spacer()
                            TextField("2", text: $vm.slowTorrentDlRateThreshold)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        HStack {
                            Text("UL Threshold (KiB/s)")
                            Spacer()
                            TextField("2", text: $vm.slowTorrentUlRateThreshold)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        HStack {
                            Text("Inactive Timer (s)")
                            Spacer()
                            TextField("60", text: $vm.slowTorrentInactiveTimer)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                }
            }

            Section(header: Text("Seeding Limits")) {
                Toggle("Limit Ratio", isOn: $vm.maxRatioEnabled)
                if vm.maxRatioEnabled {
                    HStack {
                        Text("Max Ratio")
                        Spacer()
                        TextField("1.00", text: $vm.maxRatio)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    Picker("When Reached", selection: $vm.maxRatioAct) {
                        Text("Pause Torrent").tag(0)
                        Text("Remove Torrent").tag(1)
                    }
                }
                Toggle("Limit Seeding Time", isOn: $vm.maxSeedingTimeEnabled)
                if vm.maxSeedingTimeEnabled {
                    HStack {
                        Text("Max Time (minutes)")
                        Spacer()
                        TextField("1440", text: $vm.maxSeedingTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                Toggle("Limit Inactive Seeding Time", isOn: $vm.maxInactiveSeedingTimeEnabled)
                if vm.maxInactiveSeedingTimeEnabled {
                    HStack {
                        Text("Max Inactive Time (min)")
                        Spacer()
                        TextField("1440", text: $vm.maxInactiveSeedingTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }

            Section {
                Toggle("Enable", isOn: $vm.addTrackersEnabled)
                if vm.addTrackersEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("One tracker URL per line")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("https://tracker.example.com/announce", text: $vm.addTrackers, axis: .vertical)
                            .lineLimit(4...10)
                            .font(.caption.monospaced())
                            .textFieldStyle(.roundedBorder)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Fetch from URL", isOn: $vm.addTrackersFromUrlEnabled)
                    Text("Automatically fetch tracker list from a remote URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if vm.addTrackersFromUrlEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("https://example.com/trackers.txt", text: $vm.addTrackersUrlList)
                            .font(.caption.monospaced())
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        Button {
                            vm.fetchAndMergeTrackersFromUrl()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("Fetch Now")
                            }
                        }
                        .disabled(vm.addTrackersUrlList.isEmpty)
                    }
                }
            } header: {
                Text("Automatically Add Trackers")
            } footer: {
                Text("These trackers will be added to all new torrents")
            }

            Section(header: Text("Tracker Options")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Reannounce on IP Change", isOn: $vm.reannounceWhenAddressChanged)
                    Text("Notify trackers when your IP address changes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Validate HTTPS Certificates", isOn: $vm.validateHttpsTrackerCertificate)
                    Text("Reject HTTPS trackers with invalid certificates")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("BitTorrent")
        .navigationBarTitleDisplayMode(.inline)
    }
}
