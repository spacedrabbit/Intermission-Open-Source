//
//  FeedPage.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/22/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

class FeedPage: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "feed_page"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let pageIdentifier: String
    
    var featuredPosts: [Post] = []
    var feedModules: [FeedModule] = []
    
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FeedPage.FieldKeys.self)
        pageIdentifier = try fields.decode(String.self, forKey: .id)
        
        try fields.resolveLinksArray(forKey: .featured_posts, decoder: decoder, callback: { [weak self] posts in
            let posts = (posts as? [Post] ?? []).removingUnpublished()
            self?.featuredPosts = posts
        })
        
        try fields.resolveLinksArray(forKey: .feed_modules, decoder: decoder, callback: { [weak self] modules in
            self?.feedModules = modules as? [FeedModule] ?? []
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case id
        case featured_posts
        case feed_modules
    }
}
