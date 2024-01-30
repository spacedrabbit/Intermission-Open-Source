//
//  UserDataCoordinator.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// TODO: Handle multiple simultaneous requests -
// This may not be quite so easy if we're using listeners to be able to send back data from
// writes immediately after performing the write. We could try to define a block handler
// that's able to get the latest intent made and that fires from the listener.
// In that case, we don't destroy or detach the listener after performing an update.
// Instead we call the delegate methods for success or failure from block handler

/** Used to coordinate updates to a user's data. Handled interation between the Firebase Auth
 and the FirestoreDB
 
 - Note: Unlike the UserAuthCoordinator which must manage notifications coming from the SessionManager (aka. Firebase),
 it is intentional that you instantiate this coordinator as needed since changes should be local.
 
 - Note: Because we only make use of a single reference to a Listener object for each request, care must be taken not to fire multiple of these requests. You need to ensure that only one request is in flight at a time.
 */
class UserDataCoordinator {
    weak var delegate: UserDataCoordinatorDelegate?

    private var userUpdateListener: Listener?

    init() {}
    
    // MARK: - Name
    
    func updateUser(_ id: String, firstName: String, lastName: String) {
        let intent = UserUpdateIntent.username(firstName, lastName)
        
        UserService.update(first: firstName, last: lastName) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
    }
    
    func updateUser(_ id: String, email: String, existingEmail: String? = nil, password: String? = nil) throws {
        let intent = UserUpdateIntent.email(email)

        let updateRequest = try UpdateEmailRequest(newEmail: email, existingEmail: existingEmail, password: password)
        
        UserService.update(request: updateRequest) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }


    }
    
    func updateUser(_ id: String, email: String, newPassword: String, existingPassword: String) throws {
        let intent = UserUpdateIntent.password(newPassword)
        let updateRequest = try UpdatePasswordRequest(newPassword: newPassword, emailAddress: email, existingPassword: existingPassword)
        
        UserService.update(request: updateRequest) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
    }
    
    func updateUser(_ id: String, profileImageUrl: URL) {
        let intent = UserUpdateIntent.profileImage(profileImageUrl)
        
        UserService.update(profileImageURL: profileImageUrl) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
    }
    
    func removeUserProfileImage(_ id: String) {
        let intent = UserUpdateIntent.deleteProfileImage
        
        UserService.update(profileImageURL: nil) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
        
    }
    
    func updateUserOnboarded(_ id: String, profileImageUrl: URL) {
        let intent = UserUpdateIntent.profileImageAndOnboarding(profileImageUrl)
        
        UserService.update(profileImageURL: profileImageUrl) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
    }
    
    func updateUserLinkingFacebook(_ id: String, inViewController vc: UIViewController) {
        
        UserService.linkFacebook(with: id, in: vc) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authResult):
                // TODO: this authResult would have info coming from facebook... do we want to replace the user's current
                // info with what's sent from Facebook? i.e their profile image/name/email?
                let intent = UserUpdateIntent.providerId(authResult.user.providerID)
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: .providerId("Unknown"), error: error.displayError)
            }
        }
    }
    
    func updateUserUnlinkingFacebook(_ id: String) {
        
        
        UserService.unlinkFacebook(from: id) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let authUser):
                
                /** A nil providerID would be a weird state. Theoretically, unlinking facebook should let you log in via password. So the returned auth user
                 should have "password" now listed as their provider. I don't think there
                 would be any negative side effects (as of this writing), their DB record
                 would just have a Null value for their provider id. But nothing in the
                 app depends or checks on that value. So, theoretically if they were to
                 link a different provider in the future, it would jsut update correctly
                 at tthat point. /shrug
                 */
                guard let provider = authUser.providerID else {
                    let displayError = DisplayableError(title: "Well, that was odd.", message: "We were able to unlink your facebook account, but our robots weren't able to clean up after themselves. This should be taken care of automatically on its own, but if you have issues logging in without facebook in the future, let our support team know")
                    self.delegate?.userDataCoordinator(self, didFailUpdate: UserUpdateIntent.providerId("No Provider Id"), error: displayError)
                    return
                }
                let intent = UserUpdateIntent.providerId(provider)
                self.continueUserUpdateRequest(id, intent: intent)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: UserUpdateIntent.providerId("Unknown"), error: error.displayError)
            }
        }
        
    }
    
    
    func updateUser(_ id: String, isPro: Bool) {
        let intent = UserUpdateIntent.isPro(isPro)
        continueUserUpdateRequest(id, intent: intent)
    }
    
    func updateUser(_ id: String, onboarded: Bool) {
        let intent = UserUpdateIntent.onboarded(onboarded)
        continueUserUpdateRequest(id, intent: intent)
    }
    
    // MARK: - Helpers -
    
    /// This retrieves the User's database record to reconcile it with the changes made to the Auth record
    private func continueUserUpdateRequest(_ userId: String, intent: UserUpdateIntent) {
        DatabaseService.getUser(userId) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.routeRequest(intent: intent, user: user)
            
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
        }
    }
    
    // Uses the intent to properly update a request object before sending out the request
    private func routeRequest(intent: UserUpdateIntent, user: User) {
        var request = UpdateUserRequest(user: user)
        
        switch intent {
        case .username(let first, let last) :
            request.update(first: first, last: last)
            
        case .email(let email):
            request.updateEmail(email)
        
        case .profileImage(let imageUrl):
            request.updateProfile(url: imageUrl)
            
        case .providerId(let provider):
            request.updateProviderId(provider)
            
        // A password update doesn't require any DB changes
        case .password(_):
            self.delegate?.userDataCoordinator(self, didCompleteUpdate: intent, forUser: user)
            return
            
        case .onboarded(let wasOnboarded):
            request.updateOnboardingStatus(wasOnboarded)
            
        case .isPro(let isPro):
            request.updateProStatus(isPro)
            
        case .profileImageAndOnboarding(let imageUrl):
            request.updateOnboardingStatus(true)
            request.updateProfile(url: imageUrl)
            
        case .deleteProfileImage:
            request.updateProfile(url: nil)
        }
        
        // Note: Owners of this instance will update their views using the delegate calls
        // Any other views needing to refresh user data will need to do so via notifications
        // being send from the DatabaseService calls
        userUpdateListener = DatabaseService.updateUser(request) { (result) in
            switch result {
            case .success(let updatedUser):
                self.delegate?.userDataCoordinator(self, didCompleteUpdate: intent, forUser: updatedUser)
                
            case .failure(let error):
                self.delegate?.userDataCoordinator(self, didFailUpdate: intent, error: error.displayError)
            }
            
            self.userUpdateListener?.remove()
            self.userUpdateListener = nil
        }
    }
    
}

// MARK: - UserDataCoordinatorDelegate Protocol -

protocol UserDataCoordinatorDelegate: class {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User)
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError)
    
}

/// Used to describe the kind of update happening
enum UserUpdateIntent {
    // These 4 cases require coordination with FirebaseAuth and so the requests are more complicated
    case username(String, String)
    case email(String)
    case profileImage(URL)
    case password(String)
    case providerId(String)
    case deleteProfileImage
    
    // These dont require communication with FirebaseAuth and so the requests are simpler
    case onboarded(Bool)
    case isPro(Bool)
    
    // This is a special case
    case profileImageAndOnboarding(URL)
}
