//
//  Keys.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation

struct Keys {
    struct Contentful {
        struct master {
            static let environmentId: String = ""
            static let spaceId: String = ""
            static let contentDeliveryToken = ""
            // Preview unpublished content using this API (i.e. content with “Draft” status)
            static let contentPreviewToken = ""
        }
    }
}

struct Flags {
    static let shouldDisplayShop = false
    static let enableFacebookDisconnect = false
    static let postsAreShareable = false 
}
