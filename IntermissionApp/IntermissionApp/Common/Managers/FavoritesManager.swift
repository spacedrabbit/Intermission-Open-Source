//
//  FavoritesManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FavoritesUpdateType {
    case added, modified, removed, error
    
    init(documentChangeType: DocumentChangeType) {
        switch documentChangeType {
        case .added: self = .added
        case .modified: self = .modified
        case .removed: self = .removed
        default: self = .error
        }
    }
}

/** Used to track changes to a User's favorites
 
 - Note: It is required to call `configure(user:)` on logging a user in for this to work properly
 - Note: Call `teardown` on logging a user out
 */
class FavoritesManager {
    static let shared = FavoritesManager()
    private(set) var userFavorites: [VideoHistoryEntry] = []
    
    private var favoritesListener: Listener? {
        willSet {
            favoritesListener?.remove()
        }
    }
    private var favoritesUpdateHandler: ((IAResult<QuerySnapshot, DatabaseError>) -> Void)?
    
    private init() {}
    
    // MARK: - Configure/Teardown
    
    /// Use this method to beging tracking changes to a user's favorites. You can call this multiple times, but you need to call this at least once before it will work.
    static func configure(user: User) {
        // Remove old listeners and update blocks if the configure method has been called before. Start fresh
        if let _ = shared.favoritesListener, let _ = shared.favoritesUpdateHandler {
//            print("\n\nFavorites manager was previously setup, tearing down first\n\n")
            teardown()
        }
//        print("\n\nInitializing favorites manager with user: \(user)\n\n")
        shared.initialize(with: user)
    }
    
    /// Call this function when logging out a user
    static func teardown() {
        shared.favoritesListener?.remove()
        shared.favoritesListener = nil
        shared.favoritesUpdateHandler = nil
        shared.userFavorites = []
    }
    
    static func isFavorite(post: Post) -> Bool {
        return shared.userFavorites.contains(where: { $0.postId == post.id })
    }
    
    static var favoritePostsCount: Int {
        return shared.userFavorites.count
    }
    
    // MARK: - Initializers
    
    /// Initializes the updateHandle that fires on favorites changes and initializes the listener to keep observations alive
    private func initialize(with user: User) {
        
        // Set up the handler that will send out notifications for favorites-related events
        favoritesUpdateHandler = { [weak self] result in
            switch result {
            case .success(let snapshot):
                // Update our singleton's favorites
                let videoEntries = snapshot.documents
                    .map{ $0.data() }
                    .compactMap(VideoHistoryEntry.init(json:))
                self?.userFavorites = videoEntries

                // Get our changes organized by type, then let interested observers know of the changes
                let changesDict: [DocumentChangeType : [DocumentChange]] = Dictionary(grouping: snapshot.documentChanges, by: { $0.type })
                changesDict.forEach({ (key, value) in
                    
                    // This is extrememly important to do this additional filter. Metadata is on, and if we allow this
                    // Listener to also report on events from the cache (as opposed to only from network requests), then
                    // we end up in a situation where this Lister fires in unwanted scenarios, like on log in.
                    // This was causing the notifyObservers method to fire way way way too often.
                    let videoEntries = value
                        .filter({ $0.document.exists && !$0.document.metadata.isFromCache })
                        .map({ $0.document.data() })
                        .compactMap(VideoHistoryEntry.init(json:))
                    
                    guard videoEntries.count > 0 else { return }
                    self?.notifiyObservers(event: FavoritesUpdateType(documentChangeType: key), favorites: videoEntries)
                })
                
            case .failure(let error):
                print("Error occured: \n\n\(error)")
                self?.notifiyObservers(event: .error, favorites: [], error: error.displayError)
            }
        }
        
        // Get the our listener ready to receive all event changes to the user's favorites
        guard let updateBlock = favoritesUpdateHandler else { return }
        favoritesListener = DatabaseService.favoritesListener(for: user, trackingUpdatesWith: updateBlock)
    }
    
    // MARK: - Notifications
    
    /** Notifies observers of changes to the Favorites DB. A userAddedFavorite event usually is fired on first launch/notificatin setup.
        A modified event happens when a change occured on the DB. A removed event indicates that a favorite was removed. And an error event
        indicates that there was a problem observing the favorites change
 
     */
    private func notifiyObservers(event: FavoritesUpdateType, favorites: [VideoHistoryEntry], error: DisplayableError? = nil) {
        switch event {
        case .added:
            NotificationCenter.default.post(name: .userAddedFavorite, object: nil,
                                            userInfo: [ FavoritesNotificationKey.type : event,
                                                        FavoritesNotificationKey.favorites : favorites])
            
        case .modified:
            NotificationCenter.default.post(name: .userUpdatedFavorites, object: nil,
                                            userInfo: [FavoritesNotificationKey.type : event,
                                                       FavoritesNotificationKey.favorites : favorites])
            
        case .removed:
            NotificationCenter.default.post(name: .userRemovedFavorite, object: nil,
                                            userInfo: [FavoritesNotificationKey.type : event,
                                                       FavoritesNotificationKey.favorites : favorites])
            
        case .error:
            NotificationCenter.default.post(name: .userFavoritesErrored, object: nil,
                                            userInfo: [FavoritesNotificationKey.type : event,
                                                       FavoritesNotificationKey.error : error as Any])
        }
    }
}

struct FavoritesNotificationKey {
    static let type = "com.ia.favorites.updateTypeKey"
    static let favorites = "com.ia.favorites.videoHistoryEntryKey"
    static let error = "com.ia.favorites.errorKey"
}

extension Notification.Name {
    static let userAddedFavorite = Notification.Name(rawValue: "com.ia.favoritesManager.userAddedFavorite")
    static let userUpdatedFavorites = Notification.Name(rawValue: "com.ia.favoritesManager.userUpdatedFavorites")
    static let userRemovedFavorite = Notification.Name(rawValue: "com.ia.favoritesManager.userRemovedFavorite")
    static let userFavoritesErrored = Notification.Name(rawValue: "com.ia.favoritesManager.error")
}
