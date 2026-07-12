//
//  TorrentLimitsView.swift
//  qBitControl
//

import SwiftUI

struct TorrentLimitsView: View {
    @Environment(\.dismiss) var dismiss
    
    // UI state variables
    @State private var isUploadLimitEnabled: Bool = false
    @State private var uploadLimitValue: String = ""
    
    @State private var isDownloadLimitEnabled: Bool = false
    @State private var downloadLimitValue: String = ""
    
    @State private var shareRatioOption: SeedingLimitOption = .global
    @State private var shareRatioValue: String = ""
    
    @State private var seedingTimeOption: SeedingLimitOption = .global
    @State private var seedingTimeValue: String = ""
    
    @State private var inactiveSeedingOption: SeedingLimitOption = .global
    @State private var inactiveSeedingValue: String = ""
    
    @State private var shareLimitAction: ShareLimitAction = .global
    
    // Mode properties
    let editTorrent: Torrent?
    let onSave: ((Int64, Int64, Float, Int, Int, ShareLimitAction) -> Void)?
    
    // Bindings for add mode
    let addDlLimit: Binding<String>?
    let addUpLimit: Binding<String>?
    let addRatioLimit: Binding<String>?
    let addSeedingTimeLimit: Binding<String>?
    let addShareLimitAction: Binding<ShareLimitAction>?
    
    // Initializer for Edit Mode
    init(torrent: Torrent, onSave: @escaping (Int64, Int64, Float, Int, Int, ShareLimitAction) -> Void) {
        self.editTorrent = torrent
        self.onSave = onSave
        self.addDlLimit = nil
        self.addUpLimit = nil
        self.addRatioLimit = nil
        self.addSeedingTimeLimit = nil
        self.addShareLimitAction = nil
    }
    
    // Initializer for Add Mode
    init(
        dlLimit: Binding<String>,
        upLimit: Binding<String>,
        ratioLimit: Binding<String>,
        seedingTimeLimit: Binding<String>,
        shareLimitAction: Binding<ShareLimitAction>
    ) {
        self.editTorrent = nil
        self.onSave = nil
        self.addDlLimit = dlLimit
        self.addUpLimit = upLimit
        self.addRatioLimit = ratioLimit
        self.addSeedingTimeLimit = seedingTimeLimit
        self.addShareLimitAction = shareLimitAction
    }
    
    var body: some View {
        Form {
            Section(header: Text("Torrent Speed Limits")) {
                speedSectionRow(title: "Upload Speed", icon: "arrow.up", isOn: $isUploadLimitEnabled, value: $uploadLimitValue)
                speedSectionRow(title: "Download Speed", icon: "arrow.down", isOn: $isDownloadLimitEnabled, value: $downloadLimitValue)
            }
            
            Section(header: Text("Torrent Seeding Limits")) {
                seedingSectionRow(title: "Share Ratio", icon: "percent", selection: $shareRatioOption, value: $shareRatioValue)
                seedingSectionRow(title: "Seeding Time", icon: "clock", selection: $seedingTimeOption, value: $seedingTimeValue, unit: "min")
                
                if editTorrent != nil {
                    seedingSectionRow(title: "Inactive Seeding", icon: "zzz", selection: $inactiveSeedingOption, value: $inactiveSeedingValue, unit: "min")
                }
                
                Picker(selection: $shareLimitAction) {
                    ForEach(ShareLimitAction.allCases) { action in
                        Text(action.displayName).tag(action)
                    }
                } label: {
                    Label("When limits are reached", systemImage: "arrow.right.to.line")
                }
            }
        }
        .navigationTitle("Torrent Limits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if editTorrent != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let up = isUploadLimitEnabled ? (Int64(uploadLimitValue) ?? 0) : -1
                        let dl = isDownloadLimitEnabled ? (Int64(downloadLimitValue) ?? 0) : -1
                        
                        let ratio = shareRatioOption.toRatioLimit(customValue: shareRatioValue)
                        let time = seedingTimeOption.toTimeLimit(customValue: seedingTimeValue)
                        let inactive = inactiveSeedingOption.toTimeLimit(customValue: inactiveSeedingValue)
                        
                        onSave?(dl, up, ratio, time, inactive, shareLimitAction)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let torrent = editTorrent {
                isUploadLimitEnabled = torrent.up_limit > 0
                uploadLimitValue = torrent.up_limit > 0 ? String(torrent.up_limit / 1024) : ""
                
                isDownloadLimitEnabled = torrent.dl_limit > 0
                downloadLimitValue = torrent.dl_limit > 0 ? String(torrent.dl_limit / 1024) : ""
                
                shareRatioOption = SeedingLimitOption.from(ratioLimit: torrent.ratio_limit)
                shareRatioValue = shareRatioOption == .custom ? String(format: "%.2f", torrent.ratio_limit) : ""
                
                seedingTimeOption = SeedingLimitOption.from(timeLimit: torrent.seeding_time_limit)
                seedingTimeValue = seedingTimeOption == .custom ? String(torrent.seeding_time_limit) : ""
                
                inactiveSeedingOption = .global
                inactiveSeedingValue = ""
                
                if let actionRaw = torrent.share_limit_action {
                    shareLimitAction = ShareLimitAction(rawValue: actionRaw) ?? .global
                } else {
                    shareLimitAction = .global
                }
            } else if let addDlLimit = addDlLimit,
                      let addUpLimit = addUpLimit,
                      let addRatioLimit = addRatioLimit,
                      let addSeedingTimeLimit = addSeedingTimeLimit {
                let dl = addDlLimit.wrappedValue
                isDownloadLimitEnabled = !dl.isEmpty && dl != "-1" && dl != "0"
                downloadLimitValue = isDownloadLimitEnabled ? dl : ""
                
                let up = addUpLimit.wrappedValue
                isUploadLimitEnabled = !up.isEmpty && up != "-1" && up != "0"
                uploadLimitValue = isUploadLimitEnabled ? up : ""
                
                let ratioFloat = Float(addRatioLimit.wrappedValue) ?? -2.0
                shareRatioOption = SeedingLimitOption.from(ratioLimit: ratioFloat)
                shareRatioValue = shareRatioOption == .custom ? addRatioLimit.wrappedValue : ""
                
                let timeInt = Int(addSeedingTimeLimit.wrappedValue) ?? -2
                seedingTimeOption = SeedingLimitOption.from(timeLimit: timeInt)
                seedingTimeValue = seedingTimeOption == .custom ? addSeedingTimeLimit.wrappedValue : ""
                
                shareLimitAction = addShareLimitAction?.wrappedValue ?? .global
            }
        }
        .onDisappear {
            if editTorrent == nil {
                addDlLimit?.wrappedValue = isDownloadLimitEnabled ? downloadLimitValue : "-1"
                addUpLimit?.wrappedValue = isUploadLimitEnabled ? uploadLimitValue : "-1"
                
                let ratio = shareRatioOption.toRatioLimit(customValue: shareRatioValue)
                addRatioLimit?.wrappedValue = ratio == -2 ? "-2" : (ratio == -1 ? "-1" : shareRatioValue)
                
                let time = seedingTimeOption.toTimeLimit(customValue: seedingTimeValue)
                addSeedingTimeLimit?.wrappedValue = time == -2 ? "-2" : (time == -1 ? "-1" : seedingTimeValue)
                
                if let action = addShareLimitAction {
                    action.wrappedValue = shareLimitAction
                }
            }
        }
    }
    
    // MARK: - Helper View Builders
    
    @ViewBuilder
    private func speedSectionRow(
        title: String,
        icon: String,
        isOn: Binding<Bool>,
        value: Binding<String>
    ) -> some View {
        Toggle(isOn: isOn.animation(.easeInOut)) {
            Label(title, systemImage: icon)
        }
        
        if isOn.wrappedValue {
            HStack {
                Text("\(title) Rate")
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
                Spacer()
                TextField("Rate", text: value)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                Text("KiB/s")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func seedingSectionRow(
        title: String,
        icon: String,
        selection: Binding<SeedingLimitOption>,
        value: Binding<String>,
        unit: String? = nil
    ) -> some View {
        Picker(selection: selection.animation(.easeInOut)) {
            ForEach(SeedingLimitOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        } label: {
            Label(title, systemImage: icon)
        }
        
        if selection.wrappedValue == .custom {
            HStack {
                Text("\(title) Limit")
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
                Spacer()
                TextField(unit == nil ? "Ratio" : "Time", text: value)
                    .keyboardType(unit == nil ? .decimalPad : .numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                if let unit = unit {
                    Text(unit)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TorrentLimitsView(torrent: Torrent(hash: "preview_mock")) { _, _, _, _, _, _ in }
    }
}
