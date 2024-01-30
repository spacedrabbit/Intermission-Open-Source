//
//  Series.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

class Series: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "videoSeries"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    var videos: [Video]?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Series.FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        
        try fields.resolveLinksArray(forKey: .videos, decoder: decoder, callback: { [weak self] (videos) in
            self?.videos = videos as? [Video]
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case title, videos
    }
}
