//

import SwiftUI

struct TorrentListToolbar: ToolbarContent {
    @Binding public var torrents: [Torrent]
    
    @Binding public var category: String
    
    @Binding public var isSelectionMode: Bool
    @Binding public var isLoggedIn: Bool
    @Binding public var isFilterView: Bool
    
    @Binding public var selectedTorrents: Set<Torrent>
    
    var body: some ToolbarContent {
        if(!isSelectionMode) {
            TorrentListDefaultToolbar(torrents: $torrents, category: $category, isSelectionMode: $isSelectionMode, isLoggedIn: $isLoggedIn, isFilterView: $isFilterView)
        } else {
            TorrentListSelectionToolbar(torrents: $torrents, isSelectionMode: $isSelectionMode, selectedTorrents: $selectedTorrents)
        }
    }
}

/*             if(isSelectionMode && selectedTorrents.count > 0) {
 ToolbarItemGroup(placement: .bottomBar) {
     HStack {
         Group {
             Button {
                 let selectedHashes = selectedTorrents.compactMap {
                     torrent in
                     torrent.hash
                 }
                 
                 qBittorrent.resumeTorrents(hashes: selectedHashes)
                 isSelectionMode = false
                 selectedTorrents.removeAll()
             } label: {
                 Image(systemName: "play.circle")
             }
             
             Button {
                 let selectedHashes = selectedTorrents.compactMap {
                     torrent in
                     torrent.hash
                 }
                 
                 qBittorrent.pauseTorrents(hashes: selectedHashes)
                 isSelectionMode = false
                 selectedTorrents.removeAll()
             } label: {
                 Image(systemName: "pause.circle")
             }
             
             Button {
                 let selectedHashes = selectedTorrents.compactMap {
                     torrent in
                     torrent.hash
                 }
                 
                 qBittorrent.recheckTorrents(hashes: selectedHashes)
                 isSelectionMode = false
                 selectedTorrents.removeAll()
             } label: {
                 Image(systemName: "magnifyingglass.circle")
             }
             
             Button {
                 let selectedHashes = selectedTorrents.compactMap {
                     torrent in
                     torrent.hash
                 }
                 
                 qBittorrent.reannounceTorrents(hashes: selectedHashes)
                 isSelectionMode = false
                 selectedTorrents.removeAll()
             } label: {
                 Image(systemName: "circle.dotted.circle")
             }
             
             Button {
                 // to be implemented
             } label: {
                 Image(systemName: "trash.circle").foregroundStyle(Color(.red))
             }
         }
     }.scaleEffect(1.20)
 }
}

if(!isSelectionMode) {
 ToolbarItem(placement: .navigationBarLeading) {
     leftToolbarMenu()
 }
 ToolbarItem(placement: .navigationBarTrailing) {
     Button {
         isFilterView.toggle()
     } label: {
         Image(systemName: "line.3.horizontal.decrease.circle")
     }
     
 }
} else {
 ToolbarItem(placement: .navigationBarLeading) {
     if(selectedTorrents.count == torrents.count) {
         Button {
             selectedTorrents.removeAll()
         } label: {
             Text("Deselect All")
         }
     } else {
         Button {
             torrents.forEach {
                 torrent in
                 selectedTorrents.insert(torrent)
             }
         } label: {
             Text("Select All")
         }
     }
 }
 
 ToolbarItem(placement: .navigationBarTrailing) {
     Button {
         isSelectionMode = false
         
         // do something
         
         selectedTorrents.removeAll()
     } label: {
         Text("Done")
             .fontWeight(.bold)
     }
 }
}*/

/*func leftToolbarMenu() -> some View {
*/
