//
//  OnboardingProfileImageController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/1/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - OnboardingProfileImageController -

class OnboardingProfileImageController: ScrollViewController {
    private let user: User
    private let userDataCoordinator = UserDataCoordinator()
    private var imageManager: ImageManager? = ImageManager()
    private var providerImageURL: URL?
    
    private let saveButton = CTAButton()
    
    weak var delegate: OnboardingDelegate?
    
    private let headerContainerView = UIView()
    private let cancelUploadButton = CTAButton()

    private let titleLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingTitleText]
        label.numberOfLines = 2
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 2
        return label
    }()
    
    private let profileImageButton = ProfileImageButton()
    
    private let skipUploadLabel: LinkLabel = {
        let label = LinkLabel()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    private let uploadProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .cta
        progressView.trackTintColor = .lightTextColor
        return progressView
    }()
    
    private var profileImageUploadTask: UploadTask?
    
    // MARK: - Initializers -
    
    init(with user: User, delegate: OnboardingDelegate?) {
        self.user = user
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        self.isNavigationBarHidden = true
        self.userDataCoordinator.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEINIT IMAGE MANAGER")
        self.imageManager = nil
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .paleLavendar
        
        configure()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        uploadProgressView.layer.cornerRadius = uploadProgressView.h / 2.0
    }
    
    // MARK: - Layout
    
    private func configure() {
        self.scrollView.addSubview(headerContainerView)
        self.view.addSubview(saveButton)
        
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(detailLabel)
        headerContainerView.addSubview(profileImageButton)
        headerContainerView.addSubview(skipUploadLabel)
        headerContainerView.addSubview(uploadProgressView)
        headerContainerView.addSubview(cancelUploadButton)
        
        if let profileImageURL = user.photoURL {
            providerImageURL = profileImageURL
            profileImageButton.setImage(url: profileImageURL)
        }
        
        cancelUploadButton.isHidden = true
        uploadProgressView.isHidden = true
        
        titleLabel.styledText = "Wonderful to meet you, \(user.name.first)! 👋🏽👋🏾"
        detailLabel.styledText = "Show us your lovely self!"
        skipUploadLabel.setLinkText("...or SKIP for now", linkText: "SKIP", delegate: self)
        
        profileImageButton.addTarget(self, action: #selector(handleProfileImageTapped), for: .touchUpInside)
        cancelUploadButton.addTarget(self, action: #selector(handleCancelUploadTapped), for: .touchUpInside)
        cancelUploadButton.setText("CANCEL")
        
        // Save button
        saveButton.setText("SAVE")
        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)
        saveButton.isHidden = user.photoURL == nil
        
        // Constraints
        
        headerContainerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.scrollView.contentLayoutGuide)
            make.width.equalTo(self.view)
        }
        
        titleLabel.enforceHeightOnAutoLayout()
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(995.0)
        }
        
        detailLabel.enforceHeightOnAutoLayout()
        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(70.0)
        }
        
        profileImageButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(detailLabel.snp.bottom).offset(20.0)
            make.width.height.equalTo(100.0)
        }
        
        uploadProgressView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageButton.snp.bottom).offset(20.0)
            make.width.equalTo(profileImageButton.snp.width)
            make.height.equalTo(4.0)
        }
        
        cancelUploadButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(28.0)
            make.width.equalTo(uploadProgressView.snp.width).inset(4.0)
            make.centerY.equalTo(skipUploadLabel.snp.centerY)
        }
        
        skipUploadLabel.enforceHeightOnAutoLayout()
        skipUploadLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageButton.snp.bottom).offset(60.0)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-24.0)
            make.width.equalTo(250.0)
            make.height.equalTo(50.0)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Events
    
    @objc
    private func handleProfileImageTapped() {
        /* There should be two possible scenarios:
         1. A user registered with their email/pass and won't have a profile image
         2. A user registered with Facebook, and will have a profile image
        
         For that Facebook case, we will present the user with a "Save" button to press to use their exisitng facebook image.
         They will also be able to select a different photo if they link (but will not have the option to use their facebook
         image again from here).
         
         Users in the first case, will not be given an option to remove the photo they uploaded until they get to the user profile page
        */
        user.photoURL == nil
            ? presentImagePicker()
            : presentImageOptions()
    }
    
    @objc
    private func handleCancelUploadTapped() {
        self.profileImageUploadTask?.cancel()
        self.profileImageUploadTask = nil
        
        skipUploadLabel.isHidden = false
        cancelUploadButton.isHidden = true
    }
    
    // MARK: - Events
    
    @objc
    private func handleSaveTapped() {
        guard let photoUrl = user.photoURL else { return }
        
        userDataCoordinator.updateUserOnboarded(user.id, profileImageUrl: photoUrl)
    }
    
    // MARK: - Image Options -
    
    private func presentImagePicker() {
        if self.imageManager == nil {
            self.imageManager = ImageManager()
        }
        
        self.imageManager?.launch(using: self)
    }
    
    private func presentImageOptions() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let uploadAction = UIAlertAction(title: "Add New Photo", style: .default) { [weak self] (_) in
            self?.presentImagePicker()
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(uploadAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User Data Coordination
    
    private func handlePhotoUploadOnboarding(user: User) {
        self.profileImageButton.setImage(url: user.photoURL)
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
            self.profileImageButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        animator.addAnimations({
            self.profileImageButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, delayFactor: 0.3)
        
        animator.addAnimations({
            self.profileImageButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, delayFactor: 0.6)
        
        animator.addCompletion { (position) in
            switch position {
            case .end: self.presentImageUploadedAlert(user: user)
            default: print("Other")
            }
        }
        
        animator.startAnimation()
    }
    
    private func handlePhotoSkippedOnboarding(user: User) {
        delegate?.onboardingDelegate(self, didSkipProfileImageUpload: user)
        delegate?.onboardingDelegatedidFinishRegistering(user: user)
    }
    
    private func presentImageUploadedAlert(user: User) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let okAction = AlertAction(title: "LET'S GO") { (alert, _) in
                alert.dismiss(animated: true, completion: {
                    self.delegate?.onboardingDelegatedidFinishRegistering(user: user)
                })
            }
            
            self.presentAlert(with: "Great choice! 😀", message: "Now that we’ve gotten to know each other a little, let’s get you settled in and ready to take an Intermission from your regularly scheduled programming.", primary: okAction, secondary: nil, canTapToDismiss: false)
        }
    }
}

// MARK: - LinkLabelDelegate -

extension OnboardingProfileImageController: LinkLabelDelegate {
    
    func linkLabel(_ linkLabel: LinkLabel, didSelectLink link: URL) {
        self.userDataCoordinator.updateUser(self.user.id, onboarded: true)
    }
    
}

// MARK: - UserDataCoordinatorDelegate -

extension OnboardingProfileImageController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        if case UserUpdateIntent.profileImageAndOnboarding = intent {
            handlePhotoUploadOnboarding(user: user)
        } else if case UserUpdateIntent.onboarded = intent {
            handlePhotoSkippedOnboarding(user: user)
        }
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        if self.state == .loading { self.state = .ready }
        self.ia_presentAlert(with: error.title, message: error.message)
    }
    
}

// MARK: - ImageManagerDelegate -

extension OnboardingProfileImageController: ImageManagerDelegate {
    
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
        
        // Present image selection
        self.imageManager?.present(in: self) { [weak self] (selectedImage: UIImage?) in
            // Unwrap image
            guard let data = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
            
            // Adjust UI
            self?.uploadProgressView.isHidden = false
            self?.skipUploadLabel.isHidden = true
            self?.cancelUploadButton.isHidden = false
            
            // Upload to Firestore
            guard let self = self else { return }
            self.profileImageUploadTask = StorageService.uploadUserImage(for: self.user.id, imageData: data, progress: { [weak self] (progress: Double) in
                self?.uploadProgressView.setProgress(Float(progress), animated: true)
                
            }, completion: { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let url):
                    // UserDataCoordinatorDelegate will fire to update UI
                    self.userDataCoordinator.updateUserOnboarded(self.user.id, profileImageUrl: url)
                    
                case .failure(let error):
                    self.skipUploadLabel.isHidden = false
                    self.presentAlert(with: error.displayError)
                }
                
                self.cancelUploadButton.isHidden = true
                self.uploadProgressView.isHidden = true
                self.profileImageUploadTask = nil
            })

        }
    }
    
}
