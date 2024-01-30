//
//  AuthenticatedUser.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseAuth

/** Represents a registered user in our Firebase Authentication DB. This object only has partial user
 data relevant to their info in FirebaseAuth. For full user info, retrieve their details from the
 DatabaseService which queries our Firestore DB
 */
struct AuthenticatedUser {
    
    let id: String
    let isNewUser: Bool
    var wasPreviouslyGuest: Bool = false
    var wasOnboarded: Bool = false // always starts false
    let isGuest: Bool
    
    let email: String?
    let name: String?
    let profilePhotoURL: URL?
    let username: String?
    let userProfile: [String : Any]?
    let providerID: String? // TODO: make enum based on provider
    let createdDate: Date?
    let lastLoginDate: Date?
    
    /** Initializer using FirebaseAuth response object
     */
    init(with authDataResult: AuthDataResult) {
        self.id = authDataResult.user.uid
        self.isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
        
        self.email = authDataResult.user.email
        self.name = authDataResult.user.displayName
        self.profilePhotoURL = authDataResult.user.photoURL
        self.username = authDataResult.user.displayName
        self.createdDate = authDataResult.user.metadata.creationDate
        self.lastLoginDate = authDataResult.user.metadata.lastSignInDate
        self.isGuest = authDataResult.user.isAnonymous
        
        // Takes a little extra work to get this info from a guest->user conversion
        if let additionalInfo = authDataResult.additionalUserInfo {
            self.userProfile = additionalInfo.profile
            self.providerID = additionalInfo.providerID
        } else if let providerInfo = authDataResult.user.providerData.first {
            // Not really sure why I need to get provider info this way, or why it seems to be the first element in this array...
            // It's possible that linking multiple providers in the future will require updating the "provider" property to be an
            // array of values, but for now let's assume only a single auth provider is possible
            self.userProfile = nil
            self.providerID = providerInfo.providerID
        } else {
            self.userProfile = nil
            self.providerID  = "unknown"
        }
    }
    
    init(with firebaseUser: _FirebaseUser) {
        self.id = firebaseUser.uid
        self.isNewUser = false // If we create from a FirebaseUser it means a session existed and we're logging them in automatically on app launch. so they aren't a new user.
        
        self.email = firebaseUser.email
        self.name = firebaseUser.displayName
        self.profilePhotoURL = firebaseUser.photoURL
        self.username = firebaseUser.displayName
        self.userProfile = nil
        self.providerID = firebaseUser.providerID
        self.createdDate = firebaseUser.metadata.creationDate
        self.lastLoginDate = firebaseUser.metadata.lastSignInDate
        self.isGuest = firebaseUser.isAnonymous
    }
    
    mutating func updatePreviousGuestStatus(_ wasGuest: Bool) {
        self.wasPreviouslyGuest = wasGuest
    }
}

// MARK: - DatabaseRepresentable

extension AuthenticatedUser: DatabaseEncodable {
    
    func toJSON() -> [String : Any] {
        return [
            User.Key.id : self.id,
            User.Key.email : self.email ?? NSNull(),
            User.Key.name : self.name ?? NSNull(),
            User.Key.profileImage : self.profilePhotoURL?.absoluteString ?? NSNull(),
            User.Key.username : self.username ?? NSNull(),
            User.Key.providerID : self.providerID ?? NSNull(),
            User.Key.createdDate : self.createdDate ?? _FieldVal.serverTimestamp(),
            User.Key.lastLoginDate : self.lastLoginDate ?? _FieldVal.serverTimestamp(),
            User.Key.wasGuest : self.wasPreviouslyGuest,
            User.Key.isNewUser : self.isNewUser,
            User.Key.wasOnboarded : self.wasOnboarded
        ]
    }
    
}
