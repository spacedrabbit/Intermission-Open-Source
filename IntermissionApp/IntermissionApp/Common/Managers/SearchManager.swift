//
//  SearchManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/4/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

/// This is a "dumb" search tool that will just pull all available posts on launch and store it for the duration of the session
/// A refreshed pull is eligible to occur once per hour
class SearchManager {
    private var allVideoEntries: [VideoHistoryEntry] = [] {
        didSet {
            let uniqueTags = Set(allVideoEntries.flatMap({ $0.tags }))
            uniqueTags.forEach { (uniqueTag: Tag) in
                let entriesWithTag = allVideoEntries.filter({ (entry: VideoHistoryEntry) -> Bool in
                    return entry.tags.contains(uniqueTag)
                })
                videoEntriesByTag.updateValue(entriesWithTag, forKey: uniqueTag)
            }
        }
    }
    private var videoEntriesByTag: [Tag : [VideoHistoryEntry]] = [:]
    
    static let shared: SearchManager = SearchManager()
    private let cacheExpirationLimit: TimeInterval = 60.0 * 60.0 // 1.0
    private var lastRetrieved: Date?
    
    private struct Keys {
        static let timestamp = "timestamp"
        static let snapshot = "snapshot"
        static let userDefaults = "com.ia.searchManager.snapshot"
    }
    
    private enum SearchError: Error {
        case cacheExpired
        case cacheNotFound
        case keysNotRecognized
        case couldNotParse
    }
    
    private init() {}
    
    static func prepare() {
        let result = shared.retrieveSnapshot()
        switch result {
        case .success(let entries):
            shared.allVideoEntries = entries
            shared.lastRetrieved = Date()
        case .failure(let error) where error == .cacheNotFound:
            retrievePosts()
        case .failure(let error) where error == .cacheExpired:
            retrievePosts()
        case .failure(let error):
            print("Error encountered preparing search manager: \(error)")
        }
    }
    
    static func retrievePostsIfNeeded(completion: @escaping ((IAResult<[VideoHistoryEntry], DisplayableError>) -> Void)) {
        let now = Date()
        guard
            let last = shared.lastRetrieved,
            now.timeIntervalSince(last) > shared.cacheExpirationLimit
        else {
            completion(.success(shared.allVideoEntries))
            return
        }
        
        let result = shared.retrieveSnapshot()
        switch result {
        case .success(let entries):
            shared.allVideoEntries = entries
            shared.lastRetrieved = now
            completion(.success(shared.allVideoEntries))
        case .failure(let error) where error == .cacheNotFound || error == .cacheExpired:
            retrievePosts(completion: completion)
        case .failure(let error):
            // TODO: better error, contact for support
            let displayError = DisplayableError(title: "We can't seem to find that...", message: "Looks like our robots have lost the table of contents for our videos. They probably just need a little time to get sorted, so why don't you try searching again in a few minutes? If things still don't work, reach out to us!", ignore: false, error: error)
            completion(.failure(displayError))
            
        }
    }
    
    static func entries(for tag: Tag) -> [VideoHistoryEntry] {
        let results = SearchManager.entries(for: [tag])
        guard
            results.count == 1,
            let entries = results.first?.value else
        { return [] }
        
        return entries
    }
    
    static func entries(for tags: [Tag]) -> [Tag : [VideoHistoryEntry]] {
        var result: [Tag : [VideoHistoryEntry]] = [:]
        tags.forEach { (tag: Tag) in
            if let entries = shared.videoEntriesByTag[tag] {
                result.updateValue(entries, forKey: tag)
            } else {
                result.updateValue([], forKey: tag)
            }
        }
        return result
    }
    
    private static func retrievePosts(completion: ((IAResult<[VideoHistoryEntry], DisplayableError>) -> Void)? = nil) {
        ContentfulService.getPosts { [weak shared] (result) in
            switch result {
            case .success(let posts):
                let entries = posts.removingUnpublished().compactMap(VideoHistoryEntry.init(post:))
                
                shared?.allVideoEntries = entries
                shared?.snapshot(with: entries)
                shared?.lastRetrieved = Date()
                completion?(.success(entries))
                
            case .failure(let error):
                print("Error retrieving posts: \(error)")
                completion?(.failure(error.displayError))
            }
        }
    }
    
    private func snapshot(with entries: [VideoHistoryEntry]) {
        do {
            let json: [String : Any] = [
                Keys.timestamp : Date().iso8601String,
                Keys.snapshot : entries.map({$0.toJSON()})
            ]
            
            let snapshotData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            UserDefaults.standard.set(snapshotData, forKey: Keys.userDefaults)
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    private func retrieveSnapshot() -> Swift.Result<[VideoHistoryEntry], SearchError> {
        guard let rawData = UserDefaults.standard.value(forKey: Keys.userDefaults) else {
            return .failure(.cacheNotFound)
        }
        
        guard let snapshotData = rawData as? Data,
            let tempJSON = try? JSONSerialization.jsonObject(with: snapshotData, options: []) as? [String : Any],
            let snapshotJSON = tempJSON
        else { return .failure(.couldNotParse) }
            
        guard let timestampString = snapshotJSON.stringValue(Keys.timestamp),
            let timestamp = Date.iso8601Formatter().date(from: timestampString),
            let snapshotBundle = snapshotJSON.anyValue(Keys.snapshot, as: Array<[String : Any]>.self)
        else { return .failure(.keysNotRecognized) }

        let now = Date()
        guard now.timeIntervalSince(timestamp) < cacheExpirationLimit else { return .failure(.cacheExpired) }
        
        let entries = snapshotBundle.compactMap { VideoHistoryEntry(json: $0) }
        return .success(entries)
    }
    
}
