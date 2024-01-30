//
//  SponsorViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/// Simple scrolling view to display an icon, details and social links for a Supporter
class SupporterViewController: ScrollViewController {
    private let supporter: Supporter
    
    private let containerView = UIView()
    
    private let sponsorIconImageView: ImageView = {
        let image = ImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var sponsorSocialLinksView: SocialLinksView = SocialLinksView(links: self.supporter.links)
    
    private let sponsorDetailsLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.style = Style {
            $0.font =  UIFont(name: Font.identifier(for: .regular), size: 14.0)
            $0.color = UIColor.darkBlueGrey
            $0.alignment = .left
        }
        return label
    }()
    
    // MARK: - Initializers
    
    init(supporter: Supporter) {
        self.supporter = supporter
        super.init(nibName: nil, bundle: nil)
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        self.containerView.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .cta
        sponsorSocialLinksView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSupporterIconTapped))
        sponsorIconImageView.addGestureRecognizer(tapGesture)
        sponsorIconImageView.isUserInteractionEnabled = true
        
        self.scrollView.addSubview(containerView)
        containerView.addSubview(sponsorIconImageView)
        containerView.addSubview(sponsorDetailsLabel)
        containerView.addSubview(sponsorSocialLinksView)
        
        containerView.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.leading.trailing.bottom.top.equalTo(self.scrollView.contentLayoutGuide)
        }
        
        sponsorIconImageView.snp.makeConstraints { (make) in
            make.height.equalTo(200.0)
            make.width.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28.0)
        }
        
        sponsorDetailsLabel.safelyEnforceHeightOnAutoLayout()
        sponsorDetailsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(sponsorIconImageView.snp.bottom).offset(40.0)
            make.width.equalToSuperview().inset(40.0).priority(990.0)
            make.centerX.equalToSuperview()
        }
        
        sponsorSocialLinksView.snp.makeConstraints { (make) in
            make.top.equalTo(sponsorDetailsLabel.snp.bottom).offset(40.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(989.0)
            make.bottom.equalToSuperview().inset(40.0).priority(990.0)
        }
        
        if let url = supporter.imageUrl {
            sponsorIconImageView.setImage(url: url)
        } else if let name = supporter.imageName {
            sponsorIconImageView.image = UIImage(named: name)
        }
        
        sponsorDetailsLabel.styledText = supporter.description
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSupporterIconTapped() {
        UIApplication.shared.open(supporter.website, options: [:], completionHandler: nil)
    }
    
}

extension SupporterViewController: SocialLinksViewDelegate {
    
    func socialLinksView(_ socialLinksView: SocialLinksView, didPressLink link: URL, type: Social) {
        UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
    
}

// MARK: - SocialLinksView -

/// Simple horizontally stacked view for displaying some combination of Facebook, Twitter, Instagram and Github buttons
class SocialLinksView: UIView {
    private let socialLinks: [SocialLink]
    private var buttons: [Button] = []
    weak var delegate: SocialLinksViewDelegate?
    
    private let websiteButton: Button = {
        let button = Button()
        button.setImage(Social.website.image, for: .normal)
        button.setImage(Social.website.highlightImage, for: .highlighted)
        return button
    }()
    
    private let facebookButton: Button = {
        let button = Button()
        button.setImage(Social.facebook.image, for: .normal)
        button.setImage(Social.facebook.highlightImage, for: .highlighted)
        return button
    }()
    
    private let twitterButton: Button = {
        let button = Button()
        button.setImage(Social.twitter.image, for: .normal)
        button.setImage(Social.twitter.highlightImage, for: .highlighted)
        return button
    }()
    
    private let githubButton: Button = {
        let button = Button()
        button.setImage(Social.github.image, for: .normal)
        button.setImage(Social.github.highlightImage, for: .highlighted)
        return button
    }()
    
    private let instagramButton: Button = {
        let button = Button()
        button.setImage(Social.instagram.image, for: .normal)
        button.setImage(Social.instagram.highlightImage, for: .highlighted)
        return button
    }()
    
    private let socialLinksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        return stackView
    }()
    
    // MARK: - Constructors
    
    init(links: [SocialLink]) {
        self.socialLinks = links
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        socialLinksStackView.isUserInteractionEnabled = true
        
        self.buttons = [websiteButton, facebookButton, twitterButton, instagramButton, githubButton]
        
        // Note: I don't love how it looks with this button. Hide it entirely for now, maybe
        // will adjust in the future with a better icon.
        websiteButton.isHidden = true // !links.contains(where: { $0.type == .website })
        facebookButton.isHidden = !links.contains(where: { $0.type == .facebook })
        twitterButton.isHidden = !links.contains(where: { $0.type == .twitter })
        instagramButton.isHidden = !links.contains(where: { $0.type == .instagram })
        githubButton.isHidden = !links.contains(where: { $0.type == .github })
        
        self.buttons.forEach { (btn) in
            btn.addTarget(self, action: #selector(handleDidPressSocial(button:)), for: .touchUpInside)
            socialLinksStackView.addArrangedSubview(btn)
            btn.snp.makeConstraints({ (make) in
                make.width.height.equalTo(32.0).priority(990.0)
            })
        }
        
        self.addSubview(socialLinksStackView)
        socialLinksStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    private func handleDidPressSocial(button: Button) {
        guard let link = socialLink(for: button) else { return }
        self.delegate?.socialLinksView(self, didPressLink: link.url, type: link.type)
    }
    
    // MARK: - Helpers
    
    private func socialLink(for button: Button) -> SocialLink? {
        if button === websiteButton, let link = self.socialLinks.first(where: { $0.type == .website } ){
            return link
        }
        else if button === facebookButton, let link = self.socialLinks.first(where: { $0.type == .facebook } ) {
            return link
        } else if button === twitterButton, let link = self.socialLinks.first(where: { $0.type == .twitter } ) {
            return link
        } else if button === githubButton, let link = self.socialLinks.first(where: { $0.type == .github } ) {
            return link
        } else if button === instagramButton, let link = self.socialLinks.first(where: { $0.type == .instagram } ) {
            return link
        }
        
        return nil
    }
}

protocol SocialLinksViewDelegate: class {
    
    func socialLinksView(_ socialLinksView: SocialLinksView, didPressLink link: URL, type: Social)
    
}
