//
//  FeedModule.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/22/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

enum FeedModuleLayout {
    case grid, horizontalScroll, hero

    init?(_ string: String) {
        let cleanString = string.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cleanString == "grid" { self = .grid }
        else if cleanString == "hero" { self = .hero }
        else if cleanString == "horizontal_scroll" { self = .horizontalScroll }
        else { return nil }
    }
}

enum FeedModuleType: Equatable {
    case tags(Tag)
    case videoSeries(Series)
    case videos([Video])
    case posts([Post])
    case unknown
    
    static let tagIdentifier = "tags"
    static let seriesIdentifier = "video_series"
    static let videosIdentifier = "videos"
    static let postsIdentifier = "posts"
    
    init(identifier: String, object: AnyObject) {
        switch identifier {
        case FeedModuleType.tagIdentifier:
            guard let tag = (object as? [Tag])?.first else {
                self = .unknown
                return
            }
            self = .tags(tag)
            
        case FeedModuleType.seriesIdentifier:
            guard let series = (object as? [Series])?.first else {
                self = .unknown
                return
            }
            self = .videoSeries(series)
            
        case FeedModuleType.videosIdentifier:
            guard let videos = object as? [Video] else {
                self = .unknown
                return
            }
            self = .videos(videos)
        
        case FeedModuleType.postsIdentifier:
            guard let posts = object as? [Post] else {
                self = .unknown
                return
            }
            self = .posts(posts.removingUnpublished())
            
        default:
            self = .unknown
        }
    }
    
    static func ==(_ lhs: FeedModuleType, _ rhs: FeedModuleType) -> Bool {
        switch (lhs, rhs) {
        case (.tags, .tags), (.videoSeries, .videoSeries),
             (.videos, .videos), (.posts, .posts),
             (.unknown, .unknown): return true
        default: return false
        }
    }
}

class FeedModule: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "feed_module"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let moduleIdentifer: String
    let moduleTitle: String
    let emphasizedWords: [String]
    let layout: FeedModuleLayout
    
    var type: FeedModuleType = .unknown
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FeedModule.FieldKeys.self)
        moduleIdentifer = try fields.decode(String.self, forKey: .identifier)
        moduleTitle = try fields.decode(String.self, forKey: .moduleTitle)
        emphasizedWords = try fields.decodeIfPresent(String.self, forKey: .emphasizedWords)?
            .components(separatedBy: ",")
            .compactMap { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) } ?? []
        let layoutString = try fields.decode(String.self, forKey: .layoutStyle)
        layout = FeedModuleLayout(layoutString) ?? .horizontalScroll
        
        let moduleTypeString = try fields.decode(String.self, forKey: .moduleType)
        try fields.resolveLinksArray(forKey: .content, decoder: decoder, callback: { [weak self] content in
            self?.type = FeedModuleType(identifier: moduleTypeString, object: content)
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case identifier = "id"
        case moduleTitle = "module_title"
        case emphasizedWords = "emphasized_words"
        case layoutStyle = "layout_style"
        case content
        case moduleType = "module_type"
    }
}
