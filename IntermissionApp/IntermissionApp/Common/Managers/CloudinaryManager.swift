//
//  CloudinaryManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/8/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Cloudinary

final class CloudinaryManager {
    static let shared: CloudinaryManager = CloudinaryManager()
    
    static private let cloudName = ""
    static private let apiKey = ""
    static private let apiSecret = ""
    static private let resourceFolder = ""
    
    private let instance: CLDCloudinary
    
    private init() {
        let config = CLDConfiguration(cloudName: CloudinaryManager.cloudName,
                                      apiKey: CloudinaryManager.apiKey,
                                      apiSecret: CloudinaryManager.apiSecret,
                                      secure: true)
        instance = CLDCloudinary(configuration: config)
    }
    
    static func cloudinaryUrl(from entry: VideoHistoryEntry) -> URL? {
        // It's not ideal, but we want the video to always play, so if any of these checks fails, just try to return
        // the untransformed URL
        guard let url = entry.videoURL, !url.lastPathComponent.isEmpty else {
            Track.track(eventName: "Cloudinary_URL_PreReqs_Failed")
            return entry.videoURL
        }
        
        let transform = CLDTransformation()
        transform.setQuality(CLDTransformation.CLDQuality.auto(.good))
        
        guard
            let cloudinaryString = shared.instance
                .createUrl()
                .setResourceType("video")
                .setTransformation(transform)
                .generate(CloudinaryManager.resourceFolder + url.lastPathComponent),
            let cloudinaryTransformURL = URL(string: cloudinaryString)
        else {
            Track.track(eventName: "Cloudinary_URL_Generation_Failed")
            return entry.videoURL
        }
        
        return cloudinaryTransformURL
    }
}
