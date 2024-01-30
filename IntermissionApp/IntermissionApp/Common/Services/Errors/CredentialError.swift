//
//  CredentialError.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - Credential Error -

enum CredentialError: ErrorDisplayable {
    case couldNotSaveCredentials
    case couldNotSaveFacebookSession
    case couldNotFindEmail
    case couldNotFindPassword
    case couldNotFindFacebookSession
    case couldNotClearCredentials
    /// Use this if you really want to show the KeychainAccess error. Useful for debugging
    case other(Error)
    
    var displayError: DisplayableError {
        switch self {
        case .other(let error):
            return DisplayableError(title: "There was an issue saving your info",
                                    message: error.localizedDescription)
        default: return DisplayableError()
        }
    }
}
