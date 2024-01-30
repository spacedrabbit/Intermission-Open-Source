//
//  ImageAsset.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/19/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

// TODO: I dont like this at all, come back and change me

struct ImageAsset {

    var size: Int { return details.size }
    var width: Double { return imageInfo.width }
    var height: Double { return imageInfo.height }
    var url: URL { return assetURL }
    
    // I left the actual Asset object exposed because the images API is easier to use
    // with the asset object (Getting to the asset url is the pain)
    let asset: Asset
    private let details: Asset.FileMetadata.Details
    private let imageInfo: Asset.FileMetadata.Details.ImageInfo
    private let assetURL: URL
    
    init?(asset: Asset) {
        guard
            asset.file?.contentType == "image/jpeg",
            let details = asset.file?.details,
            let imageInfo = asset.file?.details?.imageInfo,
            let url = try? asset.url()
        else { return nil }
        
        self.asset = asset
        self.details = details
        self.imageInfo = imageInfo
        self.assetURL = url
    }

}

// TODO: I dont like this at all, come back and change me

struct ImageRequest {
    private let height: CGFloat
    private let width: CGFloat
    private let url: URL
    
    private init(url: URL, width: CGFloat = 0.0, height: CGFloat = 0.0) {
        self.url = url
        self.width = width
        self.height = height
    }
    
    static func url(_ url: URL, width: CGFloat? = nil, height: CGFloat? = nil) -> ImageRequest {
        let constructedURL: URL? = {
            var queryItems: [URLQueryItem] = []
            if let w = width { queryItems.append(URLQueryItem(name: "w", value: "\(w)"))}
            if let h = height { queryItems.append(URLQueryItem(name: "h", value: "\(h)"))}
            return url.addingQueryItems(queryItems)
        }()
        
        return ImageRequest(url: constructedURL ?? url)
    }
}
