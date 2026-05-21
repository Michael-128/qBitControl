import Foundation
import Combine

class PreferencesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var saveError: String?

    // Speed Limits
    @Published var dlLimit: String = ""
    @Published var upLimit: String = ""
    @Published var altDlLimit: String = ""
    @Published var altUpLimit: String = ""

    // Queueing
    @Published var queueingEnabled: Bool = false
    @Published var maxActiveDownloads: String = ""
    @Published var maxActiveTorrents: String = ""
    @Published var maxActiveUploads: String = ""

    // Scheduler
    @Published var schedulerEnabled: Bool = false
    @Published var schedulerDays: Int = 0
    @Published var scheduleFromHour: String = ""
    @Published var scheduleFromMin: String = ""
    @Published var scheduleToHour: String = ""
    @Published var scheduleToMin: String = ""

    // Ratio
    @Published var maxRatioEnabled: Bool = false
    @Published var maxRatio: String = ""

    // Auto TMM
    @Published var autoTmmEnabled: Bool = false

    // Network
    @Published var listenPort: String = ""
    @Published var upnpEnabled: Bool = false
    @Published var maxConnections: String = ""
    @Published var maxConnectionsPerTorrent: String = ""

    // DHT / PEX / LSD
    @Published var dhtEnabled: Bool = false
    @Published var pexEnabled: Bool = false
    @Published var lsdEnabled: Bool = false

    // RSS
    @Published var rssRefreshInterval: String = ""
    @Published var rssMaxArticlesPerFeed: String = ""
    @Published var rssAutoDownloadingEnabled: Bool = false

    // Downloads
    @Published var savePath: String = ""
    @Published var tempPathEnabled: Bool = false
    @Published var tempPath: String = ""
    @Published var startPausedEnabled: Bool = false
    @Published var preallocateAll: Bool = false
    @Published var incompleteFilesExt: Bool = false

    // Seeding Time
    @Published var maxSeedingTimeEnabled: Bool = false
    @Published var maxSeedingTime: String = ""

    // BitTorrent
    @Published var bittorrentProtocol: Int = 0
    @Published var encryption: Int = 0
    @Published var anonymousMode: Bool = false

    // Connection Limits
    @Published var maxUploads: String = ""
    @Published var maxUploadsPerTorrent: String = ""

    // Slow Torrents
    @Published var dontCountSlowTorrents: Bool = false
    @Published var slowTorrentDlRateThreshold: String = ""
    @Published var slowTorrentUlRateThreshold: String = ""
    @Published var slowTorrentInactiveTimer: String = ""

    func load() {
        isLoading = true
        qBittorrent.getPreferences { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let prefs):
                    self?.syncFromPreferences(prefs)
                case .failure(let error):
                    self?.saveError = error.localizedDescription
                }
            }
        }
    }

    private func syncFromPreferences(_ prefs: qBitPreferences) {
        dlLimit = prefs.dl_limit.map { String($0) } ?? ""
        upLimit = prefs.up_limit.map { String($0) } ?? ""
        altDlLimit = prefs.alt_dl_limit.map { String($0) } ?? ""
        altUpLimit = prefs.alt_up_limit.map { String($0) } ?? ""

        queueingEnabled = prefs.queueing_enabled ?? false
        maxActiveDownloads = prefs.max_active_downloads.map { String($0) } ?? ""
        maxActiveTorrents = prefs.max_active_torrents.map { String($0) } ?? ""
        maxActiveUploads = prefs.max_active_uploads.map { String($0) } ?? ""

        schedulerEnabled = prefs.scheduler_enabled ?? false
        schedulerDays = prefs.scheduler_days ?? 0
        scheduleFromHour = prefs.schedule_from_hour.map { String($0) } ?? ""
        scheduleFromMin = prefs.schedule_from_min.map { String($0) } ?? ""
        scheduleToHour = prefs.schedule_to_hour.map { String($0) } ?? ""
        scheduleToMin = prefs.schedule_to_min.map { String($0) } ?? ""

        maxRatioEnabled = prefs.max_ratio_enabled ?? false
        maxRatio = prefs.max_ratio.map { String($0) } ?? ""

        autoTmmEnabled = prefs.auto_tmm_enabled ?? false

        listenPort = prefs.listen_port.map { String($0) } ?? ""
        upnpEnabled = prefs.upnp ?? false
        maxConnections = prefs.max_connec.map { String($0) } ?? ""
        maxConnectionsPerTorrent = prefs.max_connec_per_torrent.map { String($0) } ?? ""

        dhtEnabled = prefs.dht ?? false
        pexEnabled = prefs.pex ?? false
        lsdEnabled = prefs.lsd ?? false

        rssRefreshInterval = prefs.rss_refresh_interval.map { String($0) } ?? ""
        rssMaxArticlesPerFeed = prefs.rss_max_articles_per_feed.map { String($0) } ?? ""
        rssAutoDownloadingEnabled = prefs.rss_auto_downloading_enabled ?? false

        savePath = prefs.save_path ?? ""
        tempPathEnabled = prefs.temp_path_enabled ?? false
        tempPath = prefs.temp_path ?? ""
        startPausedEnabled = prefs.start_paused_enabled ?? false
        preallocateAll = prefs.preallocate_all ?? false
        incompleteFilesExt = prefs.incomplete_files_ext ?? false

        maxSeedingTimeEnabled = prefs.max_seeding_time_enabled ?? false
        maxSeedingTime = prefs.max_seeding_time.map { String($0) } ?? ""

        bittorrentProtocol = prefs.bittorrent_protocol ?? 0
        encryption = prefs.encryption ?? 0
        anonymousMode = prefs.anonymous_mode ?? false

        maxUploads = prefs.max_uploads.map { String($0) } ?? ""
        maxUploadsPerTorrent = prefs.max_uploads_per_torrent.map { String($0) } ?? ""

        dontCountSlowTorrents = prefs.dont_count_slow_torrents ?? false
        slowTorrentDlRateThreshold = prefs.slow_torrent_dl_rate_threshold.map { String($0) } ?? ""
        slowTorrentUlRateThreshold = prefs.slow_torrent_ul_rate_threshold.map { String($0) } ?? ""
        slowTorrentInactiveTimer = prefs.slow_torrent_inactive_timer.map { String($0) } ?? ""
    }

    func save(completion: @escaping (Bool) -> Void) {
        isSaving = true
        saveError = nil

        var prefsDict: [String: Any] = [:]

        if !dlLimit.isEmpty, let v = Int(dlLimit) { prefsDict["dl_limit"] = v }
        if !upLimit.isEmpty, let v = Int(upLimit) { prefsDict["up_limit"] = v }
        if !altDlLimit.isEmpty, let v = Int(altDlLimit) { prefsDict["alt_dl_limit"] = v }
        if !altUpLimit.isEmpty, let v = Int(altUpLimit) { prefsDict["alt_up_limit"] = v }

        prefsDict["queueing_enabled"] = queueingEnabled
        if !maxActiveDownloads.isEmpty, let v = Int(maxActiveDownloads) { prefsDict["max_active_downloads"] = v }
        if !maxActiveTorrents.isEmpty, let v = Int(maxActiveTorrents) { prefsDict["max_active_torrents"] = v }
        if !maxActiveUploads.isEmpty, let v = Int(maxActiveUploads) { prefsDict["max_active_uploads"] = v }

        prefsDict["scheduler_enabled"] = schedulerEnabled
        prefsDict["scheduler_days"] = schedulerDays
        if !scheduleFromHour.isEmpty, let v = Int(scheduleFromHour) { prefsDict["schedule_from_hour"] = v }
        if !scheduleFromMin.isEmpty, let v = Int(scheduleFromMin) { prefsDict["schedule_from_min"] = v }
        if !scheduleToHour.isEmpty, let v = Int(scheduleToHour) { prefsDict["schedule_to_hour"] = v }
        if !scheduleToMin.isEmpty, let v = Int(scheduleToMin) { prefsDict["schedule_to_min"] = v }

        prefsDict["max_ratio_enabled"] = maxRatioEnabled
        if !maxRatio.isEmpty, let v = Float(maxRatio) { prefsDict["max_ratio"] = v }

        prefsDict["auto_tmm_enabled"] = autoTmmEnabled

        if !listenPort.isEmpty, let v = Int(listenPort) { prefsDict["listen_port"] = v }
        prefsDict["upnp"] = upnpEnabled
        if !maxConnections.isEmpty, let v = Int(maxConnections) { prefsDict["max_connec"] = v }
        if !maxConnectionsPerTorrent.isEmpty, let v = Int(maxConnectionsPerTorrent) { prefsDict["max_connec_per_torrent"] = v }

        prefsDict["dht"] = dhtEnabled
        prefsDict["pex"] = pexEnabled
        prefsDict["lsd"] = lsdEnabled

        if !rssRefreshInterval.isEmpty, let v = Int(rssRefreshInterval) { prefsDict["rss_refresh_interval"] = v }
        if !rssMaxArticlesPerFeed.isEmpty, let v = Int(rssMaxArticlesPerFeed) { prefsDict["rss_max_articles_per_feed"] = v }
        prefsDict["rss_auto_downloading_enabled"] = rssAutoDownloadingEnabled

        prefsDict["save_path"] = savePath
        prefsDict["temp_path_enabled"] = tempPathEnabled
        if tempPathEnabled { prefsDict["temp_path"] = tempPath }
        prefsDict["start_paused_enabled"] = startPausedEnabled
        prefsDict["preallocate_all"] = preallocateAll
        prefsDict["incomplete_files_ext"] = incompleteFilesExt

        prefsDict["max_seeding_time_enabled"] = maxSeedingTimeEnabled
        if !maxSeedingTime.isEmpty, let v = Int(maxSeedingTime) { prefsDict["max_seeding_time"] = v }

        prefsDict["bittorrent_protocol"] = bittorrentProtocol
        prefsDict["encryption"] = encryption
        prefsDict["anonymous_mode"] = anonymousMode

        if !maxUploads.isEmpty, let v = Int(maxUploads) { prefsDict["max_uploads"] = v }
        if !maxUploadsPerTorrent.isEmpty, let v = Int(maxUploadsPerTorrent) { prefsDict["max_uploads_per_torrent"] = v }

        prefsDict["dont_count_slow_torrents"] = dontCountSlowTorrents
        if !slowTorrentDlRateThreshold.isEmpty, let v = Int(slowTorrentDlRateThreshold) { prefsDict["slow_torrent_dl_rate_threshold"] = v }
        if !slowTorrentUlRateThreshold.isEmpty, let v = Int(slowTorrentUlRateThreshold) { prefsDict["slow_torrent_ul_rate_threshold"] = v }
        if !slowTorrentInactiveTimer.isEmpty, let v = Int(slowTorrentInactiveTimer) { prefsDict["slow_torrent_inactive_timer"] = v }

        qBittorrent.setPreferences(prefsDict) { [weak self] status in
            DispatchQueue.main.async {
                self?.isSaving = false
                if status == 200 {
                    completion(true)
                } else {
                    self?.saveError = "Save failed (status: \(status))"
                    completion(false)
                }
            }
        }
    }
}
