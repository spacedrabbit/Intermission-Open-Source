//
//  File.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

// NOTE: to be able to use [weak self] in link resolution callbacks, this has to be a class
/** Represents a "Post" which includes everything that would be displayed in it, a Video, Tags, Author etc.
 */
class Post: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "post"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let subscriberOnly: Bool
    let publishDate: Date?
    
    var description: RichTextDocument?
    var author: Author?
    var video: Video?
    var tags: [Tag]?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Post.FieldKeys.self)
        
        title = try fields.decode(String.self, forKey: .title)
        subscriberOnly = try fields.decode(Bool.self, forKey: .subscriberOnly)
        publishDate = try fields.decode(Date.self, forKey: .publishDate)
        description = try fields.decodeIfPresent(RichTextDocument.self, forKey: .markdownDescription)
        
        try fields.resolveLink(forKey: .author, decoder: decoder, callback: { [weak self] (author) in
            self?.author = author as? Author
        })
        
        try fields.resolveLink(forKey: .video, decoder: decoder, callback: { [weak self] (video) in
            self?.video = video as? Video
        })
        
        try fields.resolveLinksArray(forKey: .tags, decoder: decoder, callback: { [weak self] (tags) in
            self?.tags = tags as? [Tag]
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case title, tags, author, video
        case subscriberOnly = "subscriber_only"
        case publishDate = "publish_date"
        case markdownDescription = "markdown_description"
    }
    
    // MARK: - Helpers -
    
    /// A Post is considered "new" if it was published in the last 2 weeks.
    var isNew: Bool {
        if let publishDate = self.publishDate,
            let twoWeeksAfterPublish = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 16, to: publishDate, wrappingComponents: false),
            Calendar.autoupdatingCurrent.compare(publishDate, to: twoWeeksAfterPublish, toGranularity: .minute) == .orderedAscending {
            let today = Date()
            
            return (publishDate...twoWeeksAfterPublish).contains(today)
        }
        return false
    }
    
    /// A Post isDisplayable if it's publish date is today or further in the past.
    var isDisplayable: Bool {
        if let publishDate = self.publishDate {
            let comparisonResult = Calendar.autoupdatingCurrent.compare(Date(), to: publishDate, toGranularity: .day)
            return comparisonResult == .orderedSame || comparisonResult == .orderedDescending
        }
        
        return false // there should always be a publish date
    }
}

extension Array where Element == Post {
    
    func removingUnpublished() -> [Post] {
        return self.filter({ $0.isDisplayable })
    }
    
    mutating func removeUnpublished() {
        self.removeAll(where: { !$0.isDisplayable })
    }
}
