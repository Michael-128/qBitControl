//
//  TorrentFilterView.swift
//  qBitControl
//

import SwiftUI

struct TorrentFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var sort: String
    @Binding var reverse: Bool
    @Binding var filter: String
    
    @State private var categoriesArr: [String] = []
    @State private var tagsArr: [String] = []
    
    @Binding var category: String
    @Binding var tag: String
    
    
    private let defaults = UserDefaults.standard

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Descending")) {
                    Toggle(isOn: $reverse) {
                        Text("Descending")
                    }.onChange(of: reverse) { value in
                        defaults.set(reverse, forKey: "reverse")
                    }
                }
                
                if categoriesArr.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("None").tag("None")
                        Text("Uncategorized").tag("")
                        ForEach(categoriesArr, id: \.self) {
                            category1 in
                            Text(category1).tag(category1)
                        }
                    }.pickerStyle(.inline)
                }
                
                if tagsArr.count > 1 {
                    Picker("Tags", selection: $tag) {
                        Text("None").tag("None")
                        Text("Untagged").tag("")
                        ForEach(tagsArr, id: \.self) {
                            tag1 in
                            Text(tag1).tag(tag1)
                        }
                    }.pickerStyle(.inline)
                }
                
                Picker("Filter By", selection: $filter) {
                    Group {
                        Text("All").tag("all")
                        Text("Resumed").tag("resumed")
                        Text("Seeding").tag("stalled_uploading")
                        Text("Downloading").tag("stalled_downloading")
                        Text("Active Downloading").tag("downloading")
                        Text("Active Seeding").tag("seeding")
                        Text("Completed").tag("completed")
                        Text("Paused").tag("paused")
                        Text("Active").tag("active")
                        Text("Inactive").tag("inactive")
                    }
                    Group {
                        Text("Stalled").tag("stalled")
                        Text("Errored").tag("errored")
                    }
                }.pickerStyle(.inline)
                    .onChange(of: filter, perform: {
                    value in
                    defaults.set(filter, forKey: "filter")
                })
                
                Picker("Sort By", selection: $sort) {
                    Group {
                        Text("Added On").tag("added_on")
                        Text("Amount Left").tag("amount_left")
                        //Text("Auto Torrent Management").tag("auto_tmm")
                        Text("Availability").tag("availability")
                        Text("Category").tag("category")
                        Text("Completed").tag("completed")
                        Text("Completion On").tag("completion_on")
                        //Text("Content Path").tag("content_path")
                        Text("Download Limit").tag("dl_limit")
                        Text("Download Speed").tag("dlspeed")
                    }
                    
                    Group {
                        Text("Downloaded").tag("downloaded")
                        Text("Downloaded Session").tag("downloaded_session")
                        Text("ETA").tag("eta")
                        //Text("FL Piece Ratio").tag("f_l_piece_prio")
                        //Text("Force Start").tag("force_start")
                        //Text("Hash").tag("hash")
                        Text("Last Activity").tag("last_activity")
                        //Text("Magnet URI").tag("magnet_uri")
                        Text("Max Ratio").tag("max_ratio")
                        Text("Max Seeding Time").tag("max_seeding_time")
                    }
                    
                    Group {
                        Text("Name").tag("name")
                        Text("Seeds In Swarm").tag("num_complete")
                        Text("Peers In Swarm").tag("num_incomplete")
                        Text("Connected Leeches").tag("num_leechs")
                        Text("Connected Seeds").tag("num_seeds")
                        Text("Priority").tag("priority")
                        Text("Progress").tag("progress")
                        Text("Ratio").tag("ratio")
                        Text("Ratio Limit").tag("ratio_limit")
                    }
                    
                    Group {
                        //Text("Save Path").tag("save_path")
                        Text("Seeding Time").tag("seeding_time")
                        Text("Seeding Time Limit").tag("seeding_time_limit")
                        //Text("Seen Complete").tag("seen_complete")
                        //Text("Seq DL").tag("seq_dl")
                        Text("Size").tag("size")
                        Text("State").tag("state")
                        //Text("Super Seeding").tag("super_seeding")
                        Text("Tags").tag("tags")
                        Text("Time Active").tag("time_active")
                        Text("Total Size").tag("total_size")
                    }
                    
                    Group {
                        //Text("Tracker").tag("tracker")
                        Text("Upload Limit").tag("up_limit")
                        Text("Uploaded").tag("uploaded")
                        Text("Uploaded Session").tag("uploaded_session")
                        Text("Upload Speed").tag("upspeed")
                    }
                }.pickerStyle(.inline)
                    .onChange(of: sort, perform: {
                    value in
                    defaults.set(sort, forKey: "sort")
                })
                
                .navigationBarTitle("Filters")
            }.toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }.onAppear() {
                qBittorrent.getCategories(completionHandler: {
                    categories in
                    for (key, _) in categories {
                        categoriesArr.append(key)
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
}

/*struct TorrentFilterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {}
                .sheet(isPresented: .constant(true), content: {
                    TorrentFilterView(sort: .constant("name"), reverse: .constant(false), filter: .constant("all"))
                })
        }
    }
}*/
