//
//  TorrentAddFileView.swift
//  qBitControl.
//

import SwiftUI
import UniformTypeIdentifiers


struct TorrentAddFileView: View {
    @State private var fileNames: [String] = []
    @State private var fileContent: [String: Data] = [:]
    @State private var isFileOpen = false
    
    @Binding var isPresented: Bool
    
    @Binding public var openedFileURL: [URL]
    
    func listElement(value: String) -> some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text("\(value)")
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }
    }
    
    func handleFile(fileURL: URL) -> Void {
        if(fileURL.pathExtension != "torrent") { return }
        
        let fileName = fileURL.lastPathComponent
        self.fileNames.append(fileName)
        
        if fileURL.startAccessingSecurityScopedResource() {
            do {
                self.fileContent[fileName] = try Data(contentsOf: fileURL)
            } catch {
                print(error)
            }
        }
        
        fileURL.stopAccessingSecurityScopedResource()
    }
    
    var body: some View {
        Group {
            Section(header: Text("Files")) {
                Button {
                    isFileOpen.toggle()
                } label: {
                    Text("Open Files..")
                }
                
                ForEach(fileNames, id: \.self) {
                    fileName in
                    listElement(value: fileName)
                }
            }
            .navigationTitle("File")
        }.fileImporter(isPresented: $isFileOpen, allowedContentTypes: [.data], allowsMultipleSelection: true, onCompletion: {
            files in
            do {
                for fileURL in try files.get() {
                    handleFile(fileURL: fileURL)
                }
            } catch {
                print(error)
            }
        }).onAppear() {
            for fileURL in openedFileURL {
                handleFile(fileURL: fileURL)
            }
            
            openedFileURL = []
        }
        
        TorrentAddOptionsView(torrent: .constant(""), torrentData: $fileContent, isFile: .constant(true), isPresented: $isPresented)
    }
}

struct TorrentAddFileView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentAddFileView(isPresented: .constant(true), openedFileURL: .constant([]))
    }
}
