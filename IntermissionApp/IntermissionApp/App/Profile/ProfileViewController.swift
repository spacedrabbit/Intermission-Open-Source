//
//  ProfileViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/30/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: ViewController {
    private var user: User?
    private var guest: GuestUser?
    private var imageManager: ImageManager? = ImageManager()
    private let userDataCoordinator = UserDataCoordinator()

    private let safeAreaCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .navBarGreen
        return view
    }()
    
    private let profileHeaderView: ProfileHeaderView = ProfileHeaderView()
    private let pagingAnimatedBarView: PagingAnimatedBarView = PagingAnimatedBarView(barAttributes: .default)
    private let statsView  = StatsView()
    private let journeyView = JourneyView()

    private var guestProfileView: GuestProfileView?
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        profileHeaderView.configure(with: user)
        
        // Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdated(notification:)), name: .userInfoUpdateSuccess, object: nil)
        
        commonInit()
    }
    
    init(guest: GuestUser) {
        self.guest = guest
        super.init(nibName: nil, bundle: nil)
    
        guestProfileView = GuestProfileView(guest: guest)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.view.backgroundColor = .white
        self.tabBarItem = UITabBarItem(title: "Profile", image: TabIcon.profile.inactive, selectedImage: TabIcon.profile.active)
        self.isNavigationBarHidden = true
        self.title = "Profile"
        
        reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileHeaderView.delegate = self
        journeyView.delegate = self
        statsView.delegate = self
        
        self.view.addSubview(safeAreaCoverView)
        self.view.addSubview(profileHeaderView)
        self.view.addSubview(pagingAnimatedBarView)
        
        guestStateCheck()
        
        self.userDataCoordinator.delegate = self
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // This is strictly to cover the status bar/notch area with a green background
        safeAreaCoverView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.w, height: self.view.safeAreaInsets.top)
        profileHeaderView.frame = CGRect(x: 0.0, y: safeAreaCoverView.y + safeAreaCoverView.h, width: self.view.w, height: ProfileHeaderView.requiredContentHeight)
        
        // The PagingAnimatedBarView expects that the views it's passed have set their own h/w. So we need to explicitly set the frames for the stats/journey views here.
        statsView.frame.size = CGSize(width: self.view.w, height: self.view.safeAreaLayoutGuide.layoutFrame.h - profileHeaderView.h - safeAreaCoverView.h)
        journeyView.frame.size = CGSize(width: self.view.w, height: self.view.safeAreaLayoutGuide.layoutFrame.h - profileHeaderView.h - safeAreaCoverView.h)
        
        let pageItems: [PageBarItem] = [PageBarItem(labelText: "MY STATS", page: statsView), PageBarItem(labelText: "MY JOURNEY", page: journeyView)]
        pagingAnimatedBarView.configure(pageBarItems: pageItems,
                                        inset: .zero,
                                        targetWidth: self.view.w,
                                        maxVisibleHeight: self.view.safeAreaLayoutGuide.layoutFrame.h - profileHeaderView.h)
        pagingAnimatedBarView.frame = CGRect(x: 0.0, y: profileHeaderView.y + profileHeaderView.h, width: self.view.w, height: pagingAnimatedBarView.h)
        pagingAnimatedBarView.selectBarItem(at: 0, animated: false)
        
        // If we have a guestProfileView, lay it out such that the top lines up with the safeAreaInset, and the rest is flush to the edges
        if let guestProfileView = self.guestProfileView, guest != nil {
            guestProfileView.frame = CGRect(x: 0.0, y: self.view.safeAreaInsets.top, width: self.view.w, height: self.view.safeAreaLayoutGuide.layoutFrame.h)
        }
    }
    
    private func guestStateCheck() {
        if let guestProfileView = self.guestProfileView, guest != nil {
            guestProfileView.isHidden = false
            guestProfileView.delegate = self
            self.view.addSubview(guestProfileView)
        } else {
            self.guestProfileView?.isHidden = true
            self.guestProfileView?.delegate = nil
            self.guestProfileView?.removeFromSuperview()
        }
    }
    
    // MARK: - Reload
    
    override func reload() {
        guestStateCheck()
        
        guard let user = self.user else { return }
        self.state = .loading
        
        DatabaseService.getHistory(for: user) { [weak self] result in
            switch result {
            case .success(let videoEntries):
                self?.journeyView.configure(with: videoEntries)
            case .failure(let error):
                self?.presentAlert(with: error.displayError)
            }
            
            self?.state = .ready
        }
    }
    
    // MARK: - Overrides -
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Notifications -
    
    @objc
    private func handleUserUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let user = userInfo[DatabaseUpdatedNotificationKey.user] as? User else { return }
        self.user?.decorate(with: user)
        profileHeaderView.configure(with: user)
        
    }
    
    // MARK: - Actions -
    
    @objc
    private func handleSettingsPressed() {
        guard let user = user else { return }
        
        let dtvc = SettingsViewController(user: user)
        let nav = NavigationController(rootViewController: dtvc)
        self.present(nav, animated: true)
    }
    
    // MARK: - Helpers -
    
    private func presentImagePicker() {
        if self.imageManager == nil {
            self.imageManager = ImageManager()
        }
        
        self.imageManager?.launch(using: self)
    }
    
    private func presentImageOptions() {
        guard let user = user else { return }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteImageAction = UIAlertAction(title: "Delete Photo", style: .default) { [weak self] (_) in
            self?.deleteProfileImage()
        }
        
        let uploadAction = UIAlertAction(title: "Add New Photo", style: .default) { [weak self] (_) in
            self?.presentImagePicker()
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(uploadAction)
        
        if user.profileImageInStorage() {
            alert.addAction(deleteImageAction)
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteProfileImage() {
        guard let user = user else { return }
        self.profileHeaderView.showImageActivity(true)
        
        StorageService.deleteUserImage(for: user.id) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.userDataCoordinator.removeUserProfileImage(user.id)
                
            case .failure(let error):
                self?.presentAlert(with: error.displayError)
                self?.profileHeaderView.showImageActivity(false)
            }
        }
        
        
    }
}

// MARK: - JourneyViewDelegate -

extension ProfileViewController: JourneyViewDelegate {
    func journeyViewDidSelectItem(_ journeyView: JourneyView, index: Int) {
        print("Selected item")
    }
}

// MARK: - StatsViewDelegate -

extension ProfileViewController: StatsViewDelegate {
    func statsViewDidSelectItem(_ statsView: StatsView, index: Int) {
        self.ia_presentAlert(with: "Your Stats!", message: "You have selected to view more info on your stats! We’re so happy that you’re interested in learning more. We haven’t yet added in this feature, but please check back later on your progress.")
    }
}

// MARK: - ProfileHeaderViewDelegate -

extension ProfileViewController: ProfileHeaderViewDelegate {
    func profileHeaderViewSettingsWasSelected(_ profileHeaderView: ProfileHeaderView) {
        handleSettingsPressed()
    }
    
    func profileHeaderViewAvatarWasSelected(_ profileHeaderView: ProfileHeaderView) {
        guard let user = user else { return }
        user.photoURL == nil
            ? presentImagePicker()
            : presentImageOptions()
    }
}

// MARK: - ImageManagerDelegate -

extension ProfileViewController: ImageManagerDelegate {
    
    func imageManager(_ imageManager: ImageManager, requests alert: AlertViewController) {
        self.navigationController?.present(alert, with: SlideFromTopTransition())
    }
    
    func imageManagerDidError(_ imageManager: ImageManager, error: PermissionError, alert: AlertViewController?) {
        if let alertVC = alert {
            self.navigationController?.present(alertVC, with: SlideFromTopTransition())
            return
        }
        
        self.presentAlert(with: error.displayError)
    }
    
    func imageManagerDidSucceed(_ imageManager: ImageManager) {
        guard self.imageManager === imageManager, let user = user else { return }
        
        self.imageManager?.present(in: self) { (image: UIImage?) in
            guard let data = image?.jpegData(compressionQuality: 0.8) else { return }

            StorageService.uploadUserImage(for: user.id, imageData: data, progress: { (progress: Double) in
                self.profileHeaderView.updateProgress(Float(progress))
            }, completion: { (result) in
                switch result {
                case .success(let uploaded):
                    print("Uploaded file: \(uploaded)")
                    self.profileHeaderView.hideProgress()
                    self.userDataCoordinator.updateUser(user.id, profileImageUrl: uploaded)
                    
                case .failure(let error):
                    self.presentAlert(with: error.displayError)
                }
            })
        }
    }
    
}

// MARK: - UserDataCoordinatorDelegate -

extension ProfileViewController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        if case UserUpdateIntent.profileImage = intent {
            profileHeaderView.updateAvatar(user.photoURL)
        } else if case UserUpdateIntent.deleteProfileImage = intent {
            profileHeaderView.updateAvatar(nil)
            profileHeaderView.showImageActivity(false)
        }
        
         self.imageManager = nil
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        self.presentAlert(with: error)
    }
    
}

// MARK: - GuestProfileViewDelegate -

extension ProfileViewController: GuestProfileViewDelegate {
    
    func guestProfileViewDidRequestLogIn(_ guestProfileView: GuestProfileView) {
        NotificationCenter.default.post(name: .didRequestModalLogin, object: self, userInfo: [ModalLoginKeys.authenticationOption : ModalLoginValues.login])
    }
    
    func guestProfileViewDidRequestSignUp(_ guestProfileView: GuestProfileView) {
        NotificationCenter.default.post(name: .didRequestModalLogin, object: self, userInfo: [ModalLoginKeys.authenticationOption : ModalLoginValues.signup])
    }
    
}
