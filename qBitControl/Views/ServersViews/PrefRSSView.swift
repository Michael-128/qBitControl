import SwiftUI

struct PrefRSSView: View {
    @ObservedObject var vm: PreferencesViewModel

    var body: some View {
        Form {
            Section(header: Text("RSS Reader")) {
                HStack {
                    Text("Refresh Interval (min)")
                    Spacer()
                    TextField("30", text: $vm.rssRefreshInterval)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Max Articles per Feed")
                    Spacer()
                    TextField("100", text: $vm.rssMaxArticlesPerFeed)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Enable RSS Processing", isOn: $vm.rssProcessingEnabled)
                    Text("Process RSS feeds and apply download rules")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("RSS Auto Downloading")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Enable Auto Downloading", isOn: $vm.rssAutoDownloadingEnabled)
                    Text("Automatically download torrents matching RSS rules")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Download REPACK/PROPER", isOn: $vm.rssDownloadRepackProperEpisodes)
                    Text("Re-download episodes when REPACK or PROPER versions appear")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("One regex per line")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("s(\\d+)e(\\d+)\n(\\d+)x(\\d+)", text: $vm.rssSmartEpisodeFilters, axis: .vertical)
                        .lineLimit(3...8)
                        .font(.caption.monospaced())
                        .textFieldStyle(.roundedBorder)
                }
            } header: {
                Text("Smart Episode Filters")
            } footer: {
                Text("Regex patterns to identify episode numbering in torrent names")
            }
        }
        .navigationTitle("RSS")
        .navigationBarTitleDisplayMode(.inline)
    }
}
