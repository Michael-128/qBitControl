//
//  TorrentAddOptionsView.swift
//  qBitControl
//

import SwiftUI

struct TorrentAddOptionsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var torrent: String
    @Binding var torrentData: [String: Data]
    @Binding var isFile: Bool
    @Binding var isPresented: Bool
    
    @State private var savePath = ""
    @State private var defaultSavePath = ""
    
    @State private var cookie = ""
    @State private var category = ""
    @State private var tags = ""
    
    @State private var skipChecking = false
    @State private var paused = false
    @State private var sequentialDownload = false
    
    @State private var showAdvanced = false
    
    @State private var showLimits = false
    @State private var DLlimit = ""
    @State private var UPlimit = ""
    @State private var ratioLimit = ""
    @State private var seedingTimeLimit = ""
    
    @State private var categoriesArr = ["None"]
    @State private var categoriesPaths = ["None": ""]
    @State private var tagsArr: [String] = ["None"]
    
    func limitField(title: String, textField: some View) -> some View {
        HStack {
            Text(title)
            Spacer()
            textField
                .multilineTextAlignment(.trailing)
        }
    }
    
    func addTorrent() {
        if !isFile {
            qBittorrent.addMagnetTorrent(torrent: URLQueryItem(name: "urls", value: torrent), savePath: savePath, cookie: cookie, category: category, tags: tags, skipChecking: skipChecking, paused: paused, sequentialDownload: sequentialDownload, dlLimit: Int(DLlimit) ?? -1, upLimit: Int(UPlimit) ?? -1, ratioLimit: Float(ratioLimit) ?? -1.0, seedingTimeLimit: Int(seedingTimeLimit) ?? -1)
        } else {
            qBittorrent.addFileTorrent(torrents: torrentData, savePath: savePath, cookie: cookie, category: category, tags: tags, skipChecking: skipChecking, paused: paused, sequentialDownload: sequentialDownload, dlLimit: Int(DLlimit) ?? -1, upLimit: Int(UPlimit) ?? -1, ratioLimit: Float(ratioLimit) ?? -1.0, seedingTimeLimit: Int(seedingTimeLimit) ?? -1)
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        Group {
            Group {
                Section(header: Text("Save Path")) {
                    TextField("Path", text: $savePath)
                }
                
                Section(header: Text("Info")) {
                    if showAdvanced {TextField("Cookie", text: $cookie)}
                    Picker("Category", selection: $category, content: {
                        ForEach(categoriesArr, id: \.self, content: {
                            category in
                            Text(category).tag(category)
                        })
                    }).onChange(of: category, perform: {
                        _ in
                        dump(categoriesPaths)
                        savePath = defaultSavePath
                        
                        if category != "None" {
                            if categoriesPaths[category] != "" {
                                savePath = categoriesPaths[category] ?? defaultSavePath
                            }
                        }
                    })
                    
                    Picker("Tags", selection: $tags, content: {
                        ForEach(tagsArr, id: \.self, content: {
                            tag in
                            Text(tag).tag(tag)
                        })
                    })
                }
            }
            
            Group {
                Section(header: Text("Management")) {
                    if showAdvanced {
                        Toggle(isOn: $skipChecking, label: {Text("Skip Checking")})
                    }
                    Toggle(isOn: $paused, label: {Text("Pause")})
                    Toggle(isOn: $sequentialDownload, label: {Text("Sequential Download")})
                }
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: $showAdvanced, label: {Text("Show Advanced Options")})
                }
            }
            
            Group {
                Section(header: Text("Limits")) {
                    Toggle(isOn: $showLimits, label: {Text("Limits")})
                    if showLimits {
                        /*HStack {
                         Text("Download Limit")
                         Spacer()
                         TextField("bytes/s", text: $DLlimit)
                         .multilineTextAlignment(.trailing)
                         }*/
                        
                        limitField(title: "Download Limit", textField: TextField("0 bytes/s", text: $DLlimit))
                        
                        limitField(title: "Upload Limit", textField: TextField("0 bytes/s", text: $UPlimit))
                        
                        limitField(title: "Ratio Limit", textField: TextField("Ratio Limit", text: $ratioLimit))
                        
                        limitField(title: "Seeding Time Limit", textField: TextField("Time Limit", text: $seedingTimeLimit))
                        
                    }
                }
                
                Section {
                    Button(action: {
                        addTorrent()
                        isPresented = false
                    }, label: {
                        Text("ADD")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    })
                    .buttonStyle(.borderedProminent)
                }.listRowBackground(Color.blue)
            }
        }.onAppear() {
            qBittorrent.getPreferences(completionHandler: {preferences in
                savePath = preferences.save_path ?? ""
                defaultSavePath = preferences.save_path ?? ""
            })
            qBittorrent.getCategories(completionHandler: {
                categories in
                dump(categories)
                for (key, value) in categories {
                    categoriesArr.append(key)
                    categoriesPaths[key] = value["savePath"] ?? ""
                }
                
                if category != "None" {
                    if categoriesPaths[category] != "" {
                        savePath = categoriesPaths[category] ?? savePath
                    }
                }
            })
            qBittorrent.getTags(completionHandler: {
                tags in
                tags.forEach({
                    tag in
                    tagsArr.append(tag)
                })
            })
        }
        
    }
}

/*struct TorrentAddOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentAddOptionsView(urls: .constant("url"))
    }
}*/
