//
import SwiftUI
import Combine

class TorrentListHelperViewModel: ObservableObject {
    let defaults = UserDefaults.standard

    @Published public var torrents: [Torrent] = []

    @Published public var searchQuery: String = ""
    @Published public var sort: String = "name"
    @Published public var reverse: Bool = false
    @Published public var filter: String = "all"
    @Published public var category: String = "All"
    @Published public var tag: String = "All"

    @Published public var isTorrentAddView: Bool = false
    @Published public var isSelectionMode: Bool = false

    @Published public var selectedTorrents: Set<Torrent> = Set()

    @Published public var filteredTorrents: [Torrent] = []

    @Published var scenePhase: ScenePhase = .active
    @Published var isDeleteAlert: Bool = false
    var hash = ""

    private var cancellable: AnyCancellable?

    init() {}

    func updateFilteredTorrents() {
        filteredTorrents = getFilteredTorrents(torrents: torrents)
    }

    private func applySort(_ input: [Torrent]) -> [Torrent] {
        var result = input

        if filter != "all" {
            result = result.filter { torrent in
                let state = qBittorrent.getState(state: torrent.state).lowercased()
                switch filter {
                case "downloading": return state.contains("download")
                case "seeding": return state.contains("upload") || state.contains("seed")
                case "completed": return torrent.progress >= 1.0
                case "paused": return state.contains("pause")
                case "active": return torrent.dlspeed > 0 || torrent.upspeed > 0
                case "inactive": return torrent.dlspeed == 0 && torrent.upspeed == 0
                case "errored": return state.contains("error")
                default: return true
                }
            }
        }

        if category != "All" {
            result = result.filter { $0.category == category }
        }
        if tag != "All" {
            result = result.filter { $0.tags.contains(tag) }
        }

        switch sort {
        case "name": result.sort { reverse ? $0.name > $1.name : $0.name < $1.name }
        case "size": result.sort { reverse ? $0.size > $1.size : $0.size < $1.size }
        case "progress": result.sort { reverse ? $0.progress > $1.progress : $0.progress < $1.progress }
        case "dlspeed": result.sort { reverse ? $0.dlspeed > $1.dlspeed : $0.dlspeed < $1.dlspeed }
        case "upspeed": result.sort { reverse ? $0.upspeed > $1.upspeed : $0.upspeed < $1.upspeed }
        case "priority": result = getTorrentsSortedByPriority(torrents: result)
        case "added_on": result.sort { reverse ? $0.added_on > $1.added_on : $0.added_on < $1.added_on }
        case "ratio": result.sort { reverse ? $0.ratio > $1.ratio : $0.ratio < $1.ratio }
        default: break
        }

        return result
    }

    func getTorrents() {
        if scenePhase != .active || isTorrentAddView || isSelectionMode { return }
        let allTorrents = qBitData.shared.sortedTorrents
        torrents = allTorrents
        updateFilteredTorrents()
    }

    func getTorrentsSortedByPriority(torrents: [Torrent]) -> [Torrent] {
        return torrents.sorted(by: {
            tor1, tor2 in

            if(reverse) {
                if(tor2.priority <= 0) { return false }
                if(tor1.priority < tor2.priority) { return false }
                return true;
            } else {
                if(tor2.priority <= 0) { return true }
                if(tor1.priority < tor2.priority) { return true; }
                return false;
            }
        })
    }

    func getFilteredTorrents(torrents: [Torrent]) -> [Torrent] {
        let sorted = applySort(torrents)
        if searchQuery.isEmpty { return sorted }
        return sorted.filter { torrent in torrent.name.lowercased().contains(searchQuery.lowercased()) }
    }

    func startTimer() {
        stopTimer()
        cancellable = qBitData.shared.$sortedTorrents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getTorrents()
            }
    }

    func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
    }

    func getInitialTorrents() {
        reverse = defaults.bool(forKey: "reverse")
        sort = defaults.string(forKey: "sort") ?? sort
        filter = defaults.string(forKey: "filter") ?? filter

        getTorrents()
        startTimer()
    }

    func deleteTorrent(torrent: Torrent) {
        self.hash = torrent.hash
        isDeleteAlert.toggle()
    }
}
