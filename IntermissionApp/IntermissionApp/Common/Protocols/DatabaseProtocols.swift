//
//  DatabaseProtocols.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - DatabaseRepresentable -

/// Objects conforming to DatabaseRepresentable can be saved to and retrieved from FirestoreDB
protocol DatabaseRepresentable: DatabaseEncodable & DatabaseDecodable {}

/// Objects conforming to DatabaseEncodable can be stored as Documents in the FirestoreDB
protocol DatabaseEncodable {
    
    func toJSON() -> [String : Any]
    
}
/// Objects conforming to DatabaseDecodable can be retrieved as Documents from the FirestoreDB
protocol DatabaseDecodable {
    
    init?(json: [String : Any])
    
}
