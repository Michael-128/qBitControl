//
//  TorrentAddFileView.swift
//  qBitControl.
//

import SwiftUI
import UniformTypeIdentifiers


struct TorrentAddFileViewDemo: View {
    @State private var fileNames: [String] = []
    @State private var fileContent: [String: Data] = [:]
    @State private var isFileOpen = false
    
    @Binding var isPresented: Bool
    //@State private var buttonTextColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    
    func listElement(value: String) -> some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text("\(value)")
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
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
                            let fileName = fileURL.lastPathComponent
                            self.fileNames.append(fileName)
                            
                            if
                                
                                fileURL.startAccessingSecurityScopedResource() {
                                
                                do {
                                    self.fileContent[fileName] = try Data(contentsOf: fileURL)
                                } catch {
                                    print(error)
                                }
                                
                                
                            }
                            
                            
                            fileURL.stopAccessingSecurityScopedResource()
                        }
                    } catch {
                        print(error)
                    }
                })
                
                TorrentAddOptionsViewDemo(torrent: .constant(""), torrentData: $fileContent, isFile: .constant(true), isPresented: $isPresented)
            }.toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
