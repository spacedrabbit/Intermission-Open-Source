//
//  ImageResponse.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Kingfisher

// MARK: - Kingfisher Alias -
/// Typealias for Kingfisher.CacheType. prevent leaking pod through app
typealias ImageCacheType = Kingfisher.CacheType
/// Typealias for Kingfisher.Source, prevent leaking pod through app
typealias ImageSource = Kingfisher.Source
/// Typealias for Kingfisher.RetrieveImageResult, prevent leaking pod
typealias ImageResult = Kingfisher.RetrieveImageResult

// MARK: - ImageResponse -

/** Currently a copy of Kingfisher.RetrieveImageResult. But added to allow for further options/manipulations
 */
class ImageResponse {
    
    let image: UIImage
    let cacheType: ImageCacheType
    let source: ImageSource
    
    init(imageResult: ImageResult) {
        self.image = imageResult.image
        self.cacheType = imageResult.cacheType
        self.source = imageResult.source
    }
}
