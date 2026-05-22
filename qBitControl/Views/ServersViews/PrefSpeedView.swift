import SwiftUI

struct PrefSpeedView: View {
    @ObservedObject var vm: PreferencesViewModel

    var body: some View {
        Form {
            Section(header: Text("Global Rate Limits")) {
                HStack {
                    Text("Download (KB/s)")
                    Spacer()
                    TextField("0 = unlimited", text: $vm.dlLimit)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("Upload (KB/s)")
                    Spacer()
                    TextField("0 = unlimited", text: $vm.upLimit)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            }

            Section {
                HStack {
                    Text("Download (KB/s)")
                    Spacer()
                    TextField("0 = unlimited", text: $vm.altDlLimit)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("Upload (KB/s)")
                    Spacer()
                    TextField("0 = unlimited", text: $vm.altUpLimit)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            } header: {
                Text("Alternative Rate Limits")
            } footer: {
                Text("Applied during scheduled hours or when toggled manually")
            }

            Section(header: Text("Rate Limit Options")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Apply to uTP", isOn: $vm.limitUtpRate)
                    Text("Apply rate limits to uTP (μTorrent Transport Protocol) connections")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Count TCP Overhead", isOn: $vm.limitTcpOverhead)
                    Text("Include protocol overhead (packet headers) in rate limits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Apply to LAN Peers", isOn: $vm.limitLanPeers)
                    Text("Apply rate limits to peers on local network")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Schedule")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Enable Scheduler", isOn: $vm.schedulerEnabled)
                    Text("Automatically switch to alternative speed limits during set hours")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if vm.schedulerEnabled {
                    Picker("Days", selection: $vm.schedulerDays) {
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
                        TextField("HH", text: $vm.scheduleFromHour)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                        Text(":")
                        TextField("MM", text: $vm.scheduleFromMin)
                            .keyboardType(.numberPad)
                            .frame(width: 40)
                    }
                    HStack {
                        Text("To")
                        Spacer()
                        TextField("HH", text: $vm.scheduleToHour)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                        Text(":")
                        TextField("MM", text: $vm.scheduleToMin)
                            .keyboardType(.numberPad)
                            .frame(width: 40)
                    }
                }
            }
        }
        .navigationTitle("Speed")
        .navigationBarTitleDisplayMode(.inline)
    }
}
