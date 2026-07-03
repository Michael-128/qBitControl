//
//  SearchViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var category: SearchCategory = SearchCategory(name: "All categories", id: "all")
    @Published var sortBy: SearchSortOptions = .seeders
    @Published var isDescending: Bool = true
    
    @Published var tappedResult: SearchResult?
    
    @Published var categories: Set<SearchCategory> = []
    var categoriesArray: [SearchCategory] {
        Array(self.categories).sorted { $0.name < $1.name }
    }
    
    @Published var searchId: Int?
    
    @Published var isFilterSheet: Bool = false
    @Published var isTorrentAddSheet: Bool = false
    
    @Published var latestResponse: SearchResponse?
    
    private let client: TorrentClientProtocol
    private var searchPollingTask: Task<Void, Never>?
    
    init(client: TorrentClientProtocol) {
        self.client = client
        self.loadFilters()
        self.fetchCategories()
    }
    
    var latestResults: [SearchResult] {
        if let latestResponse = self.latestResponse {
            var results = latestResponse.results
            results = results.sorted(by: sorter)
            results = isDescending ? results.reversed() : results
            return results
        }
        
        return []
    }
    
    var lastestTotal: Int {
        self.latestResponse?.total ?? 0
    }
    
    var isResponse: Bool {
        self.lastestTotal > 0
    }
    
    var isRunning: Bool {
        searchId != nil
    }
    
    func startSearch() {
        if(isRunning) { return }
        if(query.isEmpty) { return }
        
        Task {
            do {
                let result = try await client.getSearchStart(pattern: self.query, category: self.category.id, plugins: true)
                self.searchId = result.id
                
                startPolling()
            } catch {
                print("Failed to start search: \(error)")
            }
        }
    }
    
    func endSearch() {
        self.searchId = nil
        stopPolling()
    }
    
    private func startPolling() {
        searchPollingTask?.cancel()
        searchPollingTask = Task {
            while !Task.isCancelled {
                await monitorSearchResults()
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } catch {
                    break
                }
            }
        }
    }
    
    private func stopPolling() {
        searchPollingTask?.cancel()
        searchPollingTask = nil
    }
    
    private func monitorSearchResults() async {
        guard let searchId = self.searchId else {
            stopPolling()
            return
        }
        
        do {
            let response = try await client.getSearchResults(id: searchId, limit: 500, offset: 0)
            self.latestResponse = response
            if response.status == "Stopped" {
                self.endSearch()
            }
        } catch {
            print("Failed to get search results: \(error)")
        }
    }
    
    private func sorter(res1: SearchResult, res2: SearchResult) -> Bool {
        switch(sortBy) {
        case .name:
            return self.compareValues(res1.fileName, res2.fileName)
        case .size:
            return self.compareValues(res1.fileSize, res2.fileSize)
        case .seeders:
            return self.compareValues(res1.nbSeeders, res2.nbSeeders)
        case .leechers:
            return self.compareValues(res1.nbLeechers, res2.nbLeechers)
        }
    }
    
    private func compareValues<T: Comparable>(_ a: T?, _ b: T?) -> Bool {
        if let a = a, let b = b {
            return a < b
        }
        
        return false
    }
    
    private func prepareKey(_ name: String) -> String {
        return "searchViewModel-\(name)"
    }
    
    func saveFilters() {
        let defaults = UserDefaults.standard
        
        defaults.set(sortBy.rawValue, forKey: self.prepareKey("sortBy"))
        defaults.set(isDescending, forKey: self.prepareKey("isDescending"))
        print(isDescending)
    }
    
    private func loadFilters() {
        let defaults = UserDefaults.standard
        
        if let sortBy = defaults.string(forKey: self.prepareKey("sortBy")) {
            self.sortBy = SearchSortOptions(rawValue: sortBy) ?? self.sortBy
        }
        
        self.isDescending = defaults.bool(forKey: self.prepareKey("isDescending"))
        print(self.isDescending)
    }
    
    private func fetchCategories() {
        Task {
            do {
                let plugins = try await client.getSearchPlugins()
                var categoriesSet: Set<SearchCategory> = []
                plugins.forEach { plugin in
                    categoriesSet = categoriesSet.union(plugin.supportedCategories ?? [])
                }
                self.categories = categoriesSet
            } catch {
                print("Failed to fetch search plugins: \(error)")
            }
        }
    }
    
    func onRowTap(result: SearchResult) {
        self.tappedResult = result
        self.isTorrentAddSheet.toggle()
    }
}
