//
//  TorrentFormatter.swift
//  qBitControl
//

import Foundation
import SwiftUI

protocol TorrentFormatting {
    func getState(state: String) -> String
    func getStateIcon(state: String) -> String
    func getStateColor(state: String) -> Color
    func getFormatedSize(size: Int64) -> String
    func getFormatedSize(size: Int) -> String
    func getFormatedDate(date: Int) -> String
    func getFormattedTime(time: Int) -> String
}

struct TorrentFormatter: TorrentFormatting {
    func getState(state: String) -> String {
        switch state {
        case "error":
            return "Error"
        case "missingFiles":
            return "Missing Files"
        case "uploading":
            return "Seeding"
        case "pausedUP", "stoppedUP":
            return "Paused"
        case "queuedUP":
            return "Queued"
        case "stalledUP":
            return "Seeding"
        case "checkingUP":
            return "Checking"
        case "forcedUP":
            return "Forced Seeding"
        case "allocating":
            return "Allocating space"
        case "downloading":
            return "Downloading"
        case "metaDL":
            return "Downloading"
        case "pausedDL", "stoppedDL":
            return "Paused"
        case "queuedDL":
            return "Queued"
        case "stalledDL":
            return "Downloading"
        case "checkingDL":
            return "Checking"
        case "forcedDL":
            return "Forced Download"
        case "checkingResumeData":
            return "Resuming"
        case "moving":
            return "Moving"
        default:
            return "Unknown State"
        }
    }
    
    func getStateIcon(state: String) -> String {
        let errorIcon = "multiply.circle"
        let downloadIcon = "arrow.down.circle"
        let uploadIcon = "arrow.up.circle"
        let checkingIcon = "gearshape.circle"
        let pauseIcon = "pause.circle"
        let metadataDownloadIcon = "info.circle"
        let movingIcon = "folder.circle"
        let queuedIcon = "clock"
        
        switch state {
        case "error":
            return errorIcon
        case "missingFiles":
            return errorIcon
        case "uploading":
            return uploadIcon
        case "pausedUP", "stoppedUP":
            return pauseIcon
        case "queuedUP":
            return queuedIcon
        case "stalledUP":
            return uploadIcon
        case "checkingUP":
            return checkingIcon
        case "forcedUP":
            return uploadIcon
        case "allocating":
            return checkingIcon
        case "downloading":
            return downloadIcon
        case "metaDL":
            return metadataDownloadIcon
        case "pausedDL", "stoppedDL":
            return pauseIcon
        case "queuedDL":
            return queuedIcon
        case "stalledDL":
            return downloadIcon
        case "checkingDL":
            return checkingIcon
        case "forcedDL":
            return downloadIcon
        case "checkingResumeData":
            return checkingIcon
        case "moving":
            return movingIcon
        default:
            return errorIcon
        }
    }
    
    func getStateColor(state: String) -> Color {
        let errorColor = Color.red
        let pausedColor = Color.yellow
        let seedingColor = Color.blue
        let downloadingColor = Color.green
        let checkingColor = pausedColor
        let movingColor = pausedColor
        
        switch state {
        case "error":
            return errorColor
        case "missingFiles":
            return errorColor
        case "uploading":
            return seedingColor
        case "pausedUP", "stoppedUP":
            return pausedColor
        case "queuedUP":
            return pausedColor
        case "stalledUP":
            return seedingColor
        case "checkingUP":
            return checkingColor
        case "forcedUP":
            return seedingColor
        case "allocating":
            return checkingColor
        case "downloading":
            return downloadingColor
        case "metaDL":
            return downloadingColor
        case "pausedDL", "stoppedDL":
            return pausedColor
        case "queuedDL":
            return pausedColor
        case "stalledDL":
            return downloadingColor
        case "checkingDL":
            return checkingColor
        case "forcedDL":
            return downloadingColor
        case "checkingResumeData":
            return checkingColor
        case "moving":
            return movingColor
        default:
            return errorColor
        }
    }
    
    func getFormatedSize(size: Int64) -> String {
        let formater = ByteCountFormatter()
        formater.isAdaptive = true
        formater.countStyle = ByteCountFormatter.CountStyle.binary
        return formater.string(fromByteCount: size)
    }
    
    func getFormatedSize(size: Int) -> String {
        let formater = ByteCountFormatter()
        formater.isAdaptive = true
        formater.countStyle = ByteCountFormatter.CountStyle.binary
        return formater.string(fromByteCount: Int64(size))
    }
    
    func getFormatedDate(date: Int) -> String {
        let fullDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: fullDate)
    }
    
    func getFormattedTime(time: Int) -> String {
        let days = time / (24 * 60 * 60)
        let hours = (time / (60 * 60)) % 24
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        var components: [String] = []
        
        if days > 0 {
            components.append("\(days)d")
            components.append("\(hours)h")
        } else if hours > 0 {
            components.append("\(hours)h")
            components.append("\(minutes)m")
        } else if minutes > 0 {
            components.append("\(minutes)m")
            components.append("\(seconds)s")
        } else {
            components.append("\(seconds)s")
        }
        
        return components.joined(separator: " ")
    }
}
