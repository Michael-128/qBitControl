//
//  FileNodeView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 14/03/2026.
//

import SwiftUI

struct FileNodeView: View {
    @Binding public var child: FileNode
    
    func getPriorityColor(fileNode: FileNode) -> Color {
        switch(FilePriority(priority: fileNode.getPriority())) {
        case .unknown:
            return Color.gray
        case .doNotDownload:
            return Color.gray
        case .normal:
            return Color.blue
        case .high:
            return Color.orange
        case .max:
            return Color.red
        }
    }
    
    var body: some View {
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
        }
    }
}
