//
//  GuestDashboardView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/11/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

// MARK: - GuestDashboardView -

/** Simple view displayed on the Dashboard when there is a guest currently logged in. Provides some copy
 to encourage signing up, along with a CTA button to sign up and a link label for logging in. 
 
 */
class GuestDashboardView: UIView {
    weak var delegate: GuestDashboardViewDelegate?
    
    private let imageView: ImageView = {
        let image = Decorative.Yogi.yogiWarrior2Small.image
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let headerLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        return label
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.text = "Make this page your home!"
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
    
    // MARK: - Initializers
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        ctaButton.addTarget(self, action: #selector(handleCTATapped), for: .touchUpInside)
        ctaButton.setText("SIGN UP")
        
        setupViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func setupViews() {
        self.addSubview(container)
        
        container.addSubview(headerLabel)
        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(detailLabel)
        container.addSubview(ctaButton)
        container.addSubview(helperTextLabel)
        
        headerLabel.attributedText = "Welcome! 👋🏽👋🏾".set(style: Font.emptyViewTitle)
        detailLabel.attributedText = "If you'd like to bookmark videos, see recommendations, and keep track of your journey here, consider signing up for an account.\n\nUntil then, feel free to explore as our most welcomed guest.".set(style: Font.emptyViewDetail)
        helperTextLabel.setLinkText("..or if you have an account, LOG IN.", linkText: "LOG IN.", delegate: self)
    }
    
    private func configureConstraints() {
        headerLabel.enforceSizeOnAutoLayout()
        detailLabel.safelyEnforceHeightOnAutoLayout()
        helperTextLabel.safelyEnforceSizeOnAutoLayout()
        titleLabel.safelyEnforceSizeOnAutoLayout()
        
        container.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide).priority(999.0)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(container.contentLayoutGuide).offset(36.0).priority(999.0)
            make.leading.equalTo(container.contentLayoutGuide).offset(40.0)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(50.0)
            make.leading.trailing.equalTo(container.contentLayoutGuide)
            make.width.centerX.equalTo(container.frameLayoutGuide) // setting width + .scaleAspectFill will get the correct image height for its aspect ratio
        }
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(imageView.snp.bottom).offset(20.0)
            make.leading.equalTo(container.contentLayoutGuide).offset(40.0)
            make.trailing.equalTo(container.contentLayoutGuide).inset(40.0)
        })
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.leading.equalTo(container.contentLayoutGuide).offset(40.0)
            make.trailing.equalTo(container.contentLayoutGuide).inset(40.0)
        }
        
        ctaButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 250.0, height: 50.0))
            make.top.equalTo(detailLabel.snp.bottom).offset(24.0)
            make.centerX.equalTo(container.frameLayoutGuide)
        }
        
        helperTextLabel.snp.makeConstraints { make in
            make.top.equalTo(ctaButton.snp.bottom).offset(20.0)
            make.centerX.equalTo(container.frameLayoutGuide)
            make.bottom.equalTo(container.contentLayoutGuide).inset(20.0).priority(999.0)
        }
    }
    
    @objc
    private func handleCTATapped() {
        self.delegate?.guestDashboardViewDidRequestSignUp(self)
    }

}

// MARK: - LinkLabelDelegate -

extension GuestDashboardView: LinkLabelDelegate {
    
    func linkLabel(_ linkLabel: LinkLabel, didSelectLink link: URL) {
        self.delegate?.guestDashboardViewDidRequestLogIn(self)
    }
    
}

// MARK: - GuestDashboardViewDelegate Protocol -

protocol GuestDashboardViewDelegate: class {
    
    func guestDashboardViewDidRequestSignUp(_ guestDashboardView: GuestDashboardView)
    
    func guestDashboardViewDidRequestLogIn(_ guestDashboardView: GuestDashboardView)
    
}
