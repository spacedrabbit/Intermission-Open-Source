//
//  Tag.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

final class Tag: EntryDecodable, FieldKeysQueryable, DatabaseDecodable, Hashable {
    static let contentTypeId: ContentTypeId = "tag"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let slug: String
    var category: Category?
    
    init?(json: [String : Any]) {
        guard let id = json.stringValue(FieldKeys.id.rawValue),
        let title = json.stringValue(FieldKeys.title.rawValue),
        let slug = json.stringValue(FieldKeys.slug.rawValue)
        else{ return nil }
        
        self.id = id
        self.title = title
        self.slug = slug
        
        localeCode = nil
        updatedAt = nil
        createdAt = nil
        
        // TODO: add category parsing if needed
    }
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Tag.FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        slug = try fields.decode(String.self, forKey: .slug)
        
        try fields.resolveLink(forKey: .category, decoder: decoder) { [weak self] (category) in
            self?.category = category as? Category
        }
    }
    
    enum FieldKeys: String, CodingKey {
        case id
        case title
        case slug
        case category
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.slug == rhs.slug
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
}


extension Tag: DatabaseEncodable {
    
    func toJSON() -> [String : Any] {
        return [
            Tag.FieldKeys.id.rawValue : self.id,
            Tag.FieldKeys.title.rawValue : self.title,
            Tag.FieldKeys.slug.rawValue : self.slug,
            Tag.FieldKeys.category.rawValue : self.category?.toJSON() ?? NSNull()
        ]
    }
    
}

final class Category: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "category"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let slug: String
    let order: Int
    
    init?(json: [String : Any]) {
        guard
            let id = json.stringValue(FieldKeys.id.rawValue),
            let title = json.stringValue(FieldKeys.title.rawValue),
            let slug = json.stringValue(FieldKeys.slug.rawValue),
            let order = json.intValue(FieldKeys.sortOrder.rawValue)
        else{ return nil }
        
        self.id = id
        self.title = title
        self.slug = slug
        self.order = order
        
        localeCode = nil
        updatedAt = nil
        createdAt = nil
    }
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Category.FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        slug = try fields.decode(String.self, forKey: .slug)
        order = try fields.decode(Int.self, forKey: .sortOrder)
    }
    
    enum FieldKeys: String, CodingKey {
        case id
        case title
        case slug
        case sortOrder = "sort_order"
    }
}

extension Category: DatabaseRepresentable {
    
    func toJSON() -> [String : Any] {
        return [
            Category.FieldKeys.id.rawValue : self.id,
            Category.FieldKeys.title.rawValue : self.title,
            Category.FieldKeys.slug.rawValue : self.slug,
            Category.FieldKeys.sortOrder.rawValue : self.order
        ]
    }
    
}

extension Category: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
    
}
