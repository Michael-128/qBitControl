import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var category: String = "all"
    
    @Published var searchId: Int?
    
    @Published var latestResponse: SearchResponse?
    
    var latestResults: [SearchResult] {
        self.latestResponse?.results ?? []
    }
    
    var lastestTotal: Int {
        self.latestResponse?.total ?? 0
    }
    
    var isResponse: Bool {
        self.latestResponse != nil
    }
    
    var isRunning: Bool {
        searchId != nil
    }
    
    private var timer: Timer?
    
    func startSearch() {
        if(isRunning) { return }
        
        qBittorrent.getSearchStart(pattern: self.query, category: self.category, completionHandler: { result in
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
}
