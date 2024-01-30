//
//  FacebookManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import Alamofire

struct FacebookSession {
    let token: String
    let userId: String?
}

class FacebookManager {
    
    static var isSessionActive: Bool { return AccessToken.current != nil }
    static var accessToken: String? { return AccessToken.current?.authenticationToken }
    private static let permissions: [ReadPermission] = [.email, .publicProfile]
    
    let shared: FacebookManager = FacebookManager()
    private init() {}
    
    public static func authorizeFacebook(in controller: UIViewController, completion: @escaping (IAResult<FacebookSession, FacebookAuthError>) -> Void) {
        
        if FacebookManager.isSessionActive, let token = AccessToken.current, Date() < token.expirationDate {
            let session = FacebookSession(token: token.authenticationToken, userId: token.userId)
            completion(.success(session))
            return
        }
        
        LoginManager().logIn(readPermissions: FacebookManager.permissions, viewController: controller) { (loginResult: LoginResult) in
            switch loginResult {
            case .success(let grantedPermissions, _, let accessToken):
                
                // Check for email permission
                guard grantedPermissions.contains(Permission(name: "email")) else {
                    completion(.failure(FacebookAuthError.declinedEmailPermission))
                    return
                }
                
                // Check for public profile permission
                guard grantedPermissions.contains(Permission(name: "public_profile")) else {
                    completion(.failure(FacebookAuthError.declinedPublicProfilePermission))
                    return
                }
                
                // Check for userId. not sure when a successful request wouldn't return this though
                guard let userId = accessToken.userId else {
                    completion(.failure(FacebookAuthError.missingUserId))
                    return
                }
                
                let facebookSession = FacebookSession(token: accessToken.authenticationToken, userId: userId)
                completion(.success(facebookSession))
            
            case .cancelled:
                completion(.failure(FacebookAuthError.cancelled))
            case .failed(let error):
                completion(.failure(.other(error)))
            }
        }
    }
    
    public static func logoutFacebook() {
        LoginManager().logOut()
    }
}

// MARK: - Facebook Errors

/**
 Error states for Facebook authentication.
 
 */
enum FacebookAuthError: ErrorDisplayable, Equatable {
    case cancelled
    case declinedEmailPermission
    case declinedPublicProfilePermission
    case missingUserId
    case other(Error)
    
    var displayError: DisplayableError {
        switch self {
        case .cancelled:
            return DisplayableError(title: FacebookStrings.Error.authCancelledTitle, message: FacebookStrings.Error.authCancelledBody)
        case .declinedEmailPermission:
            return DisplayableError(title: FacebookStrings.Error.declinedEmailPermissionTitle, message: FacebookStrings.Error.declinedEmailPermissionBody)
        case .declinedPublicProfilePermission:
            return DisplayableError(title: FacebookStrings.Error.declinedProfilePermissionTitle, message: FacebookStrings.Error.declinedProfilePermissionBody)
        case .missingUserId:
            return DisplayableError(title: FacebookStrings.Error.missingUserIdTitle, message: FacebookStrings.Error.missingUserIdBody)
        case .other(let error):
            return DisplayableError(title: "", message: error.localizedDescription)
        }
    }
    
    static func ==(lhs: FacebookAuthError, rhs: FacebookAuthError) -> Bool {
        return lhs.displayError == rhs.displayError
    }
}

