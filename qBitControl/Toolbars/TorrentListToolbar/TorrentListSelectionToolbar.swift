//

import SwiftUI

struct TorrentListSelectionToolbar: ToolbarContent {
    @ObservedObject public var viewModel: TorrentListHelperViewModel
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if(viewModel.selectedTorrents.count == viewModel.torrents.count) {
                Button {
                    viewModel.uncheckAllTorrents()
                } label: {
                    Image(systemName: "checklist.unchecked")
                }
            } else {
                Button {
                    viewModel.checkAllTorrents()
                } label: {
                    Image(systemName: "checklist.checked")
                }
            }
        }
        
        if(viewModel.selectedTorrents.count > 0 && SystemHelper.instance.isLiquidGlass) {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.resumeSelectedTorrents()
                } label: {
                    Image(systemName: "play.fill")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.pauseSelectedTorrents()
                } label: {
                    Image(systemName: "pause.fill")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showDeleteSelectedAlert()
                } label: {
                    Image(systemName: "trash.fill").foregroundStyle(Color(.red))
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.quitSelectionMode()
            } label: {
                Image(systemName: "checkmark")
            }
        }
        
        if(viewModel.selectedTorrents.count > 0 && !SystemHelper.instance.isLiquidGlass) {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Button {
                        viewModel.resumeSelectedTorrents()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.pauseSelectedTorrents()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.recheckSelectedTorrents()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.reannounceSelectedTorrents()
                    } label: {
                        Image(systemName: "circle.dashed")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.showDeleteSelectedAlert()
                    } label: {
                        Image(systemName: "trash.fill").foregroundStyle(Color(.red))
                    }
                }
            }
        }
    }
}
