import SwiftUI

struct PrefConnectionView: View {
    @ObservedObject var vm: PreferencesViewModel

    var body: some View {
        Form {
            Section(header: Text("Listening Port")) {
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("6881", text: $vm.listenPort)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("UPnP / NAT-PMP", isOn: $vm.upnpEnabled)
                    Text("Automatically configure port forwarding on your router")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Connection Limits")) {
                HStack {
                    Text("Global Max Connections")
                    Spacer()
                    TextField("500", text: $vm.maxConnections)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Per Torrent Max Connections")
                    Spacer()
                    TextField("100", text: $vm.maxConnectionsPerTorrent)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Global Upload Slots")
                    Spacer()
                    TextField("4", text: $vm.maxUploads)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Per Torrent Upload Slots")
                    Spacer()
                    TextField("4", text: $vm.maxUploadsPerTorrent)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            Section(header: Text("IP Filtering")) {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Enable IP Filtering", isOn: $vm.ipFilterEnabled)
                    Text("Block connections from IPs listed in the filter file")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if vm.ipFilterEnabled {
                    HStack {
                        Text("Filter File Path")
                        Spacer()
                        TextField("ipfilter.dat", text: $vm.ipFilterPath)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Apply to Trackers", isOn: $vm.ipFilterTrackers)
                }
            }

            Section(header: Text("Banned IPs")) {
                Text("Manually ban specific IP addresses (one per line)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("192.168.1.1\n10.0.0.1", text: $vm.bannedIPs, axis: .vertical)
                    .lineLimit(3...8)
                    .font(.caption.monospaced())
            }

            Section {
                Picker("Type", selection: $vm.proxyType) {
                    Text("Disabled").tag("None")
                    Text("SOCKS4").tag("SOCKS4")
                    Text("SOCKS5").tag("SOCKS5")
                    Text("HTTP").tag("HTTP")
                }
                if vm.proxyType != "None" {
                    HStack {
                        Text("Host")
                        Spacer()
                        TextField("127.0.0.1", text: $vm.proxyIp)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("1080", text: $vm.proxyPort)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    Toggle("Authentication", isOn: $vm.proxyAuthEnabled)
                    if vm.proxyAuthEnabled {
                        HStack {
                            Text("Username")
                            Spacer()
                            TextField("Username", text: $vm.proxyUsername)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Password")
                            Spacer()
                            SecureField("Password", text: $vm.proxyPassword)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Proxy Peer Connections", isOn: $vm.proxyPeerConnections)
                        Text("Route peer and web seed connections through the proxy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Toggle("Proxy BitTorrent", isOn: $vm.proxyBittorrent)
                    Toggle("Proxy RSS", isOn: $vm.proxyRss)
                    Toggle("Proxy Misc (Search, etc.)", isOn: $vm.proxyMisc)
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Hostname Lookup via Proxy", isOn: $vm.proxyHostnameLookup)
                        Text("Resolve DNS through the proxy server")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Proxy")
            } footer: {
                if vm.proxyType != "None" {
                    Text("Configure which traffic types are routed through the proxy above")
                }
            }
        }
        .navigationTitle("Connection")
        .navigationBarTitleDisplayMode(.inline)
    }
}
