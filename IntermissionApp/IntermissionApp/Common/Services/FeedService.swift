//
//  FeedService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/22/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import Alamofire

final class FeedService {
    
    static func getFeed(completion: @escaping (IAResult<FeedPage, ContentError>) -> Void) {
        
        ContentfulService.getEntries { (result: IAResult<[FeedPage], ContentError>) in
            switch result {
            case .success(let feedPages):
                guard let feedPage = feedPages.first, feedPages.count == 1 else {
                    completion(.failure(ContentError.unknown))
                    return
                }
                
                completion(.success(feedPage))
                
            case .failure(let error):
                completion(.failure(ContentError.init(error)))
            }
        }
        
    }
    
}
