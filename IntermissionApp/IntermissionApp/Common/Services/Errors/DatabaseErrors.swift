//
//  DatabaseErrors.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// TODO: update
enum DatabaseError: ErrorDisplayable, Equatable {
    case firestore(Error)
    case snapshotListener(Error)
    case listenerFailed
    case noResults
    case unknown
    
    var displayError: DisplayableError {
        switch self {
        case .firestore(let error):
            return DisplayableError(title: "Forgive us!", message: error.localizedDescription, error: error)
            
        case .snapshotListener(let error):
            return DisplayableError(title: "Couldn't finish registration", message: error.localizedDescription, error: error)
            
        case .noResults:
            return DisplayableError(title: "", message: "The request succeeded, but the payload was nil", ignore: true)
            
        case .listenerFailed:
            return DisplayableError(title: "", message: "A listern update failed to return a QuerySnapshot", ignore: true)
            
        default:
            return DisplayableError()
        }
    }
    
    static func ==(lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        switch (lhs, rhs) {
        case (.firestore(let lhError), .firestore(let rhError)):
            return lhError.localizedDescription == rhError.localizedDescription
            
        case (.snapshotListener(let lhError), .snapshotListener(let rhError)):
            return lhError.localizedDescription == rhError.localizedDescription

        case (.noResults, .noResults),
             (.unknown, .unknown),
             (.listenerFailed, .listenerFailed) : return true
            
        default: return false
        }
    }
}
