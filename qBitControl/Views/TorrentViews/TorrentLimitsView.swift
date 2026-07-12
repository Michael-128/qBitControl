//
//  TorrentLimitsView.swift
//  qBitControl
//

import SwiftUI

struct TorrentLimitsView: View {
    @Environment(\.dismiss) var dismiss
    
    // UI state variables for the preview/layout demo
    @State private var isUploadLimitEnabled: Bool = false
    @State private var uploadLimitValue: String = "500"
    
    @State private var isDownloadLimitEnabled: Bool = true
    @State private var downloadLimitValue: String = "1024"
    
    @State private var shareRatioOption: String = "Custom"
    @State private var shareRatioValue: String = "2.00"
    
    @State private var seedingTimeOption: String = "Global"
    @State private var seedingTimeValue: String = "120"
    
    @State private var inactiveSeedingOption: String = "Unlimited"
    @State private var inactiveSeedingValue: String = "60"
    
    var body: some View {
        Form {
            Section(header: Text("Torrent Speed Limits")) {
                Toggle(isOn: $isUploadLimitEnabled.animation(.easeInOut)) {
                    Label("Upload Limit", systemImage: "arrow.up")
                }
                
                if isUploadLimitEnabled {
                    HStack {
                        Text("Upload Rate")
                        Spacer()
                        TextField("Rate", text: $uploadLimitValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("KiB/s")
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $isDownloadLimitEnabled.animation(.easeInOut)) {
                    Label("Download Limit", systemImage: "arrow.down")
                }
                
                if isDownloadLimitEnabled {
                    HStack {
                        Text("Download Rate")
                        Spacer()
                        TextField("Rate", text: $downloadLimitValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("KiB/s")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Torrent Seeding Limits")) {
                Picker(selection: $shareRatioOption.animation(.easeInOut)) {
                    Text("Global").tag("Global")
                    Text("Unlimited").tag("Unlimited")
                    Text("Custom").tag("Custom")
                } label: {
                    Label("Share Ratio", systemImage: "percent")
                }
                
                if shareRatioOption == "Custom" {
                    HStack {
                        Text("Ratio Limit")
                        Spacer()
                        TextField("Ratio", text: $shareRatioValue)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Picker(selection: $seedingTimeOption.animation(.easeInOut)) {
                    Text("Global").tag("Global")
                    Text("Unlimited").tag("Unlimited")
                    Text("Custom").tag("Custom")
                } label: {
                    Label("Seeding Time", systemImage: "clock")
                }
                
                if seedingTimeOption == "Custom" {
                    HStack {
                        Text("Seeding Time Limit")
                        Spacer()
                        TextField("Time", text: $seedingTimeValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
                
                Picker(selection: $inactiveSeedingOption.animation(.easeInOut)) {
                    Text("Global").tag("Global")
                    Text("Unlimited").tag("Unlimited")
                    Text("Custom").tag("Custom")
                } label: {
                    Label("Inactive Seeding", systemImage: "zzz")
                }
                
                if inactiveSeedingOption == "Custom" {
                    HStack {
                        Text("Inactive Seeding Limit")
                        Spacer()
                        TextField("Time", text: $inactiveSeedingValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Torrent Limits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TorrentLimitsView()
    }
}
