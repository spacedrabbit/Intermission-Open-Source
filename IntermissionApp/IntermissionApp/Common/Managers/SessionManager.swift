//
//  SessionManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/25/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseAuth

/// Typealias to prevent firebase auth api from leaking across the app.
/// Used in observing state changes from a ViewController. Only call from RootVC
public typealias SessionAuthListener = AuthStateDidChangeListenerHandle

/// Typealias to prevent firebase auth api from leaking across the app.
/// Used in observing state changes from a ViewController. Only call from RootVC
public typealias SessionStateChangeHandler = AuthStateDidChangeListenerBlock

/// Typealias to prevent firebase auth api from leaking across the app.
/// Used in observing state changes from a ViewController. Only call from RootVC
public typealias _FirebaseAuth = FirebaseAuth.Auth

/// Typealias to prevent firebase auth api from leaking across the app.
/// Used in observing state changes from a ViewController. Only call from RootVC
public typealias _FirebaseUser = FirebaseAuth.User

final class SessionManager {
    
    static let shared: SessionManager = SessionManager()
    
    private var authenticationListener: SessionAuthListener?
    private var authenticationChangeHandler: SessionStateChangeHandler
    private (set) var isObservingCurrentSession: Bool = false
    
    private init() {
        authenticationChangeHandler = { SessionManager.handleAuthStateDidChange(auth: $0, user: $1) }
        
        // On init, check if we have a previous session available. If we do, add our auth state observer to handle login
        authenticationListener = SessionManager.sessionExists
            ? SessionManager.addSessionListener(with: authenticationChangeHandler)
            : nil
    }
    
    private static func handleAuthStateDidChange(auth: _FirebaseAuth, user: _FirebaseUser?) {
        if let authUser = auth.currentUser {
            // Short circuit if we have a facebook account
            if let providerData = authUser.providerData.first, providerData.providerID.contains("facebook") {
                NotificationCenter.default.post(name: .facebookUserLoggedIn, object: nil, userInfo: [SessionKey.userObjectKey : AuthenticatedUser(with: authUser)])
                return
            }
            
            // Check for an existing guest/user session
            authUser.isAnonymous
                ? NotificationCenter.default.post(name: .guestLoggedIn, object: nil, userInfo: [SessionKey.guestUserKey : GuestUser(authUser)])
                : NotificationCenter.default.post(name: .userLoggedIn, object: nil, userInfo: [SessionKey.userObjectKey : AuthenticatedUser(with: authUser)])
        } else {
            // TODO: if guest logs out, destroy their local/remote data
            NotificationCenter.default.post(name: .userLoggedOut, object: nil, userInfo: nil)
        }
    }
    
    static func beginSessionObserving() {
        guard SessionManager.shared.authenticationListener == nil else {
            print("Session Listener already active")
            return
        }
        SessionManager.shared.authenticationListener = SessionManager.addSessionListener(with: SessionManager.shared.authenticationChangeHandler)
    }
    
    static func endSessionObserving() {
        guard let listener = SessionManager.shared.authenticationListener else {
            print("Session Listener doesn't exist, cannot end observation")
            return
        }
        SessionManager.removeSessionListener(listener)
    }
    
    private static func addSessionListener(with handler: @escaping SessionStateChangeHandler) -> SessionAuthListener {
        return Auth.auth().addStateDidChangeListener(handler)
    }
    
    private static func removeSessionListener(_ listener: SessionAuthListener) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    class var sessionExists: Bool {
        return Auth.auth().currentUser != nil
    }
    
    class var currentUser: _FirebaseUser? {
        return Auth.auth().currentUser
    }
    
    class var guestSessionExists: Bool {
        return Auth.auth().currentUser?.isAnonymous ?? false
    }
    
    class var guestUser: _FirebaseUser? {
        guard SessionManager.guestSessionExists else { return nil }
        return Auth.auth().currentUser
    }
    
    /** Do anything required for first launch preparation
     */
    class func prepare() {
        _ = SessionManager.shared
    }
}

extension Notification.Name {
    static let userLoggedIn = Notification.Name("com.session.ia.userLoggedIn")
    static let userLoggedOut = Notification.Name("com.session.ia.userLoggedOut")
    static let guestLoggedIn = Notification.Name("com.session.ia.guestUserLoggedIn")
    static let guestConvertedToUser = Notification.Name("com.session.ia.guestConvertedToUser")
    static let facebookUserLoggedIn = Notification.Name("com.session.ia.facebookUserLoggedIn")
    
    static let loginFailed = Notification.Name("com.session.ia.loginFailed")
    static let guestLoginFailed = Notification.Name("com.session.ia.guestLoginFailed")
}

struct SessionKey {
    static let firebaseAuthKey: String = "com.session.ia.firebaseAuthKey"
    static let firebaseUserKey: String = "com.session.ia.firebaseUserKey"
    static let firstSessionKey: String = "com.session.ia.firstSessionKey"
    
    static let guestUserKey: String = "com.session.ia.guestUserKey"
    static let userObjectKey: String = "com.sessions.ia.userObjectKey"
    
    static let loginSuccessKey: String = "com.session.ia.loginSuccessKey"
    static let loginFailureKey: String = "com.session.ia.loginFailureKey"
    static let loginResultKey: String = "com.session.ia.loginResultKey"
}
