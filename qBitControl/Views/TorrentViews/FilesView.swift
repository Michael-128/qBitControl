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
                List($viewModel.rootFileNodes, children: \.children/*, selection: $selection*/) {
                    $child in
                    FileNodeView(child: $child).contextMenu() {
                        Button {
                            viewModel.setPriority(child: child, priority: .doNotDownload)
                        } label: {
                            Label("Do not download", systemImage: "minus.circle")
                        }.tint(.gray)
                
                        Button {
                            viewModel.setPriority(child: child, priority: .normal)
                        } label: {
                            Label("Normal Priority", systemImage: "1.circle")
                        }.tint(.blue)
                        
                        Button {
                            viewModel.setPriority(child: child, priority: .high)
                        } label: {
                            Label("High Priority", systemImage: "2.circle")
                        }.tint(.orange)
                        
                        Button {
                            viewModel.setPriority(child: child, priority: .max)
                        } label: {
                            Label("Max Priority", systemImage: "3.circle")
                        }.tint(.red)
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
