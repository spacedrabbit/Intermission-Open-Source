//
//  UpdateUserRequest.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

struct UpdateField: OptionSet {
    let rawValue: Int
    
    static let name = UpdateField(rawValue: 1 << 0)
    static let email = UpdateField(rawValue: 1 << 1)
    static let photoUrl = UpdateField(rawValue: 1 << 2)
    static let proStatus = UpdateField(rawValue: 1 << 3)
    static let previousEmails = UpdateField(rawValue: 1 << 4)
    static let onboardedStatus = UpdateField(rawValue: 1 << 5)
    static let providerId = UpdateField(rawValue: 1 << 6)
    
}

/** Used to update a user's info.
 
 - Note: Out of an abundance of caution, we use the presence of change keys to determine what values
 end up in the request json. We do this because the FirebaseFirestore request to update a DB record
 will overwrite any field you send it. So in reality, initializing with the User object will get
 us a request that starts off with all the values set to the user's current values. But to make the
 payload more obvious for what we're looking to update, we do it this way.
 
 */
struct UpdateUserRequest {
    let id: String
    private var name: Name
    private var email: String?
    private var photoURL: String?
    private var isPro: Bool
    private var previousEmailAddresses: [String]?
    private var wasOnboarded: Bool
    private var providerId: String?

    private let originalUserData: User
    private var updateFields: UpdateField = []
    
    init(user: User) {
        self.id = user.id
        self.name = user.name
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.isPro = user.isPro
        self.previousEmailAddresses = user.previousEmailAddresses
        self.wasOnboarded = user.wasOnboarded
        self.providerId = user.providerId
        self.originalUserData = user
    }

    mutating func update(first: String, last: String) {
        self.name = Name(first: first, last: last)
        updateFields.insert(.name)
    }
    
    mutating func updateProfile(url: URL?) {
        if let u = url {
            self.photoURL = u.absoluteString
        } else {
            self.photoURL = nil
        }
        updateFields.insert(.photoUrl)
    }
    
    mutating func updateProStatus(_ isPro: Bool) {
        self.isPro = isPro
        updateFields.insert(.proStatus)
    }
    
    mutating func updateEmail(_ email: String) {
        self.email = email
        self.previousEmailAddresses?.append(email)
        updateFields.insert(.email)
        updateFields.insert(.previousEmails)
    }
    
    mutating func updateOnboardingStatus(_ wasOnboarded: Bool) {
        self.wasOnboarded = wasOnboarded
        updateFields.insert(.onboardedStatus)
    }
    
    mutating func updateProviderId(_ providerId: String) {
        self.providerId = providerId
        updateFields.insert(.providerId)
    }

}

// MARK: - DatabaseRepresentable -

extension UpdateUserRequest: DatabaseEncodable {
    
    func toJSON() -> [String : Any] {
        var json: [String : Any] = [:]
        
        // Name
        if updateFields.contains(.name) {
            json.updateValue(self.name.toJSON(), forKey: User.Key.name)
        }
        
        // Email
        if updateFields.contains(.email),
            updateFields.contains(.previousEmails),
            let email = self.email,
            let prior = self.previousEmailAddresses {
            json.updateValue(email, forKey: User.Key.email)
            json.updateValue(prior, forKey: User.Key.previousEmail)
        }
        
        // Profile Photo Url
        if updateFields.contains(.photoUrl) {
            if let u = photoURL {
                json.updateValue(u, forKey: User.Key.profileImage)
            } else {
                json.updateValue(NSNull(), forKey: User.Key.profileImage)
            }
        }
        
        // Pro Status
        if updateFields.contains(.proStatus) {
            json.updateValue(self.isPro, forKey: User.Key.isPro)
        }
        
        // Onboarded
        if updateFields.contains(.onboardedStatus) {
            json.updateValue(self.wasOnboarded, forKey: User.Key.wasOnboarded)
        }
        
        // Provider Id
        if updateFields.contains(.providerId), let id = providerId {
            json.updateValue(id, forKey: User.Key.providerID)
        }

        return json
    }
    
}
