//
//  GuestUser.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/9/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseAuth

struct GuestUser {
    let id: String
    let createdDate: Date?
    
    init(_ authDataResult: AuthDataResult) {
        self.id = authDataResult.user.uid
        self.createdDate = authDataResult.user.metadata.creationDate
    }
    
    init(_ firebaseUser: _FirebaseUser) {
        self.id = firebaseUser.uid
        self.createdDate = firebaseUser.metadata.creationDate
    }
    
    init(_ authenticatedUser: AuthenticatedUser) {
        self.id = authenticatedUser.id
        self.createdDate = authenticatedUser.createdDate
    }
    
    init?(_ json: [String : Any]) {
        guard let id = json.stringValue(User.Key.id) else { return nil }
        self.id = id
        self.createdDate = json.dateValue(User.Key.createdDate)
    }
}

extension GuestUser: DatabaseEncodable {
    
    func toJSON() -> [String : Any] {
        return [
            User.Key.id : self.id,
            User.Key.createdDate : self.createdDate ?? NSNull()
        ]
    }
    
}
