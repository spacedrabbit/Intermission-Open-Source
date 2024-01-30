//
//  DashboardService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/11/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import Alamofire

/// Service for anything specifically Dashboard-related
final class DashboardService {
    
    static func getDashboardRecommendedVideos(completion: @escaping (IAResult<[Post], ContentError>) -> Void) {
        
        ContentfulService.getEntries { (result: IAResult<[DashboardRecommendedPosts], ContentError>) in
            switch result {
            case .success(let recommendations):
                guard let recommendedPosts = recommendations.first, let posts = recommendedPosts.featuredPosts else {
                    completion(.success([]))
                    return
                }
                completion(.success(posts.removingUnpublished()))
                
            case .failure(let error):
                completion(.failure(ContentError.init(error)))
            }
        }
    }
    
}
