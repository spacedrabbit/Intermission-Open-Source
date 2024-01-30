//
//  DatabaseService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseFirestore

// MARK: - Typealiases -

typealias Listener = ListenerRegistration
typealias _DocumentRef = DocumentReference
typealias _CollectionRef = CollectionReference
typealias _FieldVal = FieldValue

// MARK: - Database Service -

class DatabaseService {
    private let db = Firestore.firestore()
    static let shared = DatabaseService()
    
    private init() {}
    
    // MARK: - Favorites
    
    /// Call this method if you don't need the callback handler
    static func addToFavorites(post: Post, for user: User) {
        DatabaseService.addToFavorites(post: post, for: user, completion: { _ in })
    }
    
    static func addToFavorites(post: Post, for user: User, completion: @escaping (IAResult<Bool, DatabaseError>) -> Void) {
        guard var entry = VideoHistoryEntry(post: post) else { return }
        entry.setFavorite(true) // adds the date video was favorited
        
        let route = DatabaseRoute.userFavorites(user)
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(entry.postId)
        
        documentReference.setData(entry.toJSON()) { (error) in
            if let error = error {
                let wrapped = DatabaseError.firestore(error)
                Track.track(displayableError: wrapped.displayError, domain: ErrorType.Favorites.Subtype.addToFavoritesFailed)
                completion(.failure(wrapped))
                return
            }
            
            Track.track(eventName: EventType.Video.favoritedVideo)
            completion(.success(true))
        }
    }
    
    /// Call this method if you don't need the callback handler
    static func removeFromFavorites(post: Post, for user: User) {
        DatabaseService.removeFromFavorites(post: post, for: user, completion: { _ in})
    }
    
    static func removeFromFavorites(post: Post, for user: User, completion: @escaping (IAResult<Bool, DatabaseError>) -> Void) {
        
        let route = DatabaseRoute.deleteFavorite(user, post.id)
        let documentReference = DatabaseService.shared.db.document(route.path()) // this path is right to the post we're interested in
        
        documentReference.delete { (error) in
            if let error = error {
                let wrapped = DatabaseError.firestore(error)
                Track.track(displayableError: wrapped.displayError, domain: ErrorType.Favorites.Subtype.removeFromFavoritesFailed)
                completion(.failure(wrapped))
                return
            }
            
            Track.track(eventName: EventType.Video.unfavoritedVideo)
            completion(.success(true))
        }
    }
    
    static func getFavorites(for user: User, limit: Int = 10, descending: Bool = true, completion: @escaping (IAResult<[VideoHistoryEntry], DatabaseError>) -> Void) {
        
        let route = DatabaseRoute.userFavorites(user)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        collectionReference
            .limit(to: limit)
            .order(by: VideoHistoryEntry.Keys.lastDateWatched, descending: descending)
            .getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(DatabaseError.noResults))
                return
            }
            
            let videoEntries = snapshot.documents
                .map{ $0.data() }
                .compactMap(VideoHistoryEntry.init(json:))
            
            completion(.success(videoEntries))
        }
    }
    
    /** Use this method to retrieve initial state and to listen for future updates for a user's change in favorites data.
 
     */
    @discardableResult
    static func favoritesListener(for user: User, trackingUpdatesWith updateBlock: @escaping (IAResult<QuerySnapshot, DatabaseError>) -> Void) -> Listener {
        
        let route = DatabaseRoute.userFavorites(user)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        return collectionReference
            .order(by: VideoHistoryEntry.Keys.dateFavorited, descending: true)
            .addSnapshotListener(includeMetadataChanges: true) { (querySnapshot: QuerySnapshot?, error: Error?) in
                if let error = error {
                    updateBlock(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    updateBlock(.failure(DatabaseError.listenerFailed))
                    return
                }
                
                updateBlock(.success(snapshot))
        }
        
    }
    
    // MARK: - Add to History -
    
    static func addOrUpdateHistory(entry: VideoHistoryEntry, for user: User) {
        DatabaseService.addOrUpdateHistory(entry: entry, for: user) { (_) in }
    }
    
    static func addOrUpdateHistory(entry: VideoHistoryEntry, for user: User, completion: @escaping (IAResult<Bool, DatabaseError>) -> Void) {
        let route = DatabaseRoute.userHistory(id: user.id)
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(entry.videoId)
        
        // All besides Favorites, but we'll likely change this later
        let mergeFields: [Any] = [VideoHistoryEntry.Keys.postId,
                                  VideoHistoryEntry.Keys.videoId,
                                  VideoHistoryEntry.Keys.postTitle,
                                  VideoHistoryEntry.Keys.thumbnailURL,
                                  VideoHistoryEntry.Keys.videoURL,
                                  VideoHistoryEntry.Keys.durationSeconds,
                                  VideoHistoryEntry.Keys.lastDateWatched,
                                  VideoHistoryEntry.Keys.secondsWatched,
                                  VideoHistoryEntry.Keys.finishedWatching,
                                  VideoHistoryEntry.Keys.tags]
        
        documentReference.setData(entry.toJSON(), mergeFields:mergeFields) { (error: Error?) in
            if let error = error {
                Track.track(error: error, domain: ErrorType.History.Subtype.addOrUpdateHistoryFailed)
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
            completion(.success(true))
        }
        
    }
    
    static func addOrUpdateHistory(entry: VideoHistoryEntry, for guest: GuestUser) {
        DatabaseService.addOrUpdateHistory(entry: entry, for: guest) { (_) in }
    }
    
    static func addOrUpdateHistory(entry: VideoHistoryEntry, for guest: GuestUser, completion: @escaping (IAResult<Bool, DatabaseError>) -> Void) {
        let route = DatabaseRoute.guestHistory(id: guest.id)
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(entry.videoId)
        
        // All besides Favorites, because guests can't yet store favorites
        let mergeFields: [Any] = [VideoHistoryEntry.Keys.postId,
                                  VideoHistoryEntry.Keys.videoId,
                                  VideoHistoryEntry.Keys.postTitle,
                                  VideoHistoryEntry.Keys.thumbnailURL,
                                  VideoHistoryEntry.Keys.videoURL,
                                  VideoHistoryEntry.Keys.durationSeconds,
                                  VideoHistoryEntry.Keys.lastDateWatched,
                                  VideoHistoryEntry.Keys.secondsWatched,
                                  VideoHistoryEntry.Keys.finishedWatching,
                                  VideoHistoryEntry.Keys.tags]
        
        documentReference.setData(entry.toJSON(), mergeFields: mergeFields) { (error) in
            if let error = error {
                Track.track(error: error, domain: ErrorType.History.Subtype.addOrUpdateHistoryFailed)
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
            completion(.success(true))
        }
        
        
    }
  
    // MARK: - Get History -
    
    static func getHistory(for user: User, limit: Int = 10, descending: Bool = true, completion: @escaping (IAResult<[VideoHistoryEntry], DatabaseError>) -> Void ) {
        
        let route = DatabaseRoute.userHistory(id: user.id)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        collectionReference
            .limit(to: limit)
            .order(by: VideoHistoryEntry.Keys.lastDateWatched, descending: descending)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.failure(DatabaseError.noResults))
                    return
                }
                
                let videoEntries = snapshot.documents
                    .map{ $0.data() }
                    .compactMap(VideoHistoryEntry.init(json:))
                
                completion(.success(videoEntries))
        }
    }
    
    static func getHistory(for guest: GuestUser, limit: Int = 10, descending: Bool = true, completion: @escaping (IAResult<[VideoHistoryEntry], DatabaseError>) -> Void ) {
        
        let route = DatabaseRoute.guestHistory(id: guest.id)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        collectionReference
            .limit(to: limit)
            .order(by: VideoHistoryEntry.Keys.lastDateWatched, descending: descending)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.failure(DatabaseError.noResults))
                    return
                }
                
                let videoEntries = snapshot.documents
                    .map{ $0.data() }
                    .compactMap(VideoHistoryEntry.init(json:))
                
                completion(.success(videoEntries))
        }
    }
    
    // MARK: - Transfer History -
    
    static func transferHistory(from guestId: String, to userId: String, completion: @escaping (IAResult<Bool, DatabaseError>) -> Void) {
        let guestHistoryRoute = DatabaseRoute.guestHistory(id: guestId)
        let guestCollectionReference = DatabaseService.shared.db.collection(guestHistoryRoute.path())
        
        let userHistoryRoute = DatabaseRoute.userHistory(id: userId)
        let userHistoryCollectionReference = DatabaseService.shared.db.collection(userHistoryRoute.path())
        
        let batch = DatabaseService.shared.db.batch()
        guestCollectionReference.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(DatabaseError.noResults))
                return
            }
            
            // Get documents, grab their data dictionary ([String:Any]), try to convert to VideoHistoryEntry and then add data to batch
            snapshot.documents
                .map{ $0.data() }
                .compactMap(VideoHistoryEntry.init(json:))
                .forEach { batch.setData($0.toJSON(), forDocument: userHistoryCollectionReference.document($0.postId)) }
            
            batch.commit(completion: { (error) in
                if let error = error {
                    completion(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                completion(.success(true))
            })
        }
    }
    
    /** Use this method to retrieve initial state and to listen for future updates for a user's change in video history data
     
     */
    @discardableResult
    static func videoHistoryListener(for user: User, trackingUpdatesWith updateBlock: @escaping (IAResult<QuerySnapshot, DatabaseError>) -> Void) -> Listener {
        let route = DatabaseRoute.userHistory(id: user.id)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        return collectionReference
            .order(by: VideoHistoryEntry.Keys.lastDateWatched, descending: true)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (querySnapshot: QuerySnapshot?, error: Error?) in
                if let error = error {
                    updateBlock(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    updateBlock(.failure(DatabaseError.listenerFailed))
                    return
                }
                
                updateBlock(.success(snapshot))
            })
    }
    
    @discardableResult
    static func _videoHistoryListener(for user: User, trackingUpdatesWith updateBlock: @escaping (IAResult<QuerySnapshot, DatabaseError>) -> Void) -> Listener {
        let route = DatabaseRoute.userHistory(id: user.id)
        let collectionReference = DatabaseService.shared.db.collection(route.path())
        
        return collectionReference
            .order(by: VideoHistoryEntry.Keys.lastDateWatched, descending: true)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (querySnapshot: QuerySnapshot?, error: Error?) in
                if let error = error {
                    updateBlock(.failure(DatabaseError.firestore(error)))
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    updateBlock(.failure(DatabaseError.listenerFailed))
                    return
                }
                
                updateBlock(.success(snapshot))
            })
    }
    
    // MARK: - Create User/Guest

    /** Adds a newly registered user to the Firestore DB. You generally will call this from inside the
        completion block of UserService.createUser.
     
     - Warning: You must handle the Listener object returned by this function by calling its .remove()
        method as the last step in the completion block.
 
     */
    static func addNew(user: AuthenticatedUser, completion: @escaping (IAResult<User, DatabaseError>) -> Void) -> Listener {
        
        let route = DatabaseRoute.users
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(user.id)
        
        // The use of listeners are required to be able to send back the new user in the completion
        // block of this function. The .setData call only returns an error, so the FireStore docs
        // say to add a snapshotListener if you need to handle updates to a document reference.
        let listener = documentReference.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.snapshotListener(error)))
                return
            }
            guard let data = documentSnapshot?.data(), let user = User(dictionary: data) else {
                completion(.failure(DatabaseError.unknown))
                return
            }
            completion(.success(user))
        }
        
        documentReference.setData(user.toJSON(), merge: true) { (error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
        }
        
        return listener
    }
    
    /** Adds a guest user to the Firestore DB.
     
     - Warning: You must handle the Listener object returned by this function by calling its .remove()
     method as the last step in the completion block.
     
     */
    static func addNew(guest: GuestUser, completion: @escaping (IAResult<GuestUser, DatabaseError>) -> Void) -> Listener {
        
        let route = DatabaseRoute.guests
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(guest.id)
        
        // The use of listeners are required to be able to send back the new user in the completion
        // block of this function. The .setData call only returns an error, so the FireStore docs
        // say to add a snapshotListener if you need to handle updates to a document reference.
        let listener = documentReference.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.snapshotListener(error)))
                return
            }
            
            guard let json = documentSnapshot?.data(), let guest = GuestUser(json) else {
                completion(.failure(DatabaseError.noResults))
                return
            }
            
            completion(.success(guest))
        }
        
        documentReference.setData(guest.toJSON()) { (error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
        }
        
        return listener
    }
    
    // MARK: - Get User/Guest
    
    /** Retrieves a FirestoreDB record of the user from their Auth id
 
     */
    static func getUser(_ id: String, completion: @escaping (IAResult<User, DatabaseError>) -> Void) {
        
        let route = DatabaseRoute.users
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(id)
        
        documentReference.getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
            
            guard let data = documentSnapshot?.data(), let user = User(dictionary: data) else {
                completion(.failure(DatabaseError.noResults))
                return
            }
            
            completion(.success(user))
        }
    }
    
    // MARK: - Update User
    
    /// Update any value of a user that is different in the UpdateUserRequest from their current value 
    static func updateUser(_ request: UpdateUserRequest, completion: @escaping (IAResult<User, DatabaseError>) -> Void) -> Listener {
        
        let route = DatabaseRoute.users
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(request.id)
        
        // In theory you'd want to set up the listener before making the call to update/set, but the likelihood that
        // the network request will finish before the snapshot listener gets generated is probably impossible
        documentReference.updateData(request.toJSON()) { (error) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
        }
        
        return documentReference.addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.snapshotListener(error)))
                return
            }
            
            guard let snapshot = snapshot, let data = snapshot.data(), let user = User(dictionary: data) else {
                completion(.failure(DatabaseError.noResults))
                return
            }

            if !snapshot.metadata.hasPendingWrites {
                completion(.success(user))
            }

            NotificationCenter.default.post(name: .userInfoUpdateSuccess,
                                            object: nil,
                                            userInfo: [DatabaseUpdatedNotificationKey.user : user])
        }
    }
    
    /// Updates a user's provider id
    static func updateUser(_ id: String, providerID: String, completion: @escaping (IAResult<User, DatabaseError>) -> Void) -> Listener {
        
        let route = DatabaseRoute.users
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(id)
        
        let listener = documentReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(.failure(DatabaseError.snapshotListener(error)))
                return
            }

            guard let data = snapshot?.data(), let user = User(dictionary: data) else {
                completion(.failure(DatabaseError.noResults))
                return
            }
            
            completion(.success(user))
            NotificationCenter.default.post(name: .userInfoUpdateSuccess,
                                            object: nil,
                                            userInfo: [DatabaseUpdatedNotificationKey.user : user])
        }
        
        documentReference.updateData([
            User.Key.providerID : providerID
        ]) { (error: Error?) in
            if let error = error {
                completion(.failure(DatabaseError.firestore(error)))
                return
            }
        }
        
        return listener
    }
    
    /// Updates a user's provider id silently
    static func updateUser(_ id: String, providerID: String) {
        let route = DatabaseRoute.users
        let documentReference = DatabaseService.shared.db.collection(route.path()).document(id)
        documentReference.updateData([User.Key.providerID : providerID])
    }

}

struct DatabaseUpdatedNotificationKey {
    static let user = "com.ia.database.userUpdatedKey"
    static let error = "com.ia.database.updateErrorKey"
    static let intent = "com.ia.database.updateIntentKey"
}

extension Notification.Name {
    static let userInfoUpdateSuccess = Notification.Name(rawValue: "com.ia.databaseService.userInfoUpdateSuccess")
    static let userInfoUpdateFailed = Notification.Name(rawValue: "com.ia.databaseService.userInfoUpdateFailure")
}
