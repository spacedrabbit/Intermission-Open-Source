//
//  UserService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/25/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import Alamofire

enum UpdateRequestError: Error, ErrorDisplayable {
    case noCredentials
    
    var displayError: DisplayableError {
        switch self {
        case .noCredentials:
            return DisplayableError(title: "Confirm your change", message: "In order to confirm making this update, we'll need your password. Our robots want this security step to make sure that it's really you.", ignore: false, error: nil)
            
        }
    }
}

struct UpdateEmailRequest {
    let newEmail: String
    let existingEmail: String
    let password: String
    
    init(newEmail: String, existingEmail: String?, password: String?) throws {
        self.newEmail = newEmail
        
        if let ex = existingEmail, let pass = password {
            self.existingEmail = ex
            self.password = pass
        } else if let em = CredentialManager.email, let pass = CredentialManager.password {
            self.existingEmail = em
            self.password = pass
        } else {
            throw UpdateRequestError.noCredentials
        }
    }
    
}

struct UpdatePasswordRequest {
    let emailAddress: String
    let newPassword: String
    let existingPassword: String
    
    init(newPassword: String, emailAddress: String?, existingPassword: String?) throws {
        self.newPassword = newPassword
        
        if let pass = existingPassword, let email = emailAddress {
            self.existingPassword = pass
            self.emailAddress = email
        } else if let pass = CredentialManager.password, let email = CredentialManager.email  {
            self.existingPassword = pass
            self.emailAddress = email
        } else {
            throw UpdateRequestError.noCredentials
        }
        
    }
}

class UserService {
    
    /** Registers a new user
     */
    public static func createUser(email: String, password: String, completion: @escaping (IAResult<AuthenticatedUser, SessionError>)  -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult: AuthDataResult?, error: Error?) in
            guard let authResult = authDataResult else {
                completion(.failure(SessionError(error: error)))
                return
            }
            
            CredentialManager.set(email: email, password: password)
            completion(.success(AuthenticatedUser(with: authResult)))
        }
    }

    public static func update(password: String, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            if let error = error {
                let sessionError = SessionError(error: error)
                
                switch sessionError {
                case .requiresRecentLogin(_), .userTokenExpired(_):
                    // TODO: re-auth
                    print(sessionError.displayError.title)
                    completion(.failure(sessionError))
                default:
                    completion(.failure(sessionError))
                }
            }
            completion(.success(true))
        })
    }
    
    public static func updatePasswordFacebookUser(password: String, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        guard
            let currentUser = Auth.auth().currentUser,
            let accessToken = FacebookManager.accessToken
        else {
            completion(.failure(SessionError.unknownError))
            return
        }
        
        let reauthCredential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        currentUser.reauthenticate(with: reauthCredential) { (authDataResult: AuthDataResult?, error: Error?) in
            if let err = error {
                completion(.failure(SessionError(error: err)))
                return
            }
            
            guard let result = authDataResult, result.user.uid == currentUser.uid else {
                completion(.failure(.unknownError))
                return
            }
            
            // Now we can update the password
            result.user.updatePassword(to: password, completion: { (error: Error?) in
                if let error = error {
                    completion(.failure(SessionError(error: error)))
                    return
                }
                
                CredentialManager.set(password: password)
                completion(.success(true))
            })
        }
    }
    
    /// Updates a user's password by first re-authenticating
    public static func update(request: UpdatePasswordRequest, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(SessionError.unknownError))
            return
        }
        
        let reauthCredential = EmailAuthProvider.credential(withEmail: request.emailAddress, password: request.existingPassword)
        currentUser.reauthenticate(with: reauthCredential) { (authDataResult: AuthDataResult?, error: Error?) in
            if let err = error {
                completion(.failure(SessionError(error: err)))
                return
            }
            
            guard let result = authDataResult, result.user.uid == currentUser.uid else {
                completion(.failure(.unknownError))
                return
            }
            
            // Now we can update the password
            result.user.updatePassword(to: request.newPassword, completion: { (error: Error?) in
                if let error = error {
                    completion(.failure(SessionError(error: error)))
                    return
                }
                
                CredentialManager.set(email: request.emailAddress, password: request.newPassword)
                completion(.success(true))
            })
            
        }
    }
    
    /// Updates a user's email by first reauthenticating
    public static func update(request: UpdateEmailRequest, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(SessionError.unknownError))
            return
        }
        
        // We need to reauth before being able to perform this change
        let reauthCredential = EmailAuthProvider.credential(withEmail: request.existingEmail, password: request.password)
        currentUser.reauthenticate(with: reauthCredential) { (authDataResult: AuthDataResult?, error: Error?) in
            if let err = error {
                completion(.failure(SessionError(error: err)))
                return
            }
            
            guard let result = authDataResult, result.user.uid == currentUser.uid else {
                completion(.failure(.unknownError))
                return
            }
            
            // Now we can update email
            result.user.updateEmail(to: request.newEmail, completion: { (error: Error?) in
                if let error = error {
                    completion(.failure(SessionError(error: error)))
                    return
                }
                
                CredentialManager.set(email: request.newEmail)
                completion(.success(true))
            })
        }
    }
    
    public static func update(first: String, last: String, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        
        let updateRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        updateRequest?.displayName = "\(first) \(last)"
    
        updateRequest?.commitChanges(completion: { (error) in
            if let error = error {
                let sessionError = SessionError(error: error)
                
                switch sessionError {
                case .requiresRecentLogin(_), .userTokenExpired(_):
                    // TODO: re-auth?
                    print(sessionError.displayError.title)
                    completion(.failure(sessionError))
                default:
                    completion(.failure(sessionError))
                }
            }
            completion(.success(true))
        })
    }
    
    public static func update(profileImageURL: URL?, completion: @escaping (IAResult<Bool, SessionError>) -> Void) {
        
        let updateRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        updateRequest?.photoURL = profileImageURL
        
        updateRequest?.commitChanges(completion: { (error) in
            if let error = error {
                let sessionError = SessionError(error: error)
                
                switch sessionError {
                case .requiresRecentLogin(_), .userTokenExpired(_):
                    // TODO: Re-Auth?
                    completion(.failure(sessionError))
                default:
                    completion(.failure(sessionError))
                }
            }
            completion(.success(true))
        })
    }

    /** Register's a guest as a new user
     
     - Note: Authentication state does not change when converting a user, so observers in the SessionManager will not
             automatically fire on this conversion. Instead, we post our own notification to handle this update.

     */
    public static func registerGuest(email: String, password: String, completion: @escaping (IAResult<AuthenticatedUser, SessionError>) -> Void) {
        // Make sure there is actually a guest logged in
        guard let guestUser = SessionManager.currentUser, guestUser.isAnonymous else {
            completion(.failure(SessionError.unknownError))
            return
        }
        
        let authProvider = EmailAuthProvider.credential(withEmail: email, password: password)
        guestUser.link(with: authProvider) { (authDataResult, error) in
            guard let authResult = authDataResult else {
                completion(.failure(SessionError(error: error)))
                return
            }
            CredentialManager.set(email: email, password: password)
            
            var user = AuthenticatedUser(with: authResult)
            user.updatePreviousGuestStatus(true)
            completion(.success(user))
        }
    }
    
    public static func unlinkFacebook(from userId: String, completion: @escaping (IAResult<AuthenticatedUser, SessionError>) -> Void ) {
        guard
            let currentUser = SessionManager.currentUser,
            currentUser.uid == userId,
            FacebookManager.isSessionActive
        else { return }
        
        let providerData = currentUser.providerData.filter {  $0.providerID.contains("facebook") }
        guard providerData.count > 0, let facebookProvider = providerData.first  else {
            let error = SessionError.noSuchProvider(DisplayableError(title: "Are you sure?", message: "Our robots are saying your account isn't managed by Facebook. If you're totally sure of it though, try unlinking your account later or reach out to our support for more help. 🤖"))
            print("There is no Facebook provider for requested unlinking \(String(describing: currentUser.displayName))")
            
            Track.track(displayableError: error.displayError, domain: ErrorType.Facebook.Subtype.unlinkFacebookFailed)
            completion(.failure(error))
            
            return
        }
    
        Auth.auth().currentUser?.unlink(fromProvider: facebookProvider.providerID, completion: { (user: _FirebaseUser?, error: Error?) in
            guard let user = user else {
                Track.track(error: error, domain: ErrorType.Facebook.Subtype.unlinkFacebookFailed)
                completion(.failure(SessionError(error: error)))
                return
            }
            Track.track(eventName: EventType.Facebook.disconnectedFromFacebook)
            
            let authUser = AuthenticatedUser(with: user)
            FacebookManager.logoutFacebook()
            completion(.success(authUser))
        })
    }
    
    public static func linkFacebook(with userId: String, in viewController: UIViewController, completion: @escaping (IAResult<AuthDataResult, SessionError>) -> Void) {
        guard
            let currentUser = SessionManager.currentUser,
            currentUser.uid == userId,
            !FacebookManager.isSessionActive
        else { return }
        
        FacebookManager.authorizeFacebook(in: viewController) { result in
            switch result {
            case .success(let facebookSession):
                let credential = FacebookAuthProvider.credential(withAccessToken: facebookSession.token)
                currentUser.link(with: credential, completion: { (authDataResult: AuthDataResult?, error: Error?) in
                    guard let authResult = authDataResult else {
                        let error = SessionError(error: error)
                        Track.track(displayableError: error.displayError, domain: ErrorType.Facebook.Subtype.unlinkFacebookFailed)
                        completion(.failure(error))
                        return
                    }
                    Track.track(eventName: EventType.Facebook.connectedToFacebook)
    
                    CredentialManager.set(session: facebookSession)
                    completion(.success(authResult))
                })
                
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Facebook.Subtype.unlinkFacebookFailed)
                completion(.failure(SessionError(error: error))) // TODO this will always return an unknown session error, format correctly for facebookerror
            }
        }
    }
    
}


