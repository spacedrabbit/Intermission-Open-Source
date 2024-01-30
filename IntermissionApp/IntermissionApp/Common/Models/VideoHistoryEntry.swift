//
//  VideoHistoryEntry.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - VideoHistoryEntry -

/**
 Used to represent either a watched video event or a favorited video
 */
struct VideoHistoryEntry {
    let postId: String
    let videoId: String
    let postTitle: String
    let thumbnailURL: URL
    let videoURL: URL?
    let durationSeconds: Int
    var tags: [Tag] = []
    
    var lastDateWatched: Date?
    var dateFavorited: Date?
    var datesFinished: [Date] = []
    var secondsWatched: Int?
    
    var progress: CGFloat {
        guard let secondsFromLastWatched = secondsWatched else { return 0.0 }
        return CGFloat(secondsFromLastWatched) / max(1.0, CGFloat(durationSeconds))
    }
    
    init?(post: Post) {
        guard let video = post.video else { return nil }
        
        self.postId = post.id
        self.videoId = video.id
        self.postTitle = post.title
        self.thumbnailURL = video.thumbnailURL
        self.videoURL = video.url
        self.durationSeconds = Int(video.duration)

        self.secondsWatched = nil
        self.lastDateWatched = nil
        self.dateFavorited = nil
        self.datesFinished = []
        
        if let tags = post.tags {
            self.tags = tags
        }
    }
    
    mutating func update(secondsWatched seconds: Int) {
        guard seconds > 0 else { return }
        secondsWatched = min(durationSeconds, max(0, seconds))
        
        let now = Date()
        lastDateWatched = now
        
        // If there's only 5% of the total time left in the video, we consider the video "watched"
        if progress >= 0.95 {
            datesFinished.append(now)
        }
    }
    
    mutating func setFavorite(_ favorite: Bool) {
        self.dateFavorited = favorite ? Date() : nil
    }
    
    struct Keys {
        static let postId = "post_id"
        static let videoId = "video_id"
        static let videoURL = "video_url"
        static let postTitle = "post_title"
        static let thumbnailURL = "thumbnail_url"
        static let durationSeconds = "duration_seconds"
        static let lastDateWatched = "last_date_watched"
        static let dateFavorited = "date_favorited"
        static let timestamp = "timestamp"
        static let secondsWatched = "seconds_watched"
        static let finishedWatching = "finished_watching"
        static let tags = "tags"
    }
}

// MARK: - DatabaseRepresentable -

extension VideoHistoryEntry: DatabaseRepresentable {
    
    init?(json: [String : Any]) {
        guard
            let postId  = json.stringValue(Keys.postId),
            let videoId = json.stringValue(Keys.videoId),
            let postTitle = json.stringValue(Keys.postTitle),
            let thumbnail = json.urlValue(Keys.thumbnailURL),
            let duration = json.intValue(Keys.durationSeconds)
        else { return nil }
        
        self.postId = postId
        self.videoId = videoId
        self.postTitle = postTitle
        self.thumbnailURL = thumbnail
        self.durationSeconds = duration
        
        self.lastDateWatched = json.dateValue(Keys.lastDateWatched)
        self.secondsWatched = json.intValue(Keys.secondsWatched)
        self.dateFavorited = json.dateValue(Keys.dateFavorited)
        
        // there will always be a url going forward, but we will break backwards compatibility
        // if we make it a pre-req to deserialize because older forms of the model don't have this
        // k/v pair for video url
        self.videoURL = json.urlValue(Keys.videoURL)
        
        if let watched = json[Keys.finishedWatching] as? [String] {
            self.datesFinished = watched.compactMap({ $0.iso8601StringDate })
        }
        
        if let tagDictionaries = json[Keys.tags] as? [[String : Any]] {
            self.tags = tagDictionaries.compactMap(Tag.init(json:))
        }
    }
    
    func toJSON() -> [String : Any] {
        return [
            VideoHistoryEntry.Keys.postId : self.postId,
            VideoHistoryEntry.Keys.postTitle: self.postTitle,
            VideoHistoryEntry.Keys.videoId: self.videoId,
            VideoHistoryEntry.Keys.thumbnailURL : self.thumbnailURL.absoluteString,
            VideoHistoryEntry.Keys.videoURL : self.videoURL?.absoluteString ?? NSNull(),
            VideoHistoryEntry.Keys.durationSeconds : self.durationSeconds,
            VideoHistoryEntry.Keys.lastDateWatched : self.lastDateWatched?.iso8601String ?? NSNull(),
            VideoHistoryEntry.Keys.dateFavorited : self.dateFavorited?.iso8601String ?? NSNull(),
            VideoHistoryEntry.Keys.secondsWatched : self.secondsWatched ?? NSNull(),
            VideoHistoryEntry.Keys.finishedWatching : self.datesFinished.map { $0.iso8601String },
            VideoHistoryEntry.Keys.tags : self.tags.map { $0.toJSON() }
        ]
    }
}

extension VideoHistoryEntry: Hashable {
    
}

extension VideoHistoryEntry {
    
    var playbackUrl: URL? {
        return CloudinaryManager.cloudinaryUrl(from: self)
    }
    
}
