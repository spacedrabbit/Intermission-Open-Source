//
//  VideoHistoryManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/11/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum VideoHistoryUpdateType {
    case added, modified, removed, error
    
    init(documentChangeType: DocumentChangeType) {
        switch documentChangeType {
        case .added: self = .added
        case .modified: self = .modified
        case .removed: self = .removed
        default: self = .error
        }
    }
}

/** Used to track changes to a User's video viewing history
 
 - Note: It is required to call `configure(user:)` on logging a user in for this to work properly
 - Note: Call `teardown` on logging a user out
 */
class VideoHistoryManager {
    static let shared = VideoHistoryManager()
    
    /// Represents a user's video history as it is stored in the DB
    private(set) var userVideoHistory: [VideoHistoryEntry] = []
    
    /// Represents a user's video history as a chronologically ordered array of videos. This is simply a list of
    /// VideoHistoryEntry in the order they were watched in -- each entry doesn't have a record of the date it was
    /// watched, so this is just used to populate simple counts and lists of videos for a user's history
    private(set) var orderedUserVideoHistory: [VideoHistoryEntry] = []
    
    private var streaks: [[Date]] = []
    private var dateMap: [(String, Date)] = []
    
    /// Represents video streaks. Each outer array represents a video streak, where a value of 1 means it should be counted towards
    /// the current streak, and a value of 0 means it can be ignore. Each element of an inner array represents a video that was
    private var streakCounter: [[Int]] = []
    
    private var videoHistoryListener: Listener?
    private var videoHistoryUpdateHandler: ((IAResult<QuerySnapshot, DatabaseError>) -> Void)?
    
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    private init() {}
    
    // MARK: - Configure/Teardown
    
    /// Use this method to beging tracking changes to a user's history. You can call this multiple times, but you need to call this at least once before it will work.
    static func configure(user: User) {
        // Remove old listeners and update blocks if the configure method has been called before.
        if let _ = shared.videoHistoryListener, let _ = shared.videoHistoryUpdateHandler {
//            print("\n\nVideo History manager was previously setup, tearing down first\n\n")
            teardown()
        }
//        print("\n\nInitializing video history manager with user: \(user)\n\n")
        shared.initialize(with: user)
    }
    
    /// Call this function when logging out a user
    static func teardown() {
        shared.videoHistoryListener?.remove()
        shared.videoHistoryListener = nil
        shared.videoHistoryUpdateHandler = nil
        
        shared.userVideoHistory = []
        shared.streaks = []
        shared.dateMap = []
        shared.orderedUserVideoHistory = []
    }
    
    /// Returns the last video watched, regardless if it was finished
    static var lastVideoInHistory: VideoHistoryEntry? {
        return shared.userVideoHistory.first
    }
    
    static var numberOfVideosWatched: Int {
        return shared.orderedUserVideoHistory.count
    }
    
    static var totalMinutesWatched: Int {
        let secondsWatched = shared.orderedUserVideoHistory.reduce(0, { (totalMinutes, entry) -> Int in
            return totalMinutes + entry.durationSeconds
        })
        
        return secondsWatched / 60
    }
    
    /// Calculates the current streak by checking if consecutive dates in the (ordered) shared.dateMap
    /// are within a day of each other. If they are, it is represented by a value of 1. If consecutive items
    /// in the dateMap are in the same date, that is represented by a 0. If consecutive values are over a day a part
    /// then a new "streak" group is started.
    /// Each of these streak groups (an array of 1's and 0's) is then added to get the current length of a streak
    static var currentStreak: Int {
        var allStreaks: [[Int]] = []
        var currentStreak: [Int] = []
        
        var iterator = shared.dateMap.makeIterator()
        var moreRecentDate = iterator.next()
        var moreDistantDate = iterator.next()
        
        // Iterate over all of our (string, date) tuples in the dateMap until we've exhausted all elements
        while moreDistantDate != nil {
            if currentStreak.isEmpty { currentStreak.append(1) }
            
            if let recent = moreRecentDate, let distant = moreDistantDate {
                if shared.calendar.isDate(distant.1, inSameDayAs: recent.1) {
                    currentStreak.append(0)
                } else if shared.calendar.isDate(distant.1, theDayBefore: recent.1) == true {
                    currentStreak.append(1)
                } else {
                    allStreaks.append(currentStreak)
                    currentStreak.removeAll()
                }
            }
            
            moreRecentDate = moreDistantDate
            moreDistantDate = iterator.next()
            
            // We're going to break out of the while loop when this happens, so perform any clean up
            if moreDistantDate == nil {
                allStreaks.append(currentStreak)
            }
        }
        
        if let current = allStreaks.first, let lastWatched = shared.dateMap.first {
            // If the last date in our most recent streak is within today or yesterday, we can consider
            // being in the current streak.
            // Otherwise, our current streak is 0 as there is greater than a day difference.
            return shared.calendar.isDateInToday(lastWatched.1) || shared.calendar.isDateInYesterday(lastWatched.1)
                ? current.reduce(0, +)
                : 0
        }
        return 0
    }
    
    static var longestStreak: Int {
        var allStreaks: [[Int]] = []
        var currentStreak: [Int] = []
        
        var iterator = shared.dateMap.makeIterator()
        var moreRecentDate = iterator.next()
        var moreDistantDate = iterator.next()
        
        while moreDistantDate != nil {
            if currentStreak.isEmpty { currentStreak.append(1) }
            
            if let recent = moreRecentDate, let distant = moreDistantDate {
                if shared.calendar.isDate(distant.1, inSameDayAs: recent.1) {
                    currentStreak.append(0)
                } else if shared.calendar.isDate(distant.1, theDayBefore: recent.1) == true {
                    currentStreak.append(1)
                } else {
                    allStreaks.append(currentStreak)
                    currentStreak.removeAll()
                }
            }
            
            moreRecentDate = moreDistantDate
            moreDistantDate = iterator.next()
            
            // We're going to break out of the while loop when this happens, so perform any clean up
            if moreDistantDate == nil {
                allStreaks.append(currentStreak)
            }
        }
        
        return allStreaks.map { $0.reduce(0, +) }.max() ?? 0
    }
    
    static var mostWatchVideo: VideoHistoryEntry? {
        var watchedCount: Int = 0
        var mostWatched: VideoHistoryEntry? = nil
        shared.userVideoHistory.forEach { (entry) in
            if entry.datesFinished.count > watchedCount {
                mostWatched = entry
                watchedCount = entry.datesFinished.count
            }
        }
        return mostWatched
    }
    
    static func entry(for post: Post) -> VideoHistoryEntry? {
        let entry = shared.userVideoHistory.first(where: { (entry: VideoHistoryEntry) -> Bool in
            entry.postId == post.id
        })
        
        return validate(entry) ? entry : nil
    }
    
    /* Added this check in because there was a bug with how entries were being added/updated via firebase.
       Now, if validation isn't passed (as determined by the prescence of a video URL -- missing it was the source
       of the bug) then we force the creation of a new VideoHistoryEntry from a post on VDP's
     */
    private static func validate(_ entry: VideoHistoryEntry?) -> Bool {
        guard let entry = entry else { return false }
        return entry.videoURL != nil
    }
    
    // MARK: - Initializers
    
    /// Initializes the updateHandle that fires on video history changes and initializes the listener to keep observations alive
    private func initialize(with user: User) {
        
        // Setup the handler that will send out notifications for video-history-related events
        videoHistoryUpdateHandler = { [weak self] result in
            switch result {
            case .success(let snapshot):
                
                // Update our singleton's video history
                let videoEntries = snapshot.documents
                    .map{ $0.data() }
                    .compactMap(VideoHistoryEntry.init(json:))
                
                self?.orderedUserVideoHistory = VideoHistoryManager.buildOrderedJourney(from: videoEntries)
                self?.userVideoHistory = videoEntries

                // Get our changes organized by type, then let interested observers know of the changes
                let changesDict: [DocumentChangeType : [DocumentChange]] = Dictionary(grouping: snapshot.documentChanges, by: { $0.type })
                changesDict.forEach({ (key, value) in
                    
                    // It's very important to ignore cached changes. See same are in FavoritesManager for details
                    let videoEntries = value
                        .filter({ $0.document.exists && !$0.document.metadata.isFromCache })
                        .map({ $0.document.data() })
                        .compactMap(VideoHistoryEntry.init(json:))
                    
                    guard videoEntries.count > 0 else { return }
                    self?.notifiyObservers(event: VideoHistoryUpdateType(documentChangeType: key), videoEntries: videoEntries)
                })
                
            case .failure(let error):
                print("Error occured: \n\n\(error)")
                self?.notifiyObservers(event: .error, videoEntries: [], error: error.displayError)
            }
        }
        
        // Get the our listener ready to receive all event changes to the user's video history
        guard let updateBlock = videoHistoryUpdateHandler else { return }
        videoHistoryListener = DatabaseService.videoHistoryListener(for: user, trackingUpdatesWith: updateBlock)
    }
    
    /// Takes an array of [VideoHistoryEntry] from the DB and orders videos by dates watched
    static func buildOrderedJourney(from entries: [VideoHistoryEntry]) -> [VideoHistoryEntry] {
        // An array of (postId, date watched), sorted by more recent first
        let sortedDateTuples: [(String, Date)] = entries
            .map { (entry) in
                return entry.datesFinished.map ({ (date)  in
                    return (entry.videoId, date)
                })
            }.flatMap({ $0 })
            .sorted (by: { (a, b) -> Bool in
                a.1 > b.1
            })
        
        // Ok, this is a side effect, but let's just not deal with that anti-pattern for now
        shared.dateMap = sortedDateTuples
        
        return sortedDateTuples.compactMap({ (videoID, date) -> VideoHistoryEntry? in
            return entries.first(where: { $0.videoId == videoID })
        })
    }
    
    // MARK: - Notifications
    
    /** Notifies observers of changes to the VideoHistory DB. A userAdded event usually is fired on first launch/notificatin setup.
     A modified event happens when a change occured on the DB. A removed event indicates that a favorite was removed. And an error event
     indicates that there was a problem observing the favorites change
     
     */
    private func notifiyObservers(event: VideoHistoryUpdateType, videoEntries: [VideoHistoryEntry], error: DisplayableError? = nil) {
        switch event {
        case .added:
            NotificationCenter.default.post(name: .userAddedVideoToHistory, object: nil,
                                            userInfo: [ UserHistoryNotificationKey.type : event,
                                                        UserHistoryNotificationKey.videoHistory : videoEntries])
            
        case .modified:
            NotificationCenter.default.post(name: .userUpdatedVideoHistory, object: nil,
                                            userInfo: [ UserHistoryNotificationKey.type : event,
                                                        UserHistoryNotificationKey.videoHistory : videoEntries])
            
        case .removed:
            NotificationCenter.default.post(name: .userRemoveVideoHistory, object: nil,
                                            userInfo: [ UserHistoryNotificationKey.type : event,
                                                        UserHistoryNotificationKey.videoHistory : videoEntries])
            
        case .error:
            NotificationCenter.default.post(name: .userVideoHistoryErrored, object: nil,
                                            userInfo: [ UserHistoryNotificationKey.type : event,
                                                        UserHistoryNotificationKey.error : error as Any])
        }
    }
}

struct UserHistoryNotificationKey {
    static let type = "com.ia.history.updateTypeKey"
    static let videoHistory = "com.ia.history.videoHistoryEntryKey"
    static let error = "com.ia.history.errorKey"
}

extension Notification.Name {
    static let userAddedVideoToHistory = Notification.Name(rawValue: "com.ia.historyManager.userAddedToVideoHistory")
    static let userUpdatedVideoHistory = Notification.Name(rawValue: "com.ia.historyManager.userUpdatedVideoHistory")
    static let userRemoveVideoHistory = Notification.Name(rawValue: "com.ia.historyManager.userRemovedFromVideoHistory")
    static let userVideoHistoryErrored = Notification.Name(rawValue: "com.ia.historyManager.error")
}
