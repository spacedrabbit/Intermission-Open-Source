//
//  Credits.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import UIKit

/// Contains all data needed to display in the acknowledgements page
struct Acknowledgements: Codable {
    let patrons: [Supporter]
    let services: [Supporter]
    let pods: [Pod]
}

/// URL and Logo for a Social platform
struct SocialLink: Codable {
    let type: Social
    let url: URL
}

/// Information related to a CocoaPod library
struct Pod: Codable {
    let name: String
    let link: SocialLink
    
    enum CodingKeys: String, CodingKey {
        case name, link = "social"
    }
}

/// Information related to an entity that helped build this app in some way
struct Supporter: Codable {
    let name: String
    let website: URL
    let imageUrl: URL?
    let imageName: String?
    let description: String
    let links: [SocialLink]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        website = try container.decode(URL.self, forKey: .website)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try? container.decode(URL.self, forKey: .imageUrl)
        imageName = try? container.decode(String.self, forKey: .imageName)
        links = try container.decode([SocialLink].self, forKey: .links)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, website, description,
        imageUrl = "image_url",
        imageName = "image_name",
        links = "social"
    }
}

/// Possible Social link values along with their associated icons
enum Social: String, Codable {
    case facebook, twitter, instagram, github, website
    
    var image: UIImage? {
        switch self {
        case .facebook: return Icon.Social.facebook.image
        case .twitter: return Icon.Social.twitter.image
        case .instagram: return Icon.Social.instagram.image
        case .github: return Icon.Social.github.image
        case .website: return Icon.Social.website.image
        }
    }
    
    var highlightImage: UIImage? {
        switch self {
        case .facebook: return Icon.Social.facebook.highlightImage
        case .twitter: return Icon.Social.twitter.highlightImage
        case .instagram: return Icon.Social.instagram.highlightImage
        case .github: return Icon.Social.github.highlightImage
        case .website: return Icon.Social.website.highlightImage
        }
    }
    
    var lightImage: UIImage? {
        switch self {
        case .facebook: return nil
        case .twitter: return nil
        case .instagram: return nil
        case .github: return Icon.Social.github.lightImage
        case .website: return nil
        }
    }
}

