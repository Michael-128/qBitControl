//

import SwiftUI

struct TorrentListToolbar: ToolbarContent {
    @ObservedObject public var viewModel: TorrentListHelperViewModel
    
    var body: some ToolbarContent {
        if(!viewModel.isSelectionMode) {
            TorrentListDefaultToolbar(viewModel: viewModel)
        } else {
            TorrentListSelectionToolbar(viewModel: viewModel)
        }
    }
}
