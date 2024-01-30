//
//  DashboardRecommendedPosts.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/11/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import Alamofire

/// Basic wrapper model for an array of recommended posts to display on the dashboard
class DashboardRecommendedPosts: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "dashboard_featured"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let batchIdentifier: String
    
    var featuredPosts: [Post]?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: DashboardRecommendedPosts.FieldKeys.self)
        batchIdentifier = try fields.decode(String.self, forKey: .batchIdentifier)
        
        try fields.resolveLinksArray(forKey: .featuredPosts, decoder: decoder, callback: { [weak self] post in
            self?.featuredPosts = post as? [Post]
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case batchIdentifier = "id"
        case featuredPosts = "featured_posts"
    }
}
