//
//  SessionService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/6/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Alamofire

enum SessionProvider {
    case facebook
}

class SessionService {
    
    // MARK: - Email Login
    
    public static func login(email: String, password: String, completion: @escaping (IAResult<AuthenticatedUser, SessionError>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult: AuthDataResult?, error: Error?) in
            guard let authResult = authResult else {
                completion(.failure(SessionError(error: error)))
                return
            }
            
            CredentialManager.set(email: email, password: password)
            completion(.success(AuthenticatedUser(with: authResult)))
        }
    }
    
    // MARK: - Facebook Login
    
    public static func login(facebookSession: FacebookSession, completion: @escaping (IAResult<AuthenticatedUser, SessionError>) -> Void) {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: facebookSession.token)
        Auth.auth().signIn(with: credential) { (authResult: AuthDataResult?, error: Error?) in
            guard let authResult = authResult else {
                completion(.failure(SessionError(error: error)))
                return
            }
            
            CredentialManager.set(session: facebookSession)
            completion(.success(AuthenticatedUser(with: authResult)))
        }
    }
    
    // MARK: - Guest Login
    
    public static func loginAsGuest(completion: @escaping (IAResult<AuthenticatedUser, SessionError>) -> Void) {
        
        Auth.auth().signInAnonymously { (authDataResult, error) in
            if let error = error {
                let err = SessionError(error: error)
                completion(.failure(err))
                return
            }
            
            guard let auth = authDataResult else {
                completion(.failure(SessionError.unknownError))
                return
            }
            
            completion(.success(AuthenticatedUser(with: auth)))
        }
        
    }
    
    // MARK: - Password Reset -
    
    public static func sendPasswordReset(to email: String, completion: @escaping(IAResult<Bool, SessionError>) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error: Error?) in
            if error != nil {
                completion(.failure(SessionError(error: error)))
                return
            }
            
            Track.track(eventName: EventType.Settings.resetPassword)
            completion(.success(true))
        }
    }
    
    // MARK: - Logout
    
    public static func logout() {
        guard Auth.auth().currentUser != nil else { return }
        
        do {
            try Auth.auth().signOut()
            CredentialManager.clearCredentials()
            
        } catch let signOutError {
            let error = SessionError(error: signOutError)
            print("An Error Occurred logging out: \(error.displayError.message)")
        }
        
        Track.track(eventName: EventType.Session.loggedOut)
        
        // TODO: is this needed?
        if FacebookManager.isSessionActive {
            FacebookManager.logoutFacebook()
        }
    }
}
