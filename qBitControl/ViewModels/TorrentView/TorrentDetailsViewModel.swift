import SwiftUI

class TorrentDetailsViewModel: ObservableObject {
    @Published public var torrent: Torrent
    
    @Published public var isDeleteAlert: Bool = false
    
    @Published public var isSequentialDownload: Bool = false
    @Published public var isFLPiecesFirst: Bool = false
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    private var timer: Timer?
    
    init(torrent: Torrent) {
        self.torrent = torrent
        self.isSequentialDownload = torrent.seq_dl
        self.isFLPiecesFirst = torrent.f_l_piece_prio
    }
    
    func setRefreshTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.getTorrent()
        }
    }
    
    func removeRefreshTimer() {
        timer?.invalidate()
    }
    
    func getTorrent() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [URLQueryItem(name:"hashes", value: torrent.hash)])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            if let torrent = torrent.first {
                DispatchQueue.main.async {
                    self.torrent = torrent
                    self.isSequentialDownload = torrent.seq_dl
                    self.isFLPiecesFirst = torrent.f_l_piece_prio
                }
            }
        }
    }
    
    func getCategory() -> String { torrent.category != "" ? torrent.category : "None" }
    func getTags() -> String { torrent.tags != "" ? torrent.tags : "None" }
    func getAddedOn() -> String { qBittorrent.getFormatedDate(date: torrent.added_on) }
    func getSize() -> String { "\(qBittorrent.getFormatedSize(size: torrent.size))" }
    func getTotalSize() -> String { "\(qBittorrent.getFormatedSize(size: torrent.total_size))" }
    func getAvailability() -> String { torrent.availability < 0 ? "-" : "\(String(format: "%.1f", torrent.availability*100))%" }
    func getState() -> String { "\(qBittorrent.getState(state: torrent.state))" }
    func getProgress() -> String { "\(String(format: "%.2f", (torrent.progress*100)))%" }
    func getDownloadSpeed() -> String { "\(qBittorrent.getFormatedSize(size: torrent.dlspeed))/s" }
    func getUploadSpeed() -> String { "\(qBittorrent.getFormatedSize(size: torrent.upspeed))/s" }
    func getDownloaded() -> String { "\(qBittorrent.getFormatedSize(size: torrent.downloaded))" }
    func getUploaded() -> String { "\(qBittorrent.getFormatedSize(size: torrent.uploaded))" }
    func getRatio() -> String { "\(String(format:"%.2f", torrent.ratio))" }
    func getDownloadedSession() -> String { "\(qBittorrent.getFormatedSize(size: torrent.downloaded_session))" }
    func getUploadedSession() -> String { "\(qBittorrent.getFormatedSize(size: torrent.uploaded_session))" }
    func getMaxRatio() -> String { "\(torrent.max_ratio > -1 ? String(format:"%.2f", torrent.max_ratio) : NSLocalizedString("None", comment: "None"))" }
    func getDownloadLimit() -> String { "\(torrent.dl_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.dl_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    func getUploadLimit() -> String { "\(torrent.up_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.up_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    
    
    func isPaused() -> Bool { torrent.state.contains("paused") }
    
    func toggleTorrentPause() {
        haptics.impactOccurred()
        if torrent.state.contains("paused") {
            qBittorrent.resumeTorrent(hash: torrent.hash)
        } else {
            qBittorrent.pauseTorrent(hash: torrent.hash)
        }
        getTorrent()
    }
    
    func toggleSequentialDownload() {
        qBittorrent.toggleSequentialDownload(hashes: [torrent.hash])
    }
    
    func toggleFLPiecesFirst() {
        qBittorrent.toggleFLPiecesFirst(hashes: [torrent.hash])
    }
    
    
    func recheckTorrent() {
        haptics.impactOccurred()
        qBittorrent.recheckTorrent(hash: torrent.hash)
    }
    
    func reannounceTorrent() {
        haptics.impactOccurred()
        qBittorrent.reannounceTorrent(hash: torrent.hash)
    }
    
    func deleteTorrent() {
        haptics.impactOccurred()
        isDeleteAlert = true
    }
    
    func moveToTopPriority() {
        haptics.impactOccurred()
        qBittorrent.topPriorityTorrents(hashes: [torrent.hash])
    }
    
    func moveToBottomPriority() {
        haptics.impactOccurred()
        qBittorrent.bottomPriorityTorrents(hashes: [torrent.hash])
    }
    
    func increasePriority() {
        haptics.impactOccurred()
        qBittorrent.increasePriorityTorrents(hashes: [torrent.hash])
    }
    
    func decreasePriority() {
        haptics.impactOccurred()
        qBittorrent.decreasePriorityTorrents(hashes: [torrent.hash])
    }
    
    func deleteTorrent(then dismiss: DismissAction) {
        qBittorrent.deleteTorrent(hash: torrent.hash)
        dismiss()
    }
    
    func deleteTorrentWithFiles(then dismiss: DismissAction) {
        qBittorrent.deleteTorrent(hash: torrent.hash, deleteFiles: true)
        dismiss()
    }
    
    enum State {
        case resumed, paused, isPausing, isResuming
    }
}
