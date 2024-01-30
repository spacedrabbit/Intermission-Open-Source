//
//  GuestProfileView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/7/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

/** Simple view to display on the Profile tab when a guest user is
    logged in. Gives the user the ability to signup or login via
    delegation
 
    Much of this is based on GuestDashboardView
 */
class GuestProfileView: UIView {
    private let guest: GuestUser
    weak var delegate: GuestProfileViewDelegate?
    
    private let profileHeaderView: ProfileHeaderView = ProfileHeaderView()
    
    private let imageView: ImageView = {
        let image = Decorative.Yogi.yogiWarrior2Small.image
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = .title3
        label.textAlignment = .center
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.font = .callout
        label.textAlignment = .left
        return label
    }()
    
    private let helperTextLabel: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let ctaButton = CTAButton()
    
    private let container: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.clipsToBounds = false
        return scrollView
    }()
    
    init(guest: GuestUser) {
        self.guest = guest
        super.init(frame: .zero)
        self.backgroundColor = .white
        
        self.addSubview(container)
        self.addSubview(profileHeaderView)
        container.addSubviews([titleLabel, detailLabel, helperTextLabel, ctaButton])
        
        profileHeaderView.configureForGuest()
        
        ctaButton.setText("SIGN UP")
        ctaButton.addTarget(self, action: #selector(handleCTATapped), for: .touchUpInside)
        
        titleLabel.text = "Make this page your journal!"
        detailLabel.attributedText = "Reflect on your journey and marvel at your accomplishments on this page! See where your movement began, when your mindfulness persevered and what music lit the way.\n\nYou just need to sign up to see it all. 🙏🏽🙏🏾".set(style: Font.emptyViewDetail)
        helperTextLabel.setLinkText("..or if you have an account, LOG IN.", linkText: "LOG IN.", delegate: self)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    private func configureConstraints() {
        detailLabel.safelyEnforceHeightOnAutoLayout()
        helperTextLabel.safelyEnforceSizeOnAutoLayout()
        titleLabel.safelyEnforceSizeOnAutoLayout()
        
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(self.safeAreaLayoutGuide).priority(999.0)
        }
        
        // TODO: make less hacky
        // Note: This is a bit hacky, I'm using the label to set the width of the
        // scrollview's contentSize and relying on the text length being self.w - 40.0 - 40.0
        // I will need to change this later
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(container.contentLayoutGuide).offset(36.0)
            make.width.centerX.equalTo(container.frameLayoutGuide)
            make.leading.trailing.equalTo(container.contentLayoutGuide)
        })
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.leading.equalTo(container.contentLayoutGuide).offset(40.0)
            make.trailing.equalTo(container.contentLayoutGuide).inset(40.0)
        }
        
        ctaButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 250.0, height: 50.0))
            make.top.equalTo(detailLabel.snp.bottom).offset(60.0)
            make.centerX.equalTo(container.frameLayoutGuide)
        }
        
        helperTextLabel.snp.makeConstraints { make in
            make.top.equalTo(ctaButton.snp.bottom).offset(20.0)
            make.centerX.equalTo(container.frameLayoutGuide)
            make.bottom.equalTo(container.contentLayoutGuide).inset(20.0).priority(999.0)
        }
    }
    
    // MARK: - Actions -
    
    @objc
    private func handleCTATapped() {
        self.delegate?.guestProfileViewDidRequestSignUp(self)
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileHeaderView.frame = CGRect(x: 0.0, y: 0.0, width: self.w, height: ProfileHeaderView.requiredContentHeight)
        container.frame = CGRect(x: 0.0, y: profileHeaderView.h, width: self.w, height: self.safeAreaLayoutGuide.layoutFrame.h)
    }
}

// MARK: - LinkLabelDelegate -

extension GuestProfileView: LinkLabelDelegate {
    
    func linkLabel(_ linkLabel: LinkLabel, didSelectLink link: URL) {
        self.delegate?.guestProfileViewDidRequestLogIn(self)
    }
    
}

// MARK: - GuestDashboardViewDelegate Protocol -

protocol GuestProfileViewDelegate: class {
    
    func guestProfileViewDidRequestSignUp(_ guestProfileView: GuestProfileView)
    
    func guestProfileViewDidRequestLogIn(_ guestProfileView: GuestProfileView)
    
}
