import SwiftUI

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
    
    init() {
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
    
    private var timer: Timer?
    
    func startSearch() {
        if(isRunning) { return }
        if(query.isEmpty) { return }
        
        qBittorrent.getSearchStart(pattern: self.query, category: self.category.id, completionHandler: { result in
            DispatchQueue.main.async {
                self.searchId = result.id
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    self.monitorSearchResults()
                }
            }
        })
    }
    
    private func endSearch() {
        DispatchQueue.main.async {
            self.searchId = nil
        }
    }
    
    private func monitorSearchResults() {
        self.validateTimer()
        
        if let searchId = self.searchId {   
            qBittorrent.getSearchResults(id: searchId, completionHandler: { response in
                DispatchQueue.main.async {
                    self.latestResponse = response
                }
                
                if(response.status == "Stopped") {
                    self.endSearch()
                }
            })
        }
    }
    
    private func validateTimer() {
        if(searchId == nil) {
            self.timer?.invalidate()
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
        var categories: Set<SearchCategory> = []
        
        qBittorrent.getSearchPlugins(completionHandler: { plugins in
            plugins.forEach { plugin in
                categories = categories.union(plugin.supportedCategories ?? [])
            }
            
            DispatchQueue.main.async {
                self.categories = categories
            }
        })
    }
    
    func onRowTap(result: SearchResult) {
        self.tappedResult = result
        self.isTorrentAddSheet.toggle()
    }
}
