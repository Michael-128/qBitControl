//

import SwiftUI

struct TorrentListDefaultToolbar: ToolbarContent {
    @ObservedObject public var viewModel: TorrentListHelperViewModel
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Section {
                    Button {
                        viewModel.enterSelectionMode()
                    } label: {
                        Image(systemName: "checkmark.circle")
                        Text("Select")
                    }
                }
                
                if(viewModel.category != "All") {
                    Section {
                        Button {
                            viewModel.resumeCurrentCategoryTorrents()
                        } label: {
                            Image(systemName: "play")
                                .rotationEffect(.degrees(180))
                            Text(NSLocalizedString("Resume", comment: "") + " " + viewModel.categoryName)
                        }
                        
                        Button {
                            viewModel.pauseCurrentCategoryTorrents()
                        } label: {
                            Image(systemName: "pause")
                                .rotationEffect(.degrees(180))
                            Text(NSLocalizedString("Pause", comment: "") + " " + viewModel.categoryName)
                        }
                    }
                }
                
                Section {
                    Button {
                        viewModel.alertIdentifier = AlertIdentifier(id: .resumeAll)
                    } label: {
                        Image(systemName: "play")
                            .rotationEffect(.degrees(180))
                        Text("Resume All Tasks")
                    }
                    
                    Button {
                        viewModel.alertIdentifier = AlertIdentifier(id: .pauseAll)
                    } label: {
                        Image(systemName: "pause")
                            .rotationEffect(.degrees(180))
                        Text("Pause All Tasks")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.isAlertClearCompleted = true
                    } label: {
                        Image(systemName: "trash")
                            .rotationEffect(.degrees(180))
                        Text("Clear Completed")
                    }
                }
                
                Section {
                    Button {
                        viewModel.sheetIdentifier = SheetIdentifier(id: .showAbout)
                    } label: {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }.alert(item: $viewModel.alertIdentifier) { alert in
                switch(alert.id) {
                case .resumeAll:
                    return Alert(title: Text("Confirm Resume All"), message: Text("Are you sure you want to resume all tasks?"), primaryButton: .default(Text("Resume")) {
                        qBittorrent.resumeAllTorrents()
                    }, secondaryButton: .cancel())
                case .pauseAll:
                    return Alert(title: Text("Confirm Pause All"), message: Text("Are you sure you want to pause all tasks?"), primaryButton: .default(Text("Pause")) {
                        qBittorrent.pauseAllTorrents()
                    }, secondaryButton: .cancel())
                }
            }.alert("Confirm Deletion", isPresented: $viewModel.isAlertClearCompleted, actions: {
                Button("Delete Completed Tasks", role: .destructive) {
                    viewModel.deleteCompletedTorrents()
                }
                Button("Delete Completed Tasks with Files", role: .destructive) {
                    viewModel.deleteCompletedTorrents(isDeleteFiles: true)
                }
            })
            .sheet(item: $viewModel.sheetIdentifier) {
                sheet in
                switch sheet.id {
                case .showAbout:
                    return AboutView()
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.isFilterView.toggle()
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
}
