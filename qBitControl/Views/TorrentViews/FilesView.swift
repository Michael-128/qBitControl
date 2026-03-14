//
//  TorrentDetailsFilesView.swift
//  qBitControl
//

import SwiftUI

struct FilesView: View {
    @StateObject private var viewModel: FilesViewModel
    
    init(torrentHash: String) {
        self._viewModel = StateObject(wrappedValue: FilesViewModel(torrentHash: torrentHash))
    }
    
    var body: some View {
        VStack {
            if viewModel.rootFileNodes.count > 0 {
                List(viewModel.rootFileNodes, children: \.children/*, selection: $selection*/) {
                    child in
                    HStack {
                        if child.isDir {
                            Image(systemName: "folder.fill")
                                .foregroundColor(viewModel.getPriorityColor(fileNode: child))
                        } else {
                            Image(systemName: "doc.fill")
                                .foregroundColor(viewModel.getPriorityColor(fileNode: child))
                        }
                        Text("\(child.name)")
                        Spacer()
                        Text("\(qBittorrent.getFormatedSize(size: child.getSize()))")
                            .foregroundColor(Color.gray)
                    }.contextMenu() {
                        if child.getPriority() < 1 {
                            Button {
                                let stringArr = child.getIndexes().map { String($0) }
                                let indexes = stringArr.joined(separator: "|")
                                
                                viewModel.setPriority(indexes: indexes, priority: 1, onComplete: {
                                    success in
                                    if success {
                                        for index in child.getIndexes() {
                                            if let childOfChild = child.search(index: index) {
                                                childOfChild.setPriority(priority: 1)
                                                viewModel.refresh()
                                            }
                                        }
                                    }
                                })
                            } label: {
                                Text("Download")
                                Image(systemName: "arrow.down")
                            }
                        } else {
                            Button {
                                let childIndexes = child.getIndexes()
                                let stringArr = childIndexes.map { String($0) }
                                let indexes = stringArr.joined(separator: "|")
                                
                                viewModel.setPriority(indexes: indexes, priority: 0, onComplete: {
                                    success in
                                    if success {
                                        for index in childIndexes {
                                            if let childOfChild = child.search(index: index) {
                                                childOfChild.setPriority(priority: 0)
                                                viewModel.refresh()
                                            }
                                        }
                                    }
                                })
                            } label: {
                                Text("Do not download")
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }.navigationTitle("Files")
            }
            
            
            if !viewModel.isLoaded {
                ProgressView().progressViewStyle(.circular)
                    .navigationTitle("Files")
            }
            
        }
        .searchable(text: $viewModel.searchQuery)
            .onAppear() {
                viewModel.getFiles()
            }.onSubmit(of: .search, viewModel.search)
            .onChange(of: viewModel.searchQuery) {
            _ in
                if viewModel.searchQuery.isEmpty {viewModel.search()}
        }
    }
}

struct TorrentDetailsFilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
