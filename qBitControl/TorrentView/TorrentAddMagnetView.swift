//
//  TorrentAddMagnetView.swift
//  qBitControl
//

import SwiftUI

struct TorrentAddMagnetView: View {
    
    @State public var urls = ""
    
    @Binding var openedMagnetURL: String?
    @Binding var isPresented: Bool
    /**
     root_folder optional     string     Create the root folder. Possible values are true, false, unset (default)
     rename optional     string     Rename torrent
        skipped for now
     */
    
    var body: some View {
        Group {
            Section(header: Text("URL")) {
                TextEditor(text: $urls)
                    .frame(minHeight: CGFloat(200), maxHeight: CGFloat(200))
            }.onAppear() {
                if let magnetURL = openedMagnetURL {
                    urls = magnetURL
                    openedMagnetURL = nil
                }
            }
            
            TorrentAddOptionsView(torrent: $urls, torrentData: .constant([:]), isFile: .constant(false), isPresented: $isPresented)
        }
        .navigationTitle("URL")
    }
}

/*struct TorrentAddMagnetView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentAddMagnetView()
    }
}*/
