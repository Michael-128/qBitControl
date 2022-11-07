//
//  FileNodeClass.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 07/11/2022.
//

import Foundation


final class FileNode: Identifiable, ObservableObject {
    let id = UUID()
    var index: Int? // File index
    let name: String // File name (including relative path)
    var size: Int64? // File size (bytes)
    var progress: Float? // File progress (percentage/100)
    var priority: Int? // File priority. See possible values here below
    var is_seed: Bool? // True if file is seeding/complete
    //var piece_range: [Int]?// The first number is the starting piece index and the second number is the ending piece index (inclusive)
    var availability: Float? // Percentage of file pieces currently available (percentage/100)
    
    //weak var parent: FileNode?
    
    let isDir: Bool
    
    var children: [FileNode]?
    
    init(index: Int, name: String, size: Int64, progress: Float, priority: Int, is_seed: Bool?, availability: Float) {
        self.isDir = false
        //self.children = []
        self.index = index
        self.name = name
        self.size = size
        self.progress = progress
        self.priority = priority
        self.is_seed = is_seed
        //self.piece_range = piece_range
        self.availability = availability
    }
    
    init(name: String) {
        self.isDir = true
        self.name = name
    }
    
    func add(child: FileNode) {
        if children == nil {self.children = []}
        children?.append(child)
    }
    
    func addMultiple(children: [FileNode]) {
        self.children = children
    }
}

extension FileNode: CustomStringConvertible {
  var description: String {
    var text = "\(name)"
    if !(children ?? []).isEmpty {
      text += "\n{\n - " + (children ?? []).map { $0.description }.joined(separator: "\n - ") + "\n} "
    }
    return text
  }
}

extension FileNode {
    func getIndexes() -> [Int] {
        if !self.isDir {
            if let index = self.index {
                return [index]
            }
        }
        
        var indexes: [Int] = []
        
        for child in (children ?? []) {
            indexes += child.getIndexes()
        }
        
        return indexes
    }
  
    func getSize() -> Int64 {
        if !self.isDir {
            return size ?? 0
        }
        
        var size: Int64 = 0
        
        for child in (children ?? []) {
            size += child.getSize()
        }
        
        return size
    }
    
    func getDirCount() -> Int {
        var dirs = 0
        
        if self.isDir {
            dirs += 1
        }
        
        for child in (children ?? []) {
            dirs += child.getDirCount()
        }
        
        return dirs
    }
    
    func getFileCount() -> Int {
        var files = 0
        
        if !self.isDir {
            files += 1
        }
        
        for child in (children ?? []) {
            files += child.getFileCount()
        }
        
        return files
    }
    
    func getPriority() -> Int {
        if let priority = priority {
            return priority
        }
        
        for child in (children ?? []) {
            let priority = child.getPriority()
            if priority > 0 {return priority}
        }
        
        return 0
    }
    
    func setPriority(priority: Int) {
        self.priority = priority
    }
    
    func search(index: Int) -> FileNode? {
        if index == self.index {
            return self
        }
        
        for child in (children ?? []) {
            if let found = child.search(index: index) {
                return found
            }
        }
        
        return nil
    }
    
    func findAll(query: String) -> [FileNode] {
        var hits: [FileNode] = []
        
        if self.name.lowercased().contains(query.lowercased()) {
            return [self]
        }
        
        for child in (children ?? []) {
            hits += child.findAll(query: query)
        }
        
        return hits
    }
    
    
    // 1
  func search(name: String) -> FileNode? {
    // 2
    if name == self.name {
      return self
    }
    // 3
    for child in (children ?? []) {
      if let found = child.search(name: name) {
        return found
      }
    }
    // 4
    return nil
  }
    
    // 1
    func shallowSearch(name: String) -> FileNode? {
      // 2
        if name == self.name {
            return self
        }
        // 3
        for child in (children ?? []) {
            if name == child.name {
                return child
            }
        }
        // 4
        return nil
    }
}

extension FileNode
{
   func treeLines(_ nodeIndent:String="", _ childIndent:String="") -> [String]
   {
       return [ nodeIndent + self.name ]
           + (children ?? []).enumerated().map{ ($0 < (children ?? []).count-1, $1) }
             .flatMap{ $0 ? $1.treeLines("┣╸","┃ ") : $1.treeLines("┗╸","  ") }
             .map{ childIndent + $0 }
   }

   func printTree()
   { print(treeLines().joined(separator:"\n")) }
}
