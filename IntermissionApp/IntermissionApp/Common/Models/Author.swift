//
//  Author.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

// NOTE: to be able to use [weak self] in link resolution callbacks, this has to be a class
class Author: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "author"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let name: String
    let description: String
    let twitter: URL
    let instagram: URL
    let email: String?
    let identifier: String

    var image: Asset?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Author.FieldKeys.self)
        name = try fields.decode(String.self, forKey: .name)
        description = try fields.decode(String.self, forKey: .description)
        twitter = try fields.decode(URL.self, forKey: .twitter)
        instagram = try fields.decode(URL.self, forKey: .instagram)
        email = try fields.decodeIfPresent(String.self, forKey: .email)
        identifier = try fields.decode(String.self, forKey: .identifier)
        
        try fields.resolveLink(forKey: .imageUrl, decoder: decoder, callback: { [weak self] (image) in
            self?.image = image as? Asset
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case name = "author_name"
        case description = "author_description"
        case identifier = "author_slug"
        case imageUrl = "author_image"
        case twitter, instagram, email
    }
}
