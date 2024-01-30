//
//  SessionError.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/6/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth

// MARK: - ErrorDisplayable -

/** Indicates that the error comes with a human-readible alert ready to use */
protocol ErrorDisplayable: Error {
    
    var displayError: DisplayableError { get }
    
}

// MARK: - SessionError -

enum SessionError: ErrorDisplayable, Equatable {
    
    case networkError(Error),
    userNotFound(Error),
    userTokenExpired(Error),
    tooManyRequests(Error),
    invalidAPIKey(Error),
    appNotAuthorized(Error),
    keychainError(Error),
    internalError(Error),
    
    invalidEmail(Error),
    operationNotAllowed(Error),
    userDisabled(Error),
    wrongPassword(Error),
    invalidCredential(Error),
    emailAlreadyInUse(Error),
    weakPassword(Error),
    
    invalidUserToken(Error),
    userMismatch(Error),
    requiresRecentLogin(Error),
    providerAlreadyLinked(Error),
    credentialAlreadyInUse(Error),
    noSuchProvider(Error),
    
    accountExistsWithDifferentCredential(Error),
    credentialsMissing,
    unknownError
 
    init(error: Error?) {
        guard let unwrappedError = error else {
            self = .unknownError
            return
        }
        
        let error = unwrappedError as NSError
        guard let authError = AuthErrorCode(rawValue: error.code) else {
            self = .unknownError
            return
        }
        
        switch authError {
        case .networkError:             self = .networkError(unwrappedError)
        case .userNotFound:             self = .userNotFound(unwrappedError)
        case .userTokenExpired:         self = .userTokenExpired(unwrappedError)
        case .tooManyRequests:          self = .tooManyRequests(unwrappedError)
        case .invalidAPIKey:            self = .invalidAPIKey(unwrappedError)
        case .appNotAuthorized:         self = .appNotAuthorized(unwrappedError)
        case .keychainError:            self = .keychainError(unwrappedError)
        case .internalError:            self = .internalError(unwrappedError)
        case .invalidEmail:             self = .invalidEmail(unwrappedError)
        case .operationNotAllowed:      self = .operationNotAllowed(unwrappedError)
        case .userDisabled:             self = .userDisabled(unwrappedError)
        case .wrongPassword:            self = .wrongPassword(unwrappedError)
        case .invalidCredential:        self = .invalidCredential(unwrappedError)
        case .emailAlreadyInUse:        self = .emailAlreadyInUse(unwrappedError)
        case .weakPassword:             self = .weakPassword(unwrappedError)
        case .invalidUserToken:         self = .invalidUserToken(unwrappedError)
        case .userMismatch:             self = .userMismatch(unwrappedError)
        case .requiresRecentLogin:      self = .requiresRecentLogin(unwrappedError)
        case .providerAlreadyLinked:    self = .providerAlreadyLinked(unwrappedError)
        case .credentialAlreadyInUse:   self = .credentialAlreadyInUse(unwrappedError)
        case .noSuchProvider:           self = .noSuchProvider(unwrappedError)
        case .accountExistsWithDifferentCredential: self = .accountExistsWithDifferentCredential(unwrappedError)
        default:                        self = .unknownError
        }
        
    }

    var displayError: DisplayableError {
        switch  self {
        case .networkError(let error), .userTokenExpired(let error),
             .tooManyRequests(let error), .invalidAPIKey(let error), .appNotAuthorized(let error),
             .keychainError(let error), .internalError(let error), .invalidEmail(let error),
             .operationNotAllowed(let error), .userDisabled(let error), .wrongPassword(let error),
             .invalidCredential(let error), .weakPassword(let error),
             .invalidUserToken(let error), .userMismatch(let error), .requiresRecentLogin(let error),
             .providerAlreadyLinked(let error), .credentialAlreadyInUse(let error), .noSuchProvider(let error):
            return DisplayableError(title: "Something went wrong", message: error.localizedDescription, ignore: false, error: error)
            
        case .emailAlreadyInUse(let error):
            return DisplayableError(title: "You're already registered!", message: "We had our robots check, and they've confirmed this email address is already registered. That's great news! If you're having trouble remembering your password, try resetting it.", ignore: false, error: error)
            
        case .userNotFound(let error):
            return DisplayableError(title: "We couldn't find you", message: "According to our robots, it doesn't look like you've signed up with us in the past. \n\nTry a different email address?", ignore: false, error: error)
        
        case .credentialsMissing:
            return DisplayableError(title: "Confirm your change", message: "In order to confirm switching your email address, we'll need your password. Our robots want this security step to make sure that it's really you.", ignore: false, error: nil)
            
        case .accountExistsWithDifferentCredential(let error):
            return DisplayableError(title: "Try a different sign in", message: "We have a record of your account, but not using the sign in method you just tried. This can happen if you sign up with Facebook, then disconnect your account and try to log in again.", ignore: false, error: error)
            
        case .unknownError:
            return DisplayableError()
        }
    }
    
    public static func ==(lhs: SessionError, rhs: SessionError) -> Bool {
        switch (lhs, rhs) {
        case (.weakPassword, .weakPassword): return true
        case (.weakPassword, _), (_, .weakPassword): return false
        default: return lhs == rhs
        }
    }
}

// TODO: i might get rid of this entirely
enum FacebookSessionError: ErrorDisplayable {
    case cancelled,
         declinedEmailPermission,
         declindedPublicProfilePermission,
         missingUserId,
         other(Error)
    
    init(error: FacebookAuthError) {
        switch error {
        case .cancelled: self = .cancelled
        case .declinedEmailPermission: self = .declinedEmailPermission
        case .declinedPublicProfilePermission: self = .declindedPublicProfilePermission
        case .missingUserId: self = .missingUserId
        case .other(let error): self = .other(error)
        }
        
    }
    
    var displayError: DisplayableError {
        return DisplayableError()
    }
    
}
