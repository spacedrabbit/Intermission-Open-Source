//
//  User.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

typealias _Timestamp = Timestamp

/** This represents a fully-fledged user in the app.
 
 */
struct User {
    let id: String
    private(set) var name: Name
    private(set) var email: String?
    private(set) var photoURL: URL?
    let dateJoined: Date?
    let lastLoggedIn: Date?
    private(set) var isPro: Bool
    private(set) var previousEmailAddresses: [String]?
    private(set) var wasPreviouslyGuest: Bool = false
    private(set) var providerId: String?
    private(set) var wasOnboarded: Bool
    let isNewUser: Bool // Do not modify this value directly, it is being set by FirebaseAuth automatically

    init(authenticatedUser: AuthenticatedUser) {
        self.id = authenticatedUser.id
        self.name = Name(nameString: authenticatedUser.name ?? "")
        self.email = authenticatedUser.email
        self.photoURL = authenticatedUser.profilePhotoURL
        self.dateJoined = authenticatedUser.createdDate
        self.lastLoggedIn = authenticatedUser.lastLoginDate
        self.previousEmailAddresses = authenticatedUser.email != nil ? [authenticatedUser.email ?? ""] : nil
        self.isPro = false
        self.wasPreviouslyGuest = authenticatedUser.wasPreviouslyGuest
        self.wasOnboarded = false
        self.isNewUser = authenticatedUser.isNewUser
        self.providerId = authenticatedUser.providerID
    }
    
    /** Initializes a user from Firestore JSON
     */
    init?(dictionary: [String : Any]) {
        guard let id = dictionary.stringValue(User.Key.id) else { return nil }
        self.id = id

        // An AuthenticatedUser coming from FirebaseAuth will have their name as a dictionary value
        if let nameDict: [String : String] = dictionary.dictValue(User.Key.name) {
            if let first = nameDict[Name.Key.firstName], let last = nameDict[Name.Key.lastName] {
                self.name = Name(first: first, last: last)
            } else {
                self.name = Name(first: "", last: "")
            }
        } else if let nameString = dictionary.stringValue(User.Key.name) {
            // When coming from other providers, such as Facebook, the "name" value is available as a string
            self.name = Name(nameString: nameString)
        } else {
            self.name = Name(first: "", last: "")
        }
 
        self.email = dictionary.stringValue(User.Key.email)
        self.photoURL = dictionary.urlValue(User.Key.profileImage)
        self.isPro = dictionary.boolValue(User.Key.isPro) ?? false
        
        self.dateJoined = dictionary.anyValue(User.Key.createdDate, as: Timestamp.self)?.dateValue()
        self.lastLoggedIn = dictionary.anyValue(User.Key.lastLoginDate, as: Timestamp.self)?.dateValue()
        self.wasPreviouslyGuest = dictionary.boolValue(User.Key.wasGuest) ?? false
        self.isNewUser = dictionary.boolValue(User.Key.isNewUser) ?? false
        self.wasOnboarded = dictionary.boolValue(User.Key.wasOnboarded) ?? false
        self.providerId = dictionary.stringValue(User.Key.providerID)
        
        if let email = self.email {
            self.previousEmailAddresses = [email]
        } else {
            self.previousEmailAddresses = nil
        }
    }
    
    mutating func updatePreviousGuestStatus(_ wasGuest: Bool) {
        self.wasPreviouslyGuest = wasGuest
    }
    
    mutating func decorate(with user: User) {
        guard self.id == user.id else { return }
        
        self.name = user.name
        self.isPro = user.isPro
        self.wasOnboarded = user.wasOnboarded
        self.wasPreviouslyGuest = user.wasPreviouslyGuest
        self.photoURL = user.photoURL // we dont check for nil b/c a user is allowed to remove their photo
        
        if let email = user.email {
            self.email = email
        }
        
        if let previousEmail = user.previousEmailAddresses {
            self.previousEmailAddresses = previousEmail
        }

        if let provider = user.providerId {
            self.providerId = provider
        }
        
    }
    
    func linkedToFacebook() -> Bool {
        return providerId?.lowercased().contains("facebook") ?? false
    }
    
    /// If the imageURL is from our FirebaseStorage (as opposed to being hosted on Facebook)
    func profileImageInStorage() -> Bool {
        guard let profileImageURL = photoURL else { return false }
        return profileImageURL.absoluteString.contains("intermissionapp")
                || profileImageURL.absoluteString.contains("firebasestorage")
    }
    
    // MARK: - Keys
    
    struct Key {
        static let id = "id"
        static let email = "email"
        static let name = "name"
        static let profileImage = "image_url"
        static let username = "username"
        static let userProfile = "user_profile"
        static let providerID = "provider_id"
        static let createdDate = "created_date"
        static let lastLoginDate = "last_login_date"
        static let previousEmail = "previous_email_addresses"
        static let isPro = "is_pro"
        static let wasGuest = "was_guest"
        static let wasOnboarded = "was_onboarded"
        static let isNewUser = "is_new_user"
    }
}

// MARK: - DatabaseDecodable

extension User: DatabaseDecodable {
    
    init?(json: [String : Any]) {
        guard
            let id = json.stringValue(Key.id),
            let isPro = json.boolValue(Key.isPro)
        else { return nil }
        
        self.id = id
        
        if let nameDict: [String : String] = json.dictValue(User.Key.name) {
            if let first = nameDict[Name.Key.firstName], let last = nameDict[Name.Key.lastName] {
                self.name = Name(first: first, last: last)
            } else {
                self.name = Name(first: "", last: "")
            }
        } else {
            self.name = Name(first: "", last: "")
        }

        self.isPro = isPro
        self.email = json.stringValue(Key.email)
        self.photoURL = json.urlValue(Key.profileImage)
        self.dateJoined = json.anyValue(Key.createdDate, as: Timestamp.self)?.dateValue()
        self.lastLoggedIn = json.anyValue(Key.lastLoginDate, as: Timestamp.self)?.dateValue()
        self.previousEmailAddresses = json.arrayValue(User.Key.previousEmail)
        self.wasPreviouslyGuest = json.boolValue(Key.wasGuest) ?? false
        self.isNewUser = json.boolValue(Key.isNewUser) ?? false
        self.wasOnboarded = json.boolValue(Key.wasOnboarded) ?? false
        self.providerId = json.stringValue(Key.providerID)
    }
    
}

// MARK: - Name -

struct Name: CustomStringConvertible {
    let first: String
    let last: String
    
    init(nameString: String) {
        let components = nameString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: " ")
        guard components.count > 0 else {
            self.first = ""
            self.last = ""
            return
        }
        
        self.first = components.first ?? ""
        self.last = components.last ?? ""
    }
    
    init(first: String, last: String) {
        self.first = first.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.last = last.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var description: String {
        var name = first
        if !last.isEmpty { name = "\(first) \(last)"}
        return name
    }
    
    var isMissingInfo: Bool {
        return first.isEmpty
    }
}

extension Name: DatabaseEncodable {
    
    struct Key {
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
    
    func toJSON() -> [String : Any] {
        return [
            Key.firstName : first,
            Key.lastName : last
        ]
    }
    
}
