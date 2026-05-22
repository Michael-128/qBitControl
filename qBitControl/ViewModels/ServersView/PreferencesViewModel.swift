import Foundation
import Combine

class PreferencesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var loadFailed = false
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var showSaveAlert = false
    @Published var saveSuccess = false

    // Downloads
    @Published var savePath: String = ""
    @Published var tempPathEnabled: Bool = false
    @Published var tempPath: String = ""
    @Published var autoTmmEnabled: Bool = false
    @Published var startPausedEnabled: Bool = false
    @Published var preallocateAll: Bool = false
    @Published var incompleteFilesExt: Bool = false
    @Published var exportDir: String = ""
    @Published var exportDirFin: String = ""
    @Published var autorunEnabled: Bool = false
    @Published var autorunProgram: String = ""
    @Published var torrentContentLayout: String = "Original"
    @Published var addStoppedEnabled: Bool = false
    @Published var addToTopOfQueue: Bool = false
    @Published var torrentStopCondition: String = "None"
    @Published var excludedFileNamesEnabled: Bool = false
    @Published var excludedFileNames: String = ""
    @Published var mergeTrackers: Bool = false
    @Published var useSubcategories: Bool = false
    @Published var autorunOnTorrentAddedEnabled: Bool = false
    @Published var autorunOnTorrentAddedProgram: String = ""

    // Connection
    @Published var listenPort: String = ""
    @Published var upnpEnabled: Bool = false
    @Published var maxConnections: String = ""
    @Published var maxConnectionsPerTorrent: String = ""
    @Published var maxUploads: String = ""
    @Published var maxUploadsPerTorrent: String = ""
    @Published var ipFilterEnabled: Bool = false
    @Published var ipFilterPath: String = ""
    @Published var ipFilterTrackers: Bool = false
    @Published var bannedIPs: String = ""

    // Proxy
    @Published var proxyType: String = "None"
    @Published var proxyIp: String = ""
    @Published var proxyPort: String = ""
    @Published var proxyAuthEnabled: Bool = false
    @Published var proxyUsername: String = ""
    @Published var proxyPassword: String = ""
    @Published var proxyPeerConnections: Bool = false
    @Published var proxyTorrentsOnly: Bool = false
    @Published var proxyHostnameLookup: Bool = false
    @Published var proxyBittorrent: Bool = true
    @Published var proxyRss: Bool = false
    @Published var proxyMisc: Bool = false

    // Speed
    @Published var dlLimit: String = ""
    @Published var upLimit: String = ""
    @Published var altDlLimit: String = ""
    @Published var altUpLimit: String = ""
    @Published var schedulerEnabled: Bool = false
    @Published var schedulerDays: Int = 0
    @Published var scheduleFromHour: String = ""
    @Published var scheduleFromMin: String = ""
    @Published var scheduleToHour: String = ""
    @Published var scheduleToMin: String = ""
    @Published var limitUtpRate: Bool = false
    @Published var limitTcpOverhead: Bool = false
    @Published var limitLanPeers: Bool = false

    // BitTorrent
    @Published var bittorrentProtocol: Int = 0
    @Published var encryption: Int = 0
    @Published var anonymousMode: Bool = false
    @Published var dhtEnabled: Bool = false
    @Published var pexEnabled: Bool = false
    @Published var lsdEnabled: Bool = false
    @Published var queueingEnabled: Bool = false
    @Published var maxActiveDownloads: String = ""
    @Published var maxActiveTorrents: String = ""
    @Published var maxActiveUploads: String = ""
    @Published var maxActiveCheckingTorrents: String = ""
    @Published var dontCountSlowTorrents: Bool = false
    @Published var slowTorrentDlRateThreshold: String = ""
    @Published var slowTorrentUlRateThreshold: String = ""
    @Published var slowTorrentInactiveTimer: String = ""
    @Published var maxRatioEnabled: Bool = false
    @Published var maxRatio: String = ""
    @Published var maxRatioAct: Int = 0
    @Published var maxSeedingTimeEnabled: Bool = false
    @Published var maxSeedingTime: String = ""
    @Published var maxInactiveSeedingTimeEnabled: Bool = false
    @Published var maxInactiveSeedingTime: String = ""
    @Published var addTrackersEnabled: Bool = false
    @Published var addTrackers: String = ""
    @Published var addTrackersFromUrlEnabled: Bool = false
    @Published var addTrackersUrlList: String = ""
    @Published var reannounceWhenAddressChanged: Bool = false
    @Published var validateHttpsTrackerCertificate: Bool = false

    // RSS
    @Published var rssRefreshInterval: String = ""
    @Published var rssMaxArticlesPerFeed: String = ""
    @Published var rssAutoDownloadingEnabled: Bool = false
    @Published var rssProcessingEnabled: Bool = false
    @Published var rssDownloadRepackProperEpisodes: Bool = false
    @Published var rssSmartEpisodeFilters: String = ""

    func load() {
        isLoading = true
        loadFailed = false
        qBittorrent.getPreferences { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let prefs):
                    self?.loadFailed = false
                    self?.syncFromPreferences(prefs)
                case .failure(let error):
                    print("[Preferences] Load failed: \(error)")
                    self?.loadFailed = true
                    self?.saveError = error.localizedDescription
                }
            }
        }
    }

    private func syncFromPreferences(_ prefs: qBitPreferences) {
        // Downloads
        savePath = prefs.save_path ?? ""
        tempPathEnabled = prefs.temp_path_enabled ?? false
        tempPath = prefs.temp_path ?? ""
        autoTmmEnabled = prefs.auto_tmm_enabled ?? false
        startPausedEnabled = prefs.start_paused_enabled ?? false
        preallocateAll = prefs.preallocate_all ?? false
        incompleteFilesExt = prefs.incomplete_files_ext ?? false
        exportDir = prefs.export_dir ?? ""
        exportDirFin = prefs.export_dir_fin ?? ""
        autorunEnabled = prefs.autorun_enabled ?? false
        autorunProgram = prefs.autorun_program ?? ""
        torrentContentLayout = prefs.torrent_content_layout ?? "Original"
        addStoppedEnabled = prefs.add_stopped_enabled ?? (prefs.start_paused_enabled ?? false)
        addToTopOfQueue = prefs.add_to_top_of_queue ?? false
        torrentStopCondition = prefs.torrent_stop_condition ?? "None"
        excludedFileNamesEnabled = prefs.excluded_file_names_enabled ?? false
        excludedFileNames = prefs.excluded_file_names ?? ""
        mergeTrackers = prefs.merge_trackers ?? false
        useSubcategories = prefs.use_subcategories ?? false
        autorunOnTorrentAddedEnabled = prefs.autorun_on_torrent_added_enabled ?? false
        autorunOnTorrentAddedProgram = prefs.autorun_on_torrent_added_program ?? ""

        // Connection
        listenPort = prefs.listen_port.map { String($0) } ?? ""
        upnpEnabled = prefs.upnp ?? false
        maxConnections = prefs.max_connec.map { String($0) } ?? ""
        maxConnectionsPerTorrent = prefs.max_connec_per_torrent.map { String($0) } ?? ""
        maxUploads = prefs.max_uploads.map { String($0) } ?? ""
        maxUploadsPerTorrent = prefs.max_uploads_per_torrent.map { String($0) } ?? ""
        ipFilterEnabled = prefs.ip_filter_enabled ?? false
        ipFilterPath = prefs.ip_filter_path ?? ""
        ipFilterTrackers = prefs.ip_filter_trackers ?? false
        bannedIPs = prefs.banned_IPs ?? ""

        // Proxy
        proxyType = prefs.proxy_type ?? "None"
        proxyIp = prefs.proxy_ip ?? ""
        proxyPort = prefs.proxy_port.map { String($0) } ?? ""
        proxyAuthEnabled = prefs.proxy_auth_enabled ?? false
        proxyUsername = prefs.proxy_username ?? ""
        proxyPassword = prefs.proxy_password ?? ""
        proxyPeerConnections = prefs.proxy_peer_connections ?? false
        proxyTorrentsOnly = prefs.proxy_torrents_only ?? false
        proxyHostnameLookup = prefs.proxy_hostname_lookup ?? false
        proxyBittorrent = prefs.proxy_bittorrent ?? true
        proxyRss = prefs.proxy_rss ?? false
        proxyMisc = prefs.proxy_misc ?? false

        // Speed
        dlLimit = prefs.dl_limit.map { String($0) } ?? ""
        upLimit = prefs.up_limit.map { String($0) } ?? ""
        altDlLimit = prefs.alt_dl_limit.map { String($0) } ?? ""
        altUpLimit = prefs.alt_up_limit.map { String($0) } ?? ""
        schedulerEnabled = prefs.scheduler_enabled ?? false
        schedulerDays = prefs.scheduler_days ?? 0
        scheduleFromHour = prefs.schedule_from_hour.map { String($0) } ?? ""
        scheduleFromMin = prefs.schedule_from_min.map { String($0) } ?? ""
        scheduleToHour = prefs.schedule_to_hour.map { String($0) } ?? ""
        scheduleToMin = prefs.schedule_to_min.map { String($0) } ?? ""
        limitUtpRate = prefs.limit_utp_rate ?? false
        limitTcpOverhead = prefs.limit_tcp_overhead ?? false
        limitLanPeers = prefs.limit_lan_peers ?? false

        // BitTorrent
        bittorrentProtocol = prefs.bittorrent_protocol ?? 0
        encryption = prefs.encryption ?? 0
        anonymousMode = prefs.anonymous_mode ?? false
        dhtEnabled = prefs.dht ?? false
        pexEnabled = prefs.pex ?? false
        lsdEnabled = prefs.lsd ?? false
        queueingEnabled = prefs.queueing_enabled ?? false
        maxActiveDownloads = prefs.max_active_downloads.map { String($0) } ?? ""
        maxActiveTorrents = prefs.max_active_torrents.map { String($0) } ?? ""
        maxActiveUploads = prefs.max_active_uploads.map { String($0) } ?? ""
        maxActiveCheckingTorrents = prefs.max_active_checking_torrents.map { String($0) } ?? ""
        dontCountSlowTorrents = prefs.dont_count_slow_torrents ?? false
        slowTorrentDlRateThreshold = prefs.slow_torrent_dl_rate_threshold.map { String($0) } ?? ""
        slowTorrentUlRateThreshold = prefs.slow_torrent_ul_rate_threshold.map { String($0) } ?? ""
        slowTorrentInactiveTimer = prefs.slow_torrent_inactive_timer.map { String($0) } ?? ""
        maxRatioEnabled = prefs.max_ratio_enabled ?? false
        maxRatio = prefs.max_ratio.map { String($0) } ?? ""
        maxRatioAct = prefs.max_ratio_act ?? 0
        maxSeedingTimeEnabled = prefs.max_seeding_time_enabled ?? false
        maxSeedingTime = prefs.max_seeding_time.map { String($0) } ?? ""
        maxInactiveSeedingTimeEnabled = prefs.max_inactive_seeding_time_enabled ?? false
        maxInactiveSeedingTime = prefs.max_inactive_seeding_time.map { String($0) } ?? ""
        addTrackersEnabled = prefs.add_trackers_enabled ?? false
        addTrackers = prefs.add_trackers ?? ""
        addTrackersFromUrlEnabled = prefs.add_trackers_from_url_enabled ?? false
        addTrackersUrlList = prefs.add_trackers_url_list ?? prefs.add_trackers_url ?? ""
        reannounceWhenAddressChanged = prefs.reannounce_when_address_changed ?? false
        validateHttpsTrackerCertificate = prefs.validate_https_tracker_certificate ?? false

        // RSS
        rssRefreshInterval = prefs.rss_refresh_interval.map { String($0) } ?? ""
        rssMaxArticlesPerFeed = prefs.rss_max_articles_per_feed.map { String($0) } ?? ""
        rssAutoDownloadingEnabled = prefs.rss_auto_downloading_enabled ?? false
        rssProcessingEnabled = prefs.rss_processing_enabled ?? false
        rssDownloadRepackProperEpisodes = prefs.rss_download_repack_proper_episodes ?? false
        rssSmartEpisodeFilters = prefs.rss_smart_episode_filters ?? ""
    }

    func save(completion: @escaping (Bool) -> Void) {
        isSaving = true
        saveError = nil
        var d: [String: Any] = [:]

        // Downloads
        d["save_path"] = savePath
        d["temp_path_enabled"] = tempPathEnabled
        d["temp_path"] = tempPath
        d["auto_tmm_enabled"] = autoTmmEnabled
        d["start_paused_enabled"] = startPausedEnabled
        d["add_stopped_enabled"] = addStoppedEnabled
        d["preallocate_all"] = preallocateAll
        d["incomplete_files_ext"] = incompleteFilesExt
        d["export_dir"] = exportDir
        d["export_dir_fin"] = exportDirFin
        d["autorun_enabled"] = autorunEnabled
        d["autorun_program"] = autorunProgram
        d["torrent_content_layout"] = torrentContentLayout
        d["add_to_top_of_queue"] = addToTopOfQueue
        d["torrent_stop_condition"] = torrentStopCondition
        d["excluded_file_names_enabled"] = excludedFileNamesEnabled
        d["excluded_file_names"] = excludedFileNames
        d["merge_trackers"] = mergeTrackers
        d["use_subcategories"] = useSubcategories
        d["autorun_on_torrent_added_enabled"] = autorunOnTorrentAddedEnabled
        d["autorun_on_torrent_added_program"] = autorunOnTorrentAddedProgram

        // Connection
        if !listenPort.isEmpty, let v = Int(listenPort) { d["listen_port"] = v }
        d["upnp"] = upnpEnabled
        if !maxConnections.isEmpty, let v = Int(maxConnections) { d["max_connec"] = v }
        if !maxConnectionsPerTorrent.isEmpty, let v = Int(maxConnectionsPerTorrent) { d["max_connec_per_torrent"] = v }
        if !maxUploads.isEmpty, let v = Int(maxUploads) { d["max_uploads"] = v }
        if !maxUploadsPerTorrent.isEmpty, let v = Int(maxUploadsPerTorrent) { d["max_uploads_per_torrent"] = v }
        d["ip_filter_enabled"] = ipFilterEnabled
        d["ip_filter_path"] = ipFilterPath
        d["ip_filter_trackers"] = ipFilterTrackers
        d["banned_IPs"] = bannedIPs

        // Proxy
        d["proxy_type"] = proxyType
        d["proxy_ip"] = proxyIp
        if !proxyPort.isEmpty, let v = Int(proxyPort) { d["proxy_port"] = v }
        d["proxy_auth_enabled"] = proxyAuthEnabled
        d["proxy_username"] = proxyUsername
        d["proxy_password"] = proxyPassword
        d["proxy_peer_connections"] = proxyPeerConnections
        d["proxy_torrents_only"] = proxyTorrentsOnly
        d["proxy_hostname_lookup"] = proxyHostnameLookup
        d["proxy_bittorrent"] = proxyBittorrent
        d["proxy_rss"] = proxyRss
        d["proxy_misc"] = proxyMisc

        // Speed
        if !dlLimit.isEmpty, let v = Int(dlLimit) { d["dl_limit"] = v }
        if !upLimit.isEmpty, let v = Int(upLimit) { d["up_limit"] = v }
        if !altDlLimit.isEmpty, let v = Int(altDlLimit) { d["alt_dl_limit"] = v }
        if !altUpLimit.isEmpty, let v = Int(altUpLimit) { d["alt_up_limit"] = v }
        d["scheduler_enabled"] = schedulerEnabled
        d["scheduler_days"] = schedulerDays
        if !scheduleFromHour.isEmpty, let v = Int(scheduleFromHour) { d["schedule_from_hour"] = v }
        if !scheduleFromMin.isEmpty, let v = Int(scheduleFromMin) { d["schedule_from_min"] = v }
        if !scheduleToHour.isEmpty, let v = Int(scheduleToHour) { d["schedule_to_hour"] = v }
        if !scheduleToMin.isEmpty, let v = Int(scheduleToMin) { d["schedule_to_min"] = v }
        d["limit_utp_rate"] = limitUtpRate
        d["limit_tcp_overhead"] = limitTcpOverhead
        d["limit_lan_peers"] = limitLanPeers

        // BitTorrent
        d["bittorrent_protocol"] = bittorrentProtocol
        d["encryption"] = encryption
        d["anonymous_mode"] = anonymousMode
        d["dht"] = dhtEnabled
        d["pex"] = pexEnabled
        d["lsd"] = lsdEnabled
        d["queueing_enabled"] = queueingEnabled
        if !maxActiveDownloads.isEmpty, let v = Int(maxActiveDownloads) { d["max_active_downloads"] = v }
        if !maxActiveTorrents.isEmpty, let v = Int(maxActiveTorrents) { d["max_active_torrents"] = v }
        if !maxActiveUploads.isEmpty, let v = Int(maxActiveUploads) { d["max_active_uploads"] = v }
        if !maxActiveCheckingTorrents.isEmpty, let v = Int(maxActiveCheckingTorrents) { d["max_active_checking_torrents"] = v }
        d["dont_count_slow_torrents"] = dontCountSlowTorrents
        if !slowTorrentDlRateThreshold.isEmpty, let v = Int(slowTorrentDlRateThreshold) { d["slow_torrent_dl_rate_threshold"] = v }
        if !slowTorrentUlRateThreshold.isEmpty, let v = Int(slowTorrentUlRateThreshold) { d["slow_torrent_ul_rate_threshold"] = v }
        if !slowTorrentInactiveTimer.isEmpty, let v = Int(slowTorrentInactiveTimer) { d["slow_torrent_inactive_timer"] = v }
        d["max_ratio_enabled"] = maxRatioEnabled
        if !maxRatio.isEmpty, let v = Float(maxRatio) { d["max_ratio"] = v }
        d["max_ratio_act"] = maxRatioAct
        d["max_seeding_time_enabled"] = maxSeedingTimeEnabled
        if !maxSeedingTime.isEmpty, let v = Int(maxSeedingTime) { d["max_seeding_time"] = v }
        d["max_inactive_seeding_time_enabled"] = maxInactiveSeedingTimeEnabled
        if !maxInactiveSeedingTime.isEmpty, let v = Int(maxInactiveSeedingTime) { d["max_inactive_seeding_time"] = v }
        d["add_trackers_enabled"] = addTrackersEnabled
        d["add_trackers"] = addTrackers
        d["add_trackers_from_url_enabled"] = addTrackersFromUrlEnabled
        d["add_trackers_url_list"] = addTrackersUrlList
        d["reannounce_when_address_changed"] = reannounceWhenAddressChanged
        d["validate_https_tracker_certificate"] = validateHttpsTrackerCertificate

        // RSS
        if !rssRefreshInterval.isEmpty, let v = Int(rssRefreshInterval) { d["rss_refresh_interval"] = v }
        if !rssMaxArticlesPerFeed.isEmpty, let v = Int(rssMaxArticlesPerFeed) { d["rss_max_articles_per_feed"] = v }
        d["rss_auto_downloading_enabled"] = rssAutoDownloadingEnabled
        d["rss_processing_enabled"] = rssProcessingEnabled
        d["rss_download_repack_proper_episodes"] = rssDownloadRepackProperEpisodes
        d["rss_smart_episode_filters"] = rssSmartEpisodeFilters

        qBittorrent.setPreferences(d) { [weak self] status in
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
