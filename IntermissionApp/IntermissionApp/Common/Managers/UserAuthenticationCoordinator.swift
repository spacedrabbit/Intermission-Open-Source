//
//  UserAuthenticationCoordinator.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Indicates what type of authorization attempt was made.
enum AuthIntent: String {
    case loginEmail,
    loginFacebook,
    loginGuest,
    registerGuestToUser,
    registerEmail,
    registerFacebook,
    loginObserved
}

class UserAuthCoordinator {
    weak var delegate: UserAuthCoordinatorDelegate?
    
    private var guestUserListener: Listener?
    private var userListener: Listener?
    
    // MARK: - Initialization
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLoggedIn(notification:)), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGuestUserLoggedIn(notification:)), name: .guestLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLoggedOut(notification:)), name: .userLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFacebookUserLogIn(notification:)), name: .facebookUserLoggedIn, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userLoggedIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: .guestLoggedIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userLoggedOut, object: nil)
        NotificationCenter.default.removeObserver(self, name: .facebookUserLoggedIn, object: nil)
    }
    
    // MARK: - Login
    
    /**
     This is specifically used to log in a user using their email/password from the Login screen
     */
    func login(email: String, password: String) {
        SessionService.login(email: email, password: password) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authenticatedUser):
                self.continueUserLogin(id: authenticatedUser.id, intent: .loginEmail)
                self.delegate?.userAuthCoordinator(self, didAuthenticate: authenticatedUser)
                
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginEmailFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginEmail, error: error.displayError)
            }
        }
    }
    
    func loginWithFacebook(in viewController: UIViewController) {
        FacebookManager.authorizeFacebook(in: viewController) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let facebookSession):
                SessionService.login(facebookSession: facebookSession) { result in
                    switch result {
                    case .success(let authenticatedUser):
                        authenticatedUser.isNewUser
                            ? self.continueUserRegistration(authenticatedUser: authenticatedUser)
                            : self.continueUserLogin(id: authenticatedUser.id, intent: .loginFacebook)
                    
                    case .failure(let error):
                        Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginFacebookFailed)
                        self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginFacebook, error: error.displayError)
                    }
                }
                
            case .failure(let error) where error == .cancelled: return
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginFacebookFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginFacebook, error: error.displayError)
            }
        }
    }
    
    /**
     This is specifically used to create a GuestUser and log them in if they decline registering to use the app
     */
    func loginGuest() {
        SessionService.loginAsGuest { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authenticatedUser):
                self.continueGuestLogin(guest: GuestUser(authenticatedUser))
                self.delegate?.userAuthCoordinator(self, didAuthenticate: authenticatedUser)
                
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginGuestFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginGuest, error: error.displayError)
            }
        }
    }
    
    // MARK: - Register
    
    /**
     This is specifically used to register a new user by their email and password
     */
    func registerUser(email: String, password: String) {
        UserService.createUser(email: email, password: password) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authenticatedUser):
                self.continueUserRegistration(authenticatedUser: authenticatedUser)
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Register.Subtype.userEmailRegistrationFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .registerEmail, error: error.displayError)
            }
        }
    }
    
    func registerGuest(_ guest: GuestUser, email: String, password: String) {
        UserService.registerGuest(email: email, password: password) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authenticatedUser):
                self.continueGuestRegistration(guest: guest, authenticatedUser: authenticatedUser)
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Register.Subtype.guestConvertToUserFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .registerGuestToUser, error: error.displayError)
            }
        }
    }
    
    /// This is the same as `loginWithFacebook(in:)` but we add this convenience for semantic clarity
    func registerUserWithFacebook(in viewController: UIViewController) {
        self.loginWithFacebook(in: viewController)
    }
    
    // MARK: - Notification Handling
    
    /**
     Specifically handles cases where auth changes are observed by Firebase. This should happen on:
        - App launch & a stored user session exists
     */
    @objc
    private func handleUserLoggedIn(notification: Notification) {
        guard let authUser = notification.userInfo?[SessionKey.userObjectKey] as? AuthenticatedUser else { return }
        continueUserLogin(id: authUser.id, intent: .loginObserved)
    }
    
    @objc
    private func handleFacebookUserLogIn(notification: Notification) {
        guard let authUser = notification.userInfo?[SessionKey.userObjectKey] as? AuthenticatedUser else { return }
        continueFacebookLogin(user: authUser)
    }
    
    /**
     Specifically handles cases where the auth changes are observed by Firebase. This should happen on:
        - App launch & a stored guest session exists
     */
    @objc
    private func handleGuestUserLoggedIn(notification: Notification) {
        guard let guestUser = notification.userInfo?[SessionKey.guestUserKey] as? GuestUser else { return }
        continueGuestLogin(guest: guestUser)
    }
    
    @objc
    private func handleUserLoggedOut(notification: Notification) {
        self.delegate?.userAuthCoordinatorDidLogout(self, user: nil, guest: nil)
    }
    
    // MARK: - Helpers

    private func continueUserLogin(id: String, intent: AuthIntent) {
        DatabaseService.getUser(id) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                Track.configure(with: user)
                Track.track(eventName: EventType.Session.loggedIn)
                
                self.delegate?.userAuthCoordinator(self, didLoginUser: user)
            case .failure(let error):
                // TODO: facebook login attempts route through here, need to differentiate
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.authenticationFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: intent, error: error.displayError)
            }
        }
    }
    
    private func continueFacebookLogin(user: AuthenticatedUser) {
        DatabaseService.getUser(user.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.delegate?.userAuthCoordinator(self, didLoginUser: user)
            
            // This is potentially dangerous, because it will add a new user record for a facebook-authed user if
            // an account is not returned by `getUser`. We may come into an interesting state if the DatabaseService
            // returns no user for an account id due to a time out or other issue, and we create a duplicate account.
            // May need to either remove this functionality entirely, in which case there needs to be UI handling so that
            // an empty RootVC doesn't occur. Alternatively, we may need a cloud function to merge duplicate accounts.
            case .failure(let error) where error == .noResults:
                self.userListener = DatabaseService.addNew(user: user, completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let user):
                        Track.configure(with: user)
                        Track.track(eventName: EventType.Session.loggedIn)
                        
                        self.delegate?.userAuthCoordinator(self, didLoginUser: user)
                    case .failure(let error):
                        Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginFacebookFailed)
                        self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .registerFacebook, error: error.displayError)
                    }
                    
                    self.userListener?.remove()
                    self.userListener = nil
                })
                
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginFacebookFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginFacebook, error: error.displayError)
            }
        }
        
    }
    
    private func continueGuestLogin(guest: GuestUser) {
        self.guestUserListener = DatabaseService.addNew(guest: guest, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let guestUser):
                Track.configure(with: guestUser)
                Track.track(eventName: EventType.Session.loggedIn)
                
                self.delegate?.userAuthCoordinator(self, didLoginGuest: guestUser)
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Auth.Subtype.loginGuestFailed)
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .loginGuest, error: error.displayError)
            }
            
            self.guestUserListener?.remove()
            self.guestUserListener = nil
        })
    }
    
    private func continueUserRegistration(authenticatedUser: AuthenticatedUser) {
        self.userListener = DatabaseService.addNew(user: authenticatedUser, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                Track.configure(with: user)
                Track.track(eventName: EventType.Session.signedUp)
                
                self.delegate?.userAuthCoordinator(self, didRegister: user)
            case .failure(let error):
                Track.track(displayableError: error.displayError, domain: ErrorType.Register.Subtype.userEmailRegistrationFailed)
                
                self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .registerEmail, error: error.displayError)
            }
            
            self.userListener?.remove()
            self.userListener = nil
        })
        
    }
    
    private func continueGuestRegistration(guest: GuestUser, authenticatedUser: AuthenticatedUser) {
        self.userListener = DatabaseService.addNew(user: authenticatedUser, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
                case .success(let user):
                    Track.configure(with: user)
                    Track.track(eventName: EventType.Session.guestConvertedToUser)
                    
                    // Transfer video history as a last step. Doesn't display errors on failure
                    self.transferHistory(from: guest, to: user, completion: { _ in
                        self.delegate?.userAuthCoordinator(self, didRegister: guest, as: user)
                    })
                
                case .failure(let error):
                    Track.track(displayableError: error.displayError, domain: ErrorType.Register.Subtype.guestConvertToUserFailed)
                    
                    self.delegate?.userAuthCoordinator(self, didFailAuthenticationIntent: .registerGuestToUser, error: error.displayError)
            }
            
            self.userListener?.remove()
            self.userListener = nil
        })
    }
    
    private func transferHistory(from guest: GuestUser, to newUser: User, completion: @escaping (Bool) -> Void) {
        DatabaseService.transferHistory(from: guest.id, to: newUser.id) { [weak self] (result) in
            guard let _ = self else { return }
            switch result {
            case .success(_) :
                completion(true)
            case .failure(let error):
                // Don't display an error for this, but log it for tracking
                Track.track(error: error, domain: ErrorType.Database.Subtype.transferHistory)
                completion(false)
            }
        }
    }
}

/// Handles all authentication-related changes.
protocol UserAuthCoordinatorDelegate: class {
    
    /// Indicates that a user was authenticated through the Firebase Auth API, but not necessarily in the FirestoreDB
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didAuthenticate authenticatedUser: AuthenticatedUser)
    
    /// Indicates that a user did login via email/pass or Facebook
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didLoginUser user: User)
    
    /// Indicates that a guest user has been created and logged in
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didLoginGuest guest: GuestUser)
    
    /// Indications that a guest session has been converted into a full user session
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didRegister guest: GuestUser, as user: User)
    
    /// Used to indicate that a new user has been registered by email/password
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didRegister user: User)
    
    /// Monitors all authentication failures. Use the `intent` in determining how to handle the error
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didFailAuthenticationIntent intent: AuthIntent, error: DisplayableError)
    
    /// Indicates a session has been ended for either a user or guest
    func userAuthCoordinatorDidLogout(_ userAuthCoordinator: UserAuthCoordinator, user: User?, guest: GuestUser?)
    
}
