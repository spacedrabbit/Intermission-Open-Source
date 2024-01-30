//
//  URL+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

extension URL {
    
    /// Creates a new URL with the passed query items
    func addingQueryItems(_ params: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.queryItems?.append(contentsOf: params)
        return urlComponents.url
    }
    
}
