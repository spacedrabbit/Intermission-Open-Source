//
//  BaseModule.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/22/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

enum TempModuleType:String, Codable {
    case video
    case grid
    case collection
}

class TempBaseModule: Codable {
    let headingText: String
    let ctaText: String
    let type: TempModuleType
    
    init(headingText: String, ctaText: String, type: TempModuleType) {
        self.headingText = headingText
        self.ctaText = ctaText
        self.type = type
    }
}

class TempVideoModule: TempBaseModule {
    let video: TempVideoDetail
    
    init(headingText: String, ctaText: String, type: TempModuleType, imageUrl: String, title: String, time: String, isPro: Bool = false) {
        self.video = TempVideoDetail(imageUrl: imageUrl, title: title, time: time, isPro: isPro)
        super.init(headingText: headingText, ctaText: ctaText, type: type)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

struct TempVideoDetail {
    let imageUrl: String
    let title: String
    let time: String
    var isPro: Bool
}

class TempCollectionModule: TempBaseModule {
    
    let videos: [TempVideoDetail]
    
    init(headingText: String, ctaText: String, type: TempModuleType, videos: [TempVideoDetail]) {
        self.videos = videos
        super.init(headingText: headingText, ctaText: ctaText, type: type)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class TempGridModule: TempBaseModule {
    
}

struct TempVideoColelction {
    let title: String
    let videos: [TempVideoDetail]
}

