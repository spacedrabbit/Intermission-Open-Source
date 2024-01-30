//
//  RootViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/25/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

/// Typealias for a closure that takes Void and returns Void () -> Void
typealias EmptyCompletion = ()->Void

/**
 The base `ViewController` containing and managing all other view controllers. You can assume `RootViewController` will always be in the hierarchy.
 */
class RootViewController: SwitchViewController {
    public var viewController = UIViewController()
    private let userAuthCoordinator = UserAuthCoordinator()

    // This returns a new instance each time we need a loginVC
    private var loginController: LoginViewController {
        let loginVC = LoginViewController()
        loginVC.loginDelegate = self
        return loginVC
    }
    
    private var homeTabController: HomeTabBarController?
    private let tutorialController = TutorialViewController()
    private var onboardingFlowNavController: NavigationController?
    
    private let loadingController: LoadingViewController = {
        let viewController = LoadingViewController()
        viewController.view.backgroundColor = .white
        return viewController
    }()
    
    private struct ControllerKey {
        static let login = "login"
        static let home = "home"
        static let tutorial = "tutorial"
        static let onboarding = "onboarding"
        static let loading = "loading"
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        userAuthCoordinator.delegate = self
        tutorialController.tutorialDelegate = self
        
        self.add(viewController: loadingController, as: ControllerKey.loading)
        self.switchTo(identifier: ControllerKey.loading)

        if SessionManager.guestSessionExists {
            // Notifications should handle the login process. Display the a blocking, opaque UI until then
            loadingController.loadingState()
        } else if SessionManager.sessionExists {
            // Notifications should handle the login process. Display the a blocking, opaque UI until then
            loadingController.loadingState()
        } else {
            self.add(viewController: tutorialController, as: ControllerKey.tutorial)
            self.switchTo(identifier: ControllerKey.tutorial)
            
            loadingController.readyState()
        }
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalLoginRequested(notification:)), name: .didRequestModalLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDashboardFinishedLoading), name: .dashboardDidFinishLoading, object: nil)
    }
    
    override func reload() {
        super.reload() // This will call reload() on each managed VC
    }

    // MARK: - View Controller Management
    
    func set(viewController: UIViewController, completion: EmptyCompletion?) {
        
        if let child = self.children.first {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.frame
        viewController.didMove(toParent: self)
        self.viewController = viewController
        
        completion?()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIScreen.main.bounds
    }
    
    // MARK: - Helpers
    
    private func dismissModals() {
        if let modalVC = self.presentedViewController {
            modalVC.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Notifications
    
    @objc
    private func handleModalLoginRequested(notification: Notification) {
        guard
            let requestingVC = notification.object as? ViewController,
            let userInfo = notification.userInfo,
            let loginOption = userInfo[ModalLoginKeys.authenticationOption] as? String
        else { return }
        
        // If the Root is currently managing a LoginVC, remove that instance
        self.remove(viewControllerWithId: ControllerKey.login)
        
        // Create a new instance via the getter property
        let loginVC = loginController
        
        // Make sure it doesn't belong to any other controller (sanity)
        guard loginVC.parent == nil else { return }
        
        if loginOption == ModalLoginValues.login {
            loginVC.markDeferredSwitchToLogin()
        }
        
        // If we got here as a result of an Alert modal (as is with guest sign up from the VCP), dismiss it first
        if let presenting = requestingVC.presentedViewController as? AlertViewController {
            presenting.dismiss(animated: true) {
                requestingVC.present(NavigationController(rootViewController: loginVC), animated: true, completion: nil)
            }
        } else {
            // Present this new instance
            requestingVC.present(NavigationController(rootViewController: loginVC), animated: true, completion: nil)
        }
        
    }
    
    @objc
    private func handleDashboardFinishedLoading() {
        loadingController.readyState()
    }
    
    // MARK: - Routing
    
    private func proceedToOnboarding(_ user: User) {
        let nameOnboardingController = OnboardingUserNameViewController(with: user)
        self.onboardingFlowNavController = NavigationController(rootViewController: nameOnboardingController)
        self.onboardingFlowNavController?.showNavButtonsWhenBarIsHidden = false
        nameOnboardingController.onboardingDelegate = self
        
        guard let onboarding = onboardingFlowNavController else { fatalError() } // sanity, TODO
        dismissModals()
        
        Track.track(eventName: EventType.Onboarding.startedOnboarding)
        self.add(viewController: onboarding, as: ControllerKey.onboarding)
        self.switchTo(identifier: ControllerKey.onboarding)
    }
    
    private func proceedToHome(_ user: User) {
        self.homeTabController = HomeTabBarController(with: user)
        guard let home = homeTabController else { fatalError() } // sanity, TODO
        dismissModals()
        
        self.add(viewController: home, as: ControllerKey.home)
        self.switchTo(identifier: ControllerKey.home)
    }

    private func proceedToHome(_ guest: GuestUser) {
        self.homeTabController = HomeTabBarController(with: guest)
        guard let home = homeTabController else { fatalError() } // sanity, TODO
        self.tutorialController.hideActivity() // When loggin in as guest, we need to stop the activity on the tutorial view
        
        dismissModals()

        self.add(viewController: home, as: ControllerKey.home)
        self.switchTo(identifier: ControllerKey.home)
    }
    
    // MARK: - Manager Configs
    
    private func configureManagers(_ user: User) {
        FavoritesManager.configure(user: user)
        VideoHistoryManager.configure(user: user)
    }
    
}

// MARK: - LoginViewControllerDelegate -

extension RootViewController: LoginViewControllerDelegate {
    
    func loginViewControllerDidRequestLogin(_ loginViewController: LoginViewController, email: String, password: String) {
        userAuthCoordinator.login(email: email, password: password)
    }
    
    func loginViewControllerDidRequestGuestLogin(_ loginViewController: LoginViewController) {
        userAuthCoordinator.loginGuest()
    }
    
    func loginViewControllerDidRequestFacebookLogin(_ loginViewController: LoginViewController) {
        userAuthCoordinator.loginWithFacebook(in: loginViewController)
    }
    
    func loginViewControllerDidRequestRegisterUser(_ loginViewController: LoginViewController, email: String, password: String) {
        userAuthCoordinator.registerUser(email: email, password: password)
    }
    
    func loginViewControllerDidRequestRegisterGuest(_ loginViewController: LoginViewController, guest: GuestUser, email: String, password: String) {
        userAuthCoordinator.registerGuest(guest, email: email, password: password)
    }
    
}

// MARK: - TutorialViewControllerDelegate -

extension RootViewController: TutorialViewControllerDelegate {
    
    func tutorialViewControllerDidTapLoginSignup(_ tutorialViewController: TutorialViewController) {
        // Remove the instance of the LoginVC if it was added to the Root at some point
        self.remove(viewControllerWithId: ControllerKey.login)
        
        // Create a new instance of LoginVC
        let loginVC = loginController
        
        // Make sure it doesn't belong to another VC (sanity)
        guard loginVC.parent == nil else { return }
        
        // Present the new instance
        self.present(NavigationController(rootViewController: loginVC), animated: true, completion: nil)
    }
    
    func tutorialViewControllerDidTapContinueAsGuest(_ tutorialViewController: TutorialViewController) {
        tutorialViewController.showActivity()
        userAuthCoordinator.loginGuest()
    }

}

// MARK: - OnboardViewControllerDelegate -

extension RootViewController: OnboardingDelegate {
    
    func onboardingDelegate(_ onboardingViewController: OnboardingUserNameViewController, didUpdateNameForUser user: User) {
        Track.track(eventName: EventType.Onboarding.startedOnboarding, user: user)
        
        let dtvc = OnboardingProfileImageController(with: user, delegate: onboardingViewController.onboardingDelegate)
        onboardingViewController.navigationController?.pushViewController(dtvc, animated: true)
    }
    
    func onboardingDelegate(_ onboardingViewController: OnboardingProfileImageController, didUploadProfileImage url: URL, user: User) {
        Track.track(eventName: EventType.Onboarding.uploadedProfilePicture, user: user)
    }
    
    func onboardingDelegate(_ onboardingViewController: OnboardingProfileImageController, didSkipProfileImageUpload user: User) {
        Track.track(eventName: EventType.Onboarding.skippedProfilePicture, user: user)
    }
    
    func onboardingDelegatedidFinishRegistering(user: User) {
        Track.track(eventName: EventType.Onboarding.finishedOnboarding, user: user)
        
        configureManagers(user)
        proceedToHome(user)
    }
    
}

// MARK: - UserAuthCoordinatorDelegate -

extension RootViewController: UserAuthCoordinatorDelegate {
    
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didAuthenticate authenticatedUser: AuthenticatedUser) {
        // Right now we don't need to handle anything related to the AuthenticatedUser, it's an intermediary step in the auth process
    }
    
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didLoginUser user: User) {
        if !user.wasOnboarded {
            proceedToOnboarding(user)
            loadingController.readyState()
        }
        else { proceedToHome(user) }
    
        configureManagers(user)
        
        // Managing Observers
        SessionManager.beginSessionObserving()
        
        // Last step is to reveal the updated UI by dismissing any modals observing the login event
        NotificationCenter.default.post(name: .loginRequestDidSucceed, object: nil)
    }
    
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didLoginGuest guest: GuestUser) {
        proceedToHome(guest)
        
        // Managing Observers
        SessionManager.beginSessionObserving()
        
        // Last step is to reveal the updated UI by dismissing any modals observing the login event
        NotificationCenter.default.post(name: .loginRequestDidSucceed, object: nil)
    }

    // TODO: if a guest was converted to a user, there's a chance they were in the middle of something, like favoriting
    // a video. we should take this into account in order to present them the last thing they were doing before signing up.
    // Right now, this will have to stay as is.
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didRegister guest: GuestUser, as user: User) {
        if !user.wasOnboarded { proceedToOnboarding(user) }
        else { proceedToHome(user) }
    
        configureManagers(user)
        
        // Mananging Observers
        SessionManager.beginSessionObserving()
        
        // Last step is to reveal the updated UI by dismissing any modals observing the login event
        NotificationCenter.default.post(name: .loginRequestDidSucceed, object: nil)
    }
    
    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didRegister user: User) {
        if !user.wasOnboarded { proceedToOnboarding(user)
        } else { proceedToHome(user) }
        
        configureManagers(user)

        // Managing Observers
        SessionManager.beginSessionObserving()
        
        // Last step is to reveal the updated UI by dismissing any modals observing the login event
        NotificationCenter.default.post(name: .loginRequestDidSucceed, object: nil)
    }
    
    func userAuthCoordinatorDidLogout(_ userAuthCoordinator: UserAuthCoordinator, user: User?, guest: GuestUser?) {
        tutorialController.reset()
        
        self.add(viewController: tutorialController, as: ControllerKey.tutorial)
        self.switchTo(identifier: ControllerKey.tutorial)
        
        CredentialManager.clearCredentials()
        
        FavoritesManager.teardown()
        VideoHistoryManager.teardown()
        self.homeTabController = nil
        
        SessionManager.endSessionObserving()
        SessionService.logout() // Takes care of logging out of facebook as well
        
        NotificationCenter.default.post(name: .didFinishLogout, object: nil)
    }

    func userAuthCoordinator(_ userAuthCoordinator: UserAuthCoordinator, didFailAuthenticationIntent intent: AuthIntent, error: DisplayableError) {
        // TODO: figure out wtf to do with this.. might be best (in terms of consistency to rip this attempt to hide modals out and replace it with using Notifications or intercepting the responder chain.
        
        // This is a preferential order of checking which view controller is currenly on top to present error alerts.
        // It might also be an option to simply pass back a reference to the login controller and present the alert on it directly...
        /*
        if let topVC = self.viewController.iaNavigationController?.topViewController {
            topVC.presentAlert(with: error)
        } else if let modalVC = self.presentedViewController {
            modalVC.presentAlert(with: error)
        } else if let loginVC = self.viewController(for: ControllerKey.login) {
            // In this case, the LoginVC is being managed by the Root, rather than presented modally
            loginVC.presentAlert(with: error)
        } else {
            self.viewController.presentAlert(with: error)
        }*/
        
        NotificationCenter.default.post(name: .loginRequestDidFail, object: nil,
                                        userInfo: [LoginControllerStateKeys.requestIntent: intent,
                                                   LoginControllerStateKeys.requestError : error ])

        // TODO: check if we need special cases for logged in w/ email and then registering with a new provider
        // Decide what needs to happen depending on the intent
        switch intent {
        case .registerGuestToUser: return // We dont need to end observing in this case
        default: SessionManager.endSessionObserving()
        }
    }

}

// MARK: - Notification.Name -

extension Notification.Name {
    
    static let didRequestModalLogin = Notification.Name(rawValue: "com.ia.root.didRequestModalLogin")
    static let didFinishLogout = Notification.Name(rawValue: "com.ia.root.didFinishLogout")
    
}

struct ModalLoginKeys {
    
    static let authenticationOption = "authenticationOption"
    
}

struct ModalLoginValues {
    
    static let signup = "sign_up"
    static let login = "log_in"
    
}
