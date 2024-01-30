//
//  ProfileHeaderView.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/** The "Navigation Bar" at the top of the profile page. Really, it's just a view that we're using to mimic a nav view */

class ProfileHeaderView: UIView {
    weak var delegate: ProfileHeaderViewDelegate?
    private var targetWidth: CGFloat = 0.0
    
    // MARK: Margins
    private struct Margins {
        static let navContainerHeight: CGFloat = 40.0
        static let horizontalEdgeMargins: CGFloat = 20.0
    }
    
    // Will have the appearance of a navigation bar, but is really a view
    private let mockNavBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.navBarGreen
        return view
    }()
    
    // Goes in mockNav
    private let settingsButton: Button = {
        let button = Button()
        button.setImage(Icon.NavBar.settings.image, for: .normal)
        button.setImage(Icon.NavBar.settingsActive.image, for: [.highlighted, .selected])
        button.adjustsImageWhenHighlighted = true
        return button
    }()
    
    private let waveImageView: UIImageView = {
        let imageView = UIImageView(image: Decorative.Wave.greenWave.image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let profileImageButton = ProfileImageButton()
    
    private let nameLabel: Label = {
        let label = Label()
        label.textColor = UIColor.battleshipGrey
        label.font = UIFont.largeTitle
        label.textAlignment = .center
        return label
    }()
    
    private let uploadProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .cta
        progressView.trackTintColor = .lightTextColor
        progressView.isHidden = true
        return progressView
    }()
    
    // MARK: - Constructors
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        setupSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        self.addSubview(mockNavBarView)
        self.addSubview(waveImageView)
        self.addSubview(nameLabel)
        self.addSubview(profileImageButton)
        self.addSubview(settingsButton)
        self.addSubview(uploadProgressView)
        
        mockNavBarView.addSubview(settingsButton)
        settingsButton.addTarget(self, action: #selector(handleSettingsPressed), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(handleAvatarPress), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        mockNavBarView.snp.makeConstraints { (make) in
            make.width.centerX.top.equalTo(self)
            make.height.equalTo(Margins.navContainerHeight)
        }
        
        settingsButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0)
            make.top.equalToSuperview()
        }
        
        waveImageView.snp.makeConstraints { (make) in
            make.top.equalTo(mockNavBarView.snp.bottom)
            make.centerX.width.equalToSuperview()
        }
        
        profileImageButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100.0)
            make.centerY.equalTo(waveImageView.snp.bottom).offset(4.0)
        }

        uploadProgressView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageButton.snp.bottom).offset(4.0)
            make.width.equalTo(profileImageButton.snp.width).inset(4.0)
            make.height.equalTo(4.0)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageButton.snp.bottom).offset(10.0)
            make.width.equalToSuperview().inset(20.0).priority(995.0)
        }
    }
    
    // MARK: - Configure
    
    func configure(with user: User) {
        settingsButton.isHidden = false
        settingsButton.isEnabled = true
        
        nameLabel.text = user.name.first
        if let photoURL = user.photoURL {
            updateAvatar(photoURL)
        }
    }
    
    func configureForGuest() {
        nameLabel.text = "Our Guest"
        let guestImage = [
            ProfileIcon.guest1.image,
            ProfileIcon.guest2.image,
            ProfileIcon.guest3.image
            ].compactMap({$0}).randomElement()
        profileImageButton.adjustForGuest(image: guestImage) // hides decorator view
        
        settingsButton.isHidden = true
        settingsButton.isEnabled = false
    }
    
    func updateAvatar(_ url: URL?) {
        profileImageButton.setImage(url: url)
    }
    
    func updateProgress(_ progress: Float) {
        if uploadProgressView.isHidden {
            uploadProgressView.alpha = 1.0
            uploadProgressView.isHidden.toggle()
        }
        
        self.uploadProgressView.setProgress(progress, animated: true)
    }
    
    func hideProgress() {
        UIView.animate(withDuration: 0.35, animations: {
            self.uploadProgressView.transform = CGAffineTransform(translationX: 0.0, y: -10.0)
            self.uploadProgressView.alpha = 0.0
        }) { (complete) in
            if complete {
                self.uploadProgressView.isHidden = true
                self.uploadProgressView.transform = .identity
            }
        }
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        uploadProgressView.layer.cornerRadius = uploadProgressView.h / 2.0
    }
    
    // MARK: - Helpers
    
    class var requiredContentHeight: CGFloat {
        return 200.0
    }
    
    func showImageActivity(_ show: Bool) {
        show
            ? profileImageButton.showActivity()
            : profileImageButton.hideActivity()
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSettingsPressed() {
        self.delegate?.profileHeaderViewSettingsWasSelected(self)
    }
    
    @objc
    private func handleAvatarPress() {
        self.delegate?.profileHeaderViewAvatarWasSelected(self)
    }
    
}

// MARK: - ProfileHeaderView Delegate Protocol -

protocol ProfileHeaderViewDelegate: class {
    
    func profileHeaderViewSettingsWasSelected(_ profileHeaderView: ProfileHeaderView)
    
    func profileHeaderViewAvatarWasSelected(_ profileHeaderView: ProfileHeaderView)
}
