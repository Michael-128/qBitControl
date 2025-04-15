import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var category: String = "all"
    
    @Published var searchId: Int?
    
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
        self.searchId = nil
    }
    
    private func monitorSearchResults() {
        self.validateTimer()
        
        print("Do something")
        
        self.endSearch()
    }
    
    private func validateTimer() {
        if(searchId == nil) {
            self.timer?.invalidate()
        }
    }
}
