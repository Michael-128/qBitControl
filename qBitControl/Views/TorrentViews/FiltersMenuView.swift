//
//  TorrentFilterView.swift
//  qBitControl
//

import SwiftUI

struct FiltersMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var sort: TorrentSortOption
    @Binding var reverse: Bool
    @Binding var filter: TorrentFilterOption
    
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
                        Text("All").tag(TorrentFilterOption.all)
                        Text("Resumed").tag(TorrentFilterOption.resumed)
                        Text("Seeding").tag(TorrentFilterOption.stalledUploading)
                        Text("Downloading").tag(TorrentFilterOption.stalledDownloading)
                        Text("Active Downloading").tag(TorrentFilterOption.downloading)
                        Text("Active Seeding").tag(TorrentFilterOption.seeding)
                        Text("Completed").tag(TorrentFilterOption.completed)
                        Text("Paused").tag(TorrentFilterOption.paused)
                        Text("Active").tag(TorrentFilterOption.active)
                        Text("Inactive").tag(TorrentFilterOption.inactive)
                    }
                    Group {
                        Text("Stalled").tag(TorrentFilterOption.stalled)
                        Text("Errored").tag(TorrentFilterOption.errored)
                    }
                }.pickerStyle(.inline)
                    .onChange(of: filter, perform: { value in
                    defaults.set(filter.rawValue, forKey: "filter")
                })
                
                Picker("Sort By", selection: $sort) {
                    Group {
                        Text("Added On").tag(TorrentSortOption.addedOn)
                        Text("Amount Left").tag(TorrentSortOption.amountLeft)
                        Text("Availability").tag(TorrentSortOption.availability)
                        Text("Category").tag(TorrentSortOption.category)
                        Text("Completed").tag(TorrentSortOption.completed)
                        Text("Completion On").tag(TorrentSortOption.completionOn)
                        Text("Download Limit").tag(TorrentSortOption.dlLimit)
                        Text("Download Speed").tag(TorrentSortOption.dlspeed)
                    }
                    
                    Group {
                        Text("Downloaded").tag(TorrentSortOption.downloaded)
                        Text("Downloaded Session").tag(TorrentSortOption.downloadedSession)
                        Text("ETA").tag(TorrentSortOption.eta)
                        Text("Last Activity").tag(TorrentSortOption.lastActivity)
                        Text("Max Ratio").tag(TorrentSortOption.maxRatio)
                        Text("Max Seeding Time").tag(TorrentSortOption.maxSeedingTime)
                    }
                    
                    Group {
                        Text("Name").tag(TorrentSortOption.name)
                        Text("Seeds In Swarm").tag(TorrentSortOption.numComplete)
                        Text("Peers In Swarm").tag(TorrentSortOption.numIncomplete)
                        Text("Connected Leeches").tag(TorrentSortOption.numLeechs)
                        Text("Connected Seeds").tag(TorrentSortOption.numSeeds)
                        Text("Priority").tag(TorrentSortOption.priority)
                        Text("Progress").tag(TorrentSortOption.progress)
                        Text("Ratio").tag(TorrentSortOption.ratio)
                        Text("Ratio Limit").tag(TorrentSortOption.ratioLimit)
                    }
                    
                    Group {
                        Text("Seeding Time").tag(TorrentSortOption.seedingTime)
                        Text("Seeding Time Limit").tag(TorrentSortOption.seedingTimeLimit)
                        Text("Size").tag(TorrentSortOption.size)
                        Text("State").tag(TorrentSortOption.state)
                        Text("Tags").tag(TorrentSortOption.tags)
                        Text("Time Active").tag(TorrentSortOption.timeActive)
                        Text("Total Size").tag(TorrentSortOption.totalSize)
                    }
                    
                    Group {
                        Text("Upload Limit").tag(TorrentSortOption.upLimit)
                        Text("Uploaded").tag(TorrentSortOption.uploaded)
                        Text("Uploaded Session").tag(TorrentSortOption.uploadedSession)
                        Text("Upload Speed").tag(TorrentSortOption.upspeed)
                    }
                }.pickerStyle(.inline)
                    .onChange(of: sort, perform: { value in
                    defaults.set(sort.rawValue, forKey: "sort")
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
                        AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_categories_failed", errorDescription: error.localizedDescription))
                    }
                    
                    do {
                        let fetchedTags = try await client.getTags()
                        self.tagsArr = fetchedTags
                    } catch {
                        AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_tags_failed", errorDescription: error.localizedDescription))
                    }
                }
            }
        }
    }
}
