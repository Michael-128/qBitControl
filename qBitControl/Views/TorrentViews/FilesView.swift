//
//  TorrentDetailsFilesView.swift
//  qBitControl
//

import SwiftUI

@MainActor
struct FilesView: View {
    @Binding var torrentHash: String
    private let client: TorrentClientProtocol
    var formatter: TorrentFormatting = TorrentFormatter()

    @State private var sortedFiles: [Dictionary<String, [FileNode]>.Element] = []
    @State private var rootFileNodes: [FileNode] = []
    @StateObject private var rootFileNode = FileNode(name: "")
    
    @State private var isLoaded = false
    @State private var searchQuery = ""
    
    // Max dirs loaded at a time
    let step = 50
    @State private var curStep = 0
    
    init(torrentHash: Binding<String>, client: TorrentClientProtocol) {
        self._torrentHash = torrentHash
        self.client = client
    }
    
    func getNextStep(currentStep: Int) -> Int {
        let nextStep = currentStep + step
        self.curStep = nextStep + 1
        return nextStep
    }
    
    func getFiles() {
        isLoaded = false
        
        Task {
            do {
                let files = try await client.getFiles(hash: torrentHash)
                var filesWithCommonPaths: [String: [FileNode]] = ["":[]]
                
                for file in files {
                    let fileComponents = file.name.components(separatedBy: "/")
                    let actualFilename = fileComponents.last ?? ""
                    let path = fileComponents.dropLast().joined(separator: "/")
                    filesWithCommonPaths[path, default: []].append(
                        FileNode(
                            index: file.index,
                            name: actualFilename,
                            size: file.size,
                            progress: file.progress,
                            priority: file.priority,
                            is_seed: file.is_seed,
                            availability: file.availability
                        )
                    )
                }
                
                self.sortedFiles = filesWithCommonPaths.sorted(by: { $0.0 < $1.0 })
                getNextFileNodes(startIndex: curStep, endIndex: getNextStep(currentStep: curStep))
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "get_files_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func getNextFileNodes(startIndex: Int, endIndex: Int) {
        var newEndIndex = endIndex
        if endIndex > sortedFiles.count - 1 {
            newEndIndex = sortedFiles.count - 1
        }
        if startIndex > newEndIndex {
            return
        }
        
        let rootFileNode = self.rootFileNode
        
        for index in startIndex...newEndIndex {
            let path = sortedFiles[index].key
            let files = sortedFiles[index].value
            
            let pathComponents = path.components(separatedBy: "/")
            
            var lastFileNode = rootFileNode
            
            for pathComponent in pathComponents {
                if let existingFileNode = lastFileNode.shallowSearch(name: pathComponent) {
                    lastFileNode = existingFileNode
                } else {
                    let newFileNode = FileNode(name: pathComponent)
                    lastFileNode.add(child: newFileNode)
                    lastFileNode = newFileNode
                }
            }
            
            lastFileNode.addMultiple(children: files)
        }
        
        self.rootFileNodes = self.rootFileNode.children ?? []
        
        isLoaded = true
        
        getNextFileNodes(startIndex: curStep, endIndex: getNextStep(currentStep: curStep))
    }
    
    func getPriorityColor(fileNode: FileNode) -> Color {
        return fileNode.getPriority() > 0 ? Color.primary : Color.gray
    }
    
    func setPriority(indexes: String, priority: Int, onComplete: @escaping @MainActor (Bool) -> Void) {
        Task {
            do {
                try await client.setFilePriority(hash: torrentHash, ids: indexes, priority: priority)
                onComplete(true)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "set_file_priority_failed", errorDescription: error.localizedDescription))
                onComplete(false)
            }
        }
    }
    
    func refresh() {
        rootFileNode.objectWillChange.send()
        self.rootFileNodes = rootFileNode.children ?? []
    }
    
    func search() {
        if searchQuery.isEmpty {
            self.rootFileNodes = rootFileNode.children ?? []
        } else {
            self.rootFileNodes = rootFileNode.findAll(query: searchQuery)
        }
    }
    
    var body: some View {
        VStack {
            if rootFileNodes.count > 0 {
                List(rootFileNodes, children: \.children) {
                    child in
                    HStack {
                        if child.isDir {
                            Image(systemName: "folder.fill")
                                .foregroundColor(getPriorityColor(fileNode: child))
                        } else {
                            Image(systemName: "doc.fill")
                                .foregroundColor(getPriorityColor(fileNode: child))
                        }
                        Text("\(child.name)")
                        Spacer()
                        Text("\(formatter.getFormatedSize(size: child.getSize()))")
                            .foregroundColor(Color.gray)
                    }.contextMenu() {
                        if child.getPriority() < 1 {
                            Button {
                                let stringArr = child.getIndexes().map { String($0) }
                                let indexes = stringArr.joined(separator: "|")
                                
                                setPriority(indexes: indexes, priority: 1, onComplete: {
                                    success in
                                    if success {
                                        for index in child.getIndexes() {
                                            if let childOfChild = child.search(index: index) {
                                                childOfChild.setPriority(priority: 1)
                                                refresh()
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
                                
                                setPriority(indexes: indexes, priority: 0, onComplete: {
                                    success in
                                    if success {
                                        for index in childIndexes {
                                            if let childOfChild = child.search(index: index) {
                                                childOfChild.setPriority(priority: 0)
                                                refresh()
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
            
            if !isLoaded {
                ProgressView().progressViewStyle(.circular)
                    .navigationTitle("Files")
            }
            
        }
        .searchable(text: $searchQuery)
        .onAppear() {
            getFiles()
        }
        .onSubmit(of: .search, search)
        .onChange(of: searchQuery) { _ in
            if searchQuery.isEmpty { search() }
        }
    }
}

struct TorrentDetailsFilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
