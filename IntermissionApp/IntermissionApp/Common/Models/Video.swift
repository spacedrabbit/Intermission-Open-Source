//
//  Video.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

/** Represents a specific video and it's metadata.
 */
class Video: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "video"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let description: String?
    let url: URL
    let thumbnailURL: URL
    let durationMinutes: Int
    let durationSeconds: Int
    
    var series: [Series]?
    
    var duration: TimeInterval {
        return TimeInterval((durationMinutes * 60) + durationSeconds)
    }
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Video.FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        description = try fields.decodeIfPresent(String.self, forKey: .description)
        url = try fields.decode(URL.self, forKey: .video_url)
        thumbnailURL = try fields.decode(URL.self, forKey: .thumbnail)
        durationMinutes = try fields.decode(Int.self, forKey: .duration_minutes)
        durationSeconds = try fields.decode(Int.self, forKey: .duration_seconds)
        
        try fields.resolveLinksArray(forKey: .series, decoder: decoder, callback: { [weak self] (series) in
            self?.series = series as? [Series]
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case title, description, video_url,
        thumbnail, duration_minutes, duration_seconds, series
    }
}

// MARK: - ModuleDisplayable -

extension Video: ModuleDisplayable {
    
    var displayImage: UIImage? { return nil }
    var displayImageURL: URL? { return self.thumbnailURL }
    var titleText: String? { return self.title }
    var subtitleText: String? { return Int(duration).minuteString() }
    
}

// MARK - DatabaseRepresentable -

//extension Video: DatabaseEncodable {
//
//    func toJSON() -> [String : Any] {
//        return VideoHistoryEntry(video: self).toJSON()
//    }
//}
