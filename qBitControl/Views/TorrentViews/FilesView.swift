//
//  TorrentDetailsFilesView.swift
//  qBitControl
//

import SwiftUI

struct FilesView: View {
    @Binding var torrentHash: String

    @State private var sortedFiles: [Dictionary<String, [FileNode]>.Element] = []
    @State private var rootFileNodes: [FileNode] = []
    @StateObject private var rootFileNode = FileNode(name: "")

    @State private var isLoaded = false
    @State private var searchQuery = ""
    @State private var renameTarget: FileNode?
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var filePathMap: [Int: String] = [:]
    
    // Max dirs loaded at a time
    let step = 50
    @State private var curStep = 0
    
    func getNextStep(currentStep: Int) -> Int {
        let nextStep = currentStep + step
        self.curStep = nextStep + 1
        return nextStep
    }
    
    func getFiles() {
        isLoaded = false
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/files", queryItems: [URLQueryItem(name: "hash", value: torrentHash)])
        
        qBitRequest.requestFilesJSON(request: request, completionHandler: {
            files in

            var filesWithCommonPaths: [String: [FileNode]] = ["":[]]
            var pathMap: [Int: String] = [:]

            for file in files {
                pathMap[file.index] = file.name
                var fileComponents = file.name.components(separatedBy: "/")
                let actualFilename = fileComponents.last!
                let _ = fileComponents.popLast()
                let path = fileComponents.joined(separator: "/")
                filesWithCommonPaths[path, default: []].append(FileNode(index: file.index, name: actualFilename, size: file.size, progress: file.progress, priority: file.priority, is_seed: file.is_seed, availability: file.availability))
            }

            self.filePathMap = pathMap
            self.sortedFiles = filesWithCommonPaths.sorted(by: { $0.0 < $1.0 })
            getNextFileNodes(startIndex: curStep, endIndex: getNextStep(currentStep: curStep))
        })
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
    
    func setPriority(indexes: String, priority: Int, onComplete: @escaping (Bool) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/filePrio", queryItems: [
            URLQueryItem(name: "hash", value: torrentHash),
            URLQueryItem(name: "id", value: indexes),
            URLQueryItem(name: "priority", value: "\(priority)")
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {
            code in
            if let code = code {
                if code == 200 {
                    onComplete(true)
                } else {
                    onComplete(false)
                }
            } else {
                onComplete(false)
            }
        })
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
                List(rootFileNodes, children: \.children/*, selection: $selection*/) {
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
                        Text("\(qBittorrent.getFormatedSize(size: child.getSize()))")
                            .foregroundColor(Color.gray)
                    }.contextMenu() {
                        Section("Priority") {
                            Button {
                                setChildPriority(child: child, priority: 7)
                            } label: {
                                Label("Maximum", systemImage: "arrow.up.to.line")
                            }
                            Button {
                                setChildPriority(child: child, priority: 6)
                            } label: {
                                Label("High", systemImage: "arrow.up")
                            }
                            Button {
                                setChildPriority(child: child, priority: 1)
                            } label: {
                                Label("Normal", systemImage: "arrow.down")
                            }
                            Button(role: .destructive) {
                                setChildPriority(child: child, priority: 0)
                            } label: {
                                Label("Do Not Download", systemImage: "xmark")
                            }
                        }
                        if !child.isDir {
                            Section {
                                Button {
                                    renameTarget = child
                                    renameText = child.name
                                    showRenameAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
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
        .onAppear() { getFiles() }
        .onSubmit(of: .search, search)
        .onChange(of: searchQuery) { _ in
            if searchQuery.isEmpty { search() }
        }
        .alert("Rename File", isPresented: $showRenameAlert) {
            TextField("File Name", text: $renameText)
            Button("Rename") {
                guard let target = renameTarget,
                      let fileIndex = target.index,
                      let oldPath = filePathMap[fileIndex],
                      !renameText.isEmpty, renameText != target.name else { return }
                let pathComponents = oldPath.components(separatedBy: "/")
                let newPath = pathComponents.dropLast().joined(separator: "/") + (pathComponents.count > 1 ? "/" : "") + renameText
                qBittorrent.renameFile(hash: torrentHash, oldPath: oldPath, newPath: newPath)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { getFiles() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func setChildPriority(child: FileNode, priority: Int) {
        let childIndexes = child.getIndexes()
        let stringArr = childIndexes.map { String($0) }
        let indexes = stringArr.joined(separator: "|")

        setPriority(indexes: indexes, priority: priority, onComplete: { success in
            if success {
                for index in childIndexes {
                    if let childOfChild = child.search(index: index) {
                        childOfChild.setPriority(priority: priority)
                        refresh()
                    }
                }
            }
        })
    }
}

struct TorrentDetailsFilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
