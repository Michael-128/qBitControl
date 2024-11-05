//
//  TorrentDetailsPeersView.swift
//  qBitControl
//

import SwiftUI

struct PeerRowView: View {
    
    @Binding var peer: Peer
    
    func emojiFlag(regionCode: String) -> String? {
        let code = regionCode.uppercased()

        guard Locale.isoRegionCodes.contains(code) else {
            return nil
        }

        var flagString = ""
        for s in code.unicodeScalars {
            guard let scalar = UnicodeScalar(127397 + s.value) else {
                continue
            }
            flagString.append(String(scalar))
        }
        return flagString
    }
    
    var body: some View {
        NavigationLink {
            PeerDetailsView(peer: $peer)
        } label: {
            VStack {
                HStack {
                    Text("\(emojiFlag(regionCode:peer.country_code) ?? "")")
                    Text("\(peer.ip)")
                    Spacer()
                }
                HStack(spacing: 3) {
                    if peer.client.count > 1 {
                        Text("\(peer.client)")
                        Text("•")
                    }
                    Image(systemName: "arrow.down")
                    Text("\(qBittorrent.getFormatedSize(size: peer.dl_speed))/s")
                    Text("•")
                    Image(systemName: "arrow.up")
                    Text("\(qBittorrent.getFormatedSize(size: peer.up_speed))/s")
                    Spacer()
                }.font(.footnote)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }
    }
}

struct TorrentDetailsPeerRowView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
