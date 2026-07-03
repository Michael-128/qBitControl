//
//  TorrentFilterView.swift
//  qBitControl
//

import SwiftUI

struct FiltersMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var sort: String
    @Binding var reverse: Bool
    @Binding var filter: String
    
    @State private var categories: [Category] = []
    @State private var tagsArr: [String] = []
    
    @Binding var category: String
    @Binding var tag: String
    
    private let defaults = UserDefaults.standard
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
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
                
                if categories.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("All").tag("All")
                        Text("Uncategorized").tag("")
                        ForEach(categories, id: \.self) { theCategory in
                            Text(theCategory.name).tag(theCategory.name)
                        }
                    }.pickerStyle(.inline)
                }
                
                if tagsArr.count > 1 {
                    Picker("Tags", selection: $tag) {
                        Text("All").tag("All")
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
                        Text("Availability").tag("availability")
                        Text("Category").tag("category")
                        Text("Completed").tag("completed")
                        Text("Completion On").tag("completion_on")
                        Text("Download Limit").tag("dl_limit")
                        Text("Download Speed").tag("dlspeed")
                    }
                    
                    Group {
                        Text("Downloaded").tag("downloaded")
                        Text("Downloaded Session").tag("downloaded_session")
                        Text("ETA").tag("eta")
                        Text("Last Activity").tag("last_activity")
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
                        Text("Seeding Time").tag("seeding_time")
                        Text("Seeding Time Limit").tag("seeding_time_limit")
                        Text("Size").tag("size")
                        Text("State").tag("state")
                        Text("Tags").tag("tags")
                        Text("Time Active").tag("time_active")
                        Text("Total Size").tag("total_size")
                    }
                    
                    Group {
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
                Task {
                    do {
                        let fetchedCategories = try await client.getCategories()
                        self.categories = fetchedCategories.map { $1 }.sorted { $0.name < $1.name }
                    } catch {
                        print("Failed to fetch categories: \(error)")
                    }
                    
                    do {
                        let fetchedTags = try await client.getTags()
                        self.tagsArr = fetchedTags
                    } catch {
                        print("Failed to fetch tags: \(error)")
                    }
                }
            }
        }
    }
}
