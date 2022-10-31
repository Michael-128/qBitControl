//
//  TorrentAddMagnetView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 27/10/2022.
//

import SwiftUI

struct TorrentAddMagnetView: View {
    
    @State private var urls = ""
    @Binding var isPresented: Bool
    /**
     root_folder optional     string     Create the root folder. Possible values are true, false, unset (default)
     rename optional     string     Rename torrent
        skipped for now
     */
    
    var body: some View {
        Group {
            Section(header: Text("Magnet")) {
                TextEditor(text: $urls)
                    .frame(minHeight: CGFloat(200), maxHeight: CGFloat(200))
            }
            
            TorrentAddOptionsView(torrent: $urls, torrentData: .constant([:]), isFile: .constant(false), isPresented: $isPresented)
        }
        .navigationTitle("Magnet")
    }
}

/*struct TorrentAddMagnetView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentAddMagnetView()
    }
}*/
