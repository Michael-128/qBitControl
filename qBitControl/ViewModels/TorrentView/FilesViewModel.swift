//
//  FilesViewModel.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 14/03/2026.
//

import SwiftUI

class FilesViewModel: ObservableObject {
    @Published var torrentHash: String

    @Published private var sortedFiles: [Dictionary<String, [FileNode]>.Element] = []
    @Published public var rootFileNodes: [FileNode] = []
    @Published public var rootFileNode = FileNode(name: "")
    
    @Published public var isLoaded = false
    @Published public var searchQuery = ""
    
    init(torrentHash: String) {
        self.torrentHash = torrentHash
    }
    
    private let step = 50
    @Published private var curStep = 0
    
    
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
            
            DispatchQueue.main.async {
                var filesWithCommonPaths: [String: [FileNode]] = ["":[]]
                
                for file in files {
                    var fileComponents = file.name.components(separatedBy: "/")
                    let actualFilename = fileComponents.last!
                    let _ = fileComponents.popLast()
                    let path = fileComponents.joined(separator: "/")
                    filesWithCommonPaths[path, default: []].append(FileNode(index: file.index, name: actualFilename, size: file.size, progress: file.progress, priority: file.priority, is_seed: file.is_seed, availability: file.availability))
                }
                
                self.sortedFiles = filesWithCommonPaths.sorted(by: { $0.0 < $1.0 })
                self.getNextFileNodes(startIndex: self.curStep, endIndex: self.getNextStep(currentStep: self.curStep))
            }
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
        
        DispatchQueue.main.async {
            self.rootFileNodes = self.rootFileNode.children ?? []
            
            self.isLoaded = true
            
            self.getNextFileNodes(startIndex: self.curStep, endIndex: self.getNextStep(currentStep: self.curStep))
        }
    }
    
    func getPriorityColor(fileNode: FileNode) -> Color {
        return fileNode.getPriority() > 0 ? Color.primary : Color.gray
    }
    
    func setPriority(child: FileNode, priority: FilePriority) {
        let stringArr = child.getIndexes().map { String($0) }
        let indexes = stringArr.joined(separator: "|")
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/filePrio", queryItems: [
            URLQueryItem(name: "hash", value: torrentHash),
            URLQueryItem(name: "id", value: indexes),
            URLQueryItem(name: "priority", value: "\(priority.rawValue)")
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {
            code in
            if let code = code {
                if code == 200 {
                    for index in child.getIndexes() {
                        if let childOfChild = child.search(index: index) {
                            childOfChild.setPriority(priority: Int(priority.rawValue))
                            self.refresh()
                        }
                    }
                }
            }
        })
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.rootFileNode.objectWillChange.send()
            self.rootFileNodes = self.rootFileNode.children ?? []
        }
    }
    
    func search() {
        if searchQuery.isEmpty {
            self.rootFileNodes = rootFileNode.children ?? []
        } else {
            self.rootFileNodes = rootFileNode.findAll(query: searchQuery)
        }
    }
}

