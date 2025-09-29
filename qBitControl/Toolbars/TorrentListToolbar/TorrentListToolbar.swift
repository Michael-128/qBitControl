//

import SwiftUI

struct TorrentListToolbar: ToolbarContent {
    @Binding public var torrents: [Torrent]
    
    @Binding public var category: String
    
    @Binding public var isSelectionMode: Bool
    @Binding public var isFilterView: Bool
    
    @Binding public var selectedTorrents: Set<Torrent>
    
    @ObservedObject public var viewModel: TorrentListHelperViewModel
    
    var body: some ToolbarContent {
        if(!isSelectionMode) {
            TorrentListDefaultToolbar(torrents: $torrents, category: $category, isSelectionMode: $isSelectionMode, isFilterView: $isFilterView)
        } else {
            TorrentListSelectionToolbar(viewModel: viewModel)
        }
    }
}
