import SwiftUI

struct PrefDownloadsView: View {
    @ObservedObject var vm: PreferencesViewModel

    var body: some View {
        Form {
            Section(header: Text("Save Path")) {
                HStack {
                    Text("Default Save Path")
                    Spacer()
                    TextField("/downloads", text: $vm.savePath)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Automatic Torrent Management", isOn: $vm.autoTmmEnabled)
                    Text("Automatically move torrents to category-specific save paths")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Toggle("Use Subcategories", isOn: $vm.useSubcategories)
            }

            Section(header: Text("Adding Torrents")) {
                Picker("Content Layout", selection: $vm.torrentContentLayout) {
                    Text("Original").tag("Original")
                    Text("Create Subfolder").tag("Subfolder")
                    Text("Don't Create Subfolder").tag("NoSubfolder")
                }
                Toggle("Add in Stopped State", isOn: $vm.addStoppedEnabled)
                Toggle("Add to Top of Queue", isOn: $vm.addToTopOfQueue)
                VStack(alignment: .leading, spacing: 4) {
                    Picker("Stop Condition", selection: $vm.torrentStopCondition) {
                        Text("None").tag("None")
                        Text("Metadata Received").tag("MetadataReceived")
                        Text("Files Checked").tag("FilesChecked")
                    }
                    Text("Automatically stop torrent after condition is met")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Merge Trackers on Duplicate", isOn: $vm.mergeTrackers)
                    Text("When adding a torrent that already exists, merge its trackers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Temp Path")) {
                Toggle("Enable Temp Path", isOn: $vm.tempPathEnabled)
                if vm.tempPathEnabled {
                    HStack {
                        Text("Temp Path")
                        Spacer()
                        TextField("/tmp", text: $vm.tempPath)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            Section(header: Text("File Handling")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Pre-allocate Disk Space", isOn: $vm.preallocateAll)
                    Text("Reserve full file size on disk before downloading")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Append .!qB Extension", isOn: $vm.incompleteFilesExt)
                    Text("Add .!qB to incomplete files to prevent premature access")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Toggle("Exclude File Names", isOn: $vm.excludedFileNamesEnabled)
                if vm.excludedFileNamesEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("*.txt\n*.nfo", text: $vm.excludedFileNames, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.caption.monospaced())
                            .textFieldStyle(.roundedBorder)
                        Text("One pattern per line, supports wildcards")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(header: Text("Export .torrent")) {
                HStack {
                    Text("Copy .torrent to")
                    Spacer()
                    TextField("Path", text: $vm.exportDir)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("On completion, copy to")
                    Spacer()
                    TextField("Path", text: $vm.exportDirFin)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section(header: Text("Autorun")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Run on Torrent Finished", isOn: $vm.autorunEnabled)
                    Text("Execute a script when a torrent finishes downloading")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if vm.autorunEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Command")
                        TextField("/path/to/script.sh \"%N\"", text: $vm.autorunProgram)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption.monospaced())
                        Text("Parameters: %N (name), %F (path), %C (category), %T (tracker)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Run on Torrent Added", isOn: $vm.autorunOnTorrentAddedEnabled)
                    Text("Execute a script when a torrent is added")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if vm.autorunOnTorrentAddedEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Command")
                        TextField("/path/to/script.sh \"%N\"", text: $vm.autorunOnTorrentAddedProgram)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption.monospaced())
                    }
                }
            }
        }
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.inline)
    }
}
