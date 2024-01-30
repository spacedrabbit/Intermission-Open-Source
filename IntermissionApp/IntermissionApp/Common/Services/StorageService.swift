//
//  StorageService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/1/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Firebase
import FirebaseStorage

enum StorageError: ErrorDisplayable {
    case upload(Error)
    case metadataMissing
    case urlCouldNotBeGenerated(Error)
    case urlReturnedNil
    case delete(Error)
    
    var displayError: DisplayableError {
        switch self {
        case .upload(let error):
            return DisplayableError(title: "Problem with uploading", message: error.localizedDescription)
        case .urlCouldNotBeGenerated(let error):
            return DisplayableError(title: "There was a problem", message: error.localizedDescription)
        case .delete(let error):
            return DisplayableError(title: "Problem with deleting", message: error.localizedDescription)
        case .metadataMissing, .urlReturnedNil:
            return DisplayableError()
        }
    }
}

typealias UploadTask = StorageUploadTask
typealias TaskSnapshot = StorageTaskSnapshot
typealias ProgressHandler = (TaskSnapshot) -> Void

final class StorageService {
    
    private let storage = Storage.storage()
    static let shared = StorageService()
    private init() {}
    
    @discardableResult
    static func uploadUserImage(for userId: String, imageData: Data, progress: @escaping ProgressHandler, completion: @escaping (IAResult<URL, StorageError>) -> Void) -> UploadTask {
        let reference = shared.storage.reference(withPath: StorageRoute.uploadProfileReference(userId: userId).path())
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let uploadTask: StorageUploadTask = reference.putData(imageData, metadata: uploadMetaData) { (metaData: StorageMetadata?, error: Error?) in
            if let e = error {
                completion(.failure(StorageError.upload(e)))
                return
            }
            
            guard let data = metaData, let ref = data.storageReference else {
                completion(.failure(StorageError.metadataMissing))
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                if let e = error {
                    completion(.failure(StorageError.urlCouldNotBeGenerated(e)))
                    return
                }
                
                guard let u = url else {
                    completion(.failure(StorageError.urlReturnedNil))
                    return
                }
                
                completion(.success(u))
            })
        }
        
        uploadTask.observe(.progress, handler: progress)
        
        return uploadTask
    }
    
    @discardableResult
    static func uploadUserImage(for userId: String, imageData: Data, progress: @escaping (Double) -> Void, completion: @escaping (IAResult<URL, StorageError>) -> Void) -> UploadTask {
        let reference = shared.storage.reference(withPath: StorageRoute.uploadProfileReference(userId: userId).path())
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let uploadTask: StorageUploadTask = reference.putData(imageData, metadata: uploadMetaData) { (metaData: StorageMetadata?, error: Error?) in
            if let e = error {
                completion(.failure(StorageError.upload(e)))
                return
            }
            
            guard let _ = metaData else {
                completion(.failure(StorageError.metadataMissing))
                return
            }
            
            reference.downloadURL(completion: { (url, error) in
                if let e = error {
                    completion(.failure(StorageError.urlCouldNotBeGenerated(e)))
                    return
                }
                
                guard let u = url else {
                    completion(.failure(StorageError.urlReturnedNil))
                    return
                }
                
                completion(.success(u))
            })
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            guard let snapProgress = snapshot.progress else { return }
            progress(snapProgress.fractionCompleted)
        }
        
        return uploadTask
    }
    
    static func deleteUserImage(for userId: String, completion: @escaping (IAResult<Bool, StorageError>) -> Void) {
        let reference = shared.storage.reference(withPath: StorageRoute.uploadProfileReference(userId: userId).path())
        
        reference.delete { (error: Error?) in
            if let error = error {
                completion(.failure(StorageError.delete(error)))
            } else {
                completion(.success(true))
            }
        }
    }
    
}

enum StorageRoute {
    case downloadProfileImage(userId: String)
    case uploadProfileReference(userId: String)

    func path() -> String {
        switch self {
        case .downloadProfileImage(let userId):
            return "\(StorageReferences.baseUrl)\(StorageReferences.profileImagePath)\(userId)/\(StorageReferences.profileImageName)"
        case .uploadProfileReference(let userId):
            return "\(StorageReferences.profileImagePath)\(userId)/\(StorageReferences.profileImageName)"
        }
    }
}

private struct StorageReferences {
    static let baseUrl = "gs://intermissionapp-blem.appspot.com/"
    static let profileImagePath = "profile-images/"
    static let profileImageName = "avatar.jpg"
}
