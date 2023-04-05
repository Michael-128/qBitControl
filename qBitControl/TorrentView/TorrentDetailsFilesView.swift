//
//  TorrentDetailsFilesView.swift
//  qBitControl
//

import SwiftUI

struct TorrentDetailsFilesView: View {
    @Binding var torrentHash: String

    @State private var sortedFiles: [Dictionary<String, [FileNode]>.Element] = []
    @State private var rootFileNodes: [FileNode] = []
    @StateObject private var rootFileNode = FileNode(name: "")
    
    @State private var isLoaded = false
    @State private var searchQuery = ""
    
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
            
            for file in files {
                var fileComponents = file.name.components(separatedBy: "/")
                let actualFilename = fileComponents.last!
                fileComponents.popLast()
                let path = fileComponents.joined(separator: "/")
                filesWithCommonPaths[path, default: []].append(FileNode(index: file.index, name: actualFilename, size: file.size, progress: file.progress, priority: file.priority, is_seed: file.is_seed, availability: file.availability))
            }
            
            self.sortedFiles = filesWithCommonPaths.sorted(by: { $0.0 < $1.0 })
            print(files.count)
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
        
        //print(endIndex)
        //print(sortedFiles.count)
        
        let rootFileNode = self.rootFileNode
        
        for index in startIndex...newEndIndex {
            let path = sortedFiles[index].key
            let files = sortedFiles[index].value
            
            
            let pathComponents = path.components(separatedBy: "/")
            
            //print(path)
            //print(pathComponents)
            
            var lastFileNode = rootFileNode
            
            for pathComponent in pathComponents {
                if let existingFileNode = lastFileNode.shallowSearch(name: pathComponent) {
                    //print("Path component: \(pathComponent) exists in \(lastFileNode.name)")
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
        
        //print(rootFileNode.getIndexes())
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
            print("\(self.rootFileNodes.count) hits")
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
                                                print(childOfChild.getPriority())
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
            }.onSubmit(of: .search, search)
            .onChange(of: searchQuery) {
            _ in
            if searchQuery.isEmpty {search()}
        }
    }
}

struct TorrentDetailsFilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
