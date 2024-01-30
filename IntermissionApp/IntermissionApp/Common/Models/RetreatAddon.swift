//
//  RetreatAddon.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/19/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

class RetreatAddon: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "retreat_addon"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let name: String
    let price: Double
    let description: RichTextDocument
    let slug: String
    var displayImage: Asset?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: RetreatAddon.FieldKeys.self)
        name = try fields.decode(String.self, forKey: .name)
        price = try fields.decode(Double.self, forKey: .price)
        description = try fields.decode(RichTextDocument.self, forKey: .description)
        slug = try fields.decode(String.self, forKey: .slug)
        
        try fields.resolveLink(forKey: .displayImage, decoder: decoder, callback: { [weak self] (image) in
            self?.displayImage = image as? Asset
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case name, price, description, slug
        case displayImage = "display_image"
    }
}
