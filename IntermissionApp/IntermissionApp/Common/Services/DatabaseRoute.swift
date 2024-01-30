//
//  DatabaseRoute.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - DatabaseRoute -

/// Represent absolute paths in the Firestore database
enum DatabaseRoute {
    case users
    case userHistory(id: String)
    case userFavorites(User)
    case deleteFavorite(User, String)
    case guests
    case guestHistory(id: String)
    
    func path() -> String {
        switch self {
        case .users:
            return "\(DatabaseCollection.users)"
        case .userHistory(let userId):
            return "\(DatabaseCollection.userHistory)/\(userId)/\(DatabaseCollection.videos)"
        case .userFavorites(let user):
            return "\(DatabaseCollection.userFavorites)/\(user.id)/\(DatabaseCollection.videos)"
        case .deleteFavorite(let user, let postId):
            return "\(DatabaseCollection.userFavorites)/\(user.id)/\(DatabaseCollection.videos)/\(postId)"
        case .guests:
            return "\(DatabaseCollection.guests)"
        case .guestHistory(let guestId):
            return "\(DatabaseCollection.guestHistory)/\(guestId)/\(DatabaseCollection.videos)"
        }
    }
}

// MARK: - DatabaseCollection -

/// Represent Collection namespaces in the Firestore database
enum DatabaseCollection: String, CustomStringConvertible {
    case users
    case userHistory = "user-history"
    case userFavorites = "user-favorites"
    case videos
    case guests
    case guestHistory = "guest-history"
    
    var description: String { return self.rawValue }
}
