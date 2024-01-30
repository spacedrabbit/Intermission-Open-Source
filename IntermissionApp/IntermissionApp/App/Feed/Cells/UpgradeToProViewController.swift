//
//  UpgradeToProViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// TODO: @Louis THIS IS OLD, REVIEW AND REMOVE
class UpgradeToProViewController: ViewController {
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        return label
    }()
    
    private let interstitialLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        return label
    }()
    
    private let monthlySubcriptionButton = CTAButton()
    private let yearlySubscriptionButton = CTAButton()
    
    private let imageView: ImageView = {
        let image = UIImage(named: "yogi_backbend_translucent_bkgd")
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.xCloseFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.xCloseFilledDark.image, for: .highlighted)
        return button
    }()
    
    // MARK: - Constructors -
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(interstitialLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(monthlySubcriptionButton)
        self.view.addSubview(yearlySubscriptionButton)
        
        titleLabel.attributedText = "Upgrade to Pro!".set(style: Font.emptyViewTitle)
        detailLabel.attributedText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Auctor augue mauris augue neque. Arcu vitae elementum curabitur vitae nunc.".set(style: Font.emptyViewDetail)
        interstitialLabel.attributedText = "or".set(style: Font.emptyViewDetail)
        
        monthlySubcriptionButton.setText("$1.99 / MONTH")
        yearlySubscriptionButton.setText("$19.99 / YEAR")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let margin: CGFloat = 20.0
        let maxWidth: CGFloat = max(0.0, self.view.w - margin - margin)
        var yPos: CGFloat = margin
        titleLabel.sizeToFit(width: maxWidth)
        detailLabel.sizeToFit(width: maxWidth)
        interstitialLabel.sizeToFit()
        
        titleLabel.frame = CGRect(x: (self.view.w - titleLabel.w) / 2.0,
                                  y: self.view.safeAreaInsets.top + yPos,
                                  width: titleLabel.w, height: titleLabel.h)
        yPos += titleLabel.y + titleLabel.h + margin
        
        detailLabel.frame = CGRect(x: (self.view.w - detailLabel.w) / 2.0, y: yPos,
                                   width: detailLabel.w, height: detailLabel.h)
        yPos += detailLabel.h + margin
        
        monthlySubcriptionButton.frame.origin = CGPoint(x: (self.view.w - monthlySubcriptionButton.w) / 2.0, y: yPos)
        yPos += monthlySubcriptionButton.h + 12.0
        
        interstitialLabel.frame = CGRect(x: (self.view.w - interstitialLabel.w) / 2.0, y: yPos,
                                         width: interstitialLabel.w, height: interstitialLabel.h)
        yPos += interstitialLabel.h + 12.0
        
        yearlySubscriptionButton.frame.origin = CGPoint(x: (self.view.w - yearlySubscriptionButton.w) / 2.0, y: yPos)
        yPos += yearlySubscriptionButton.h
        
        // Pick up here, image view
    }
    
    // MARK: - Actions -
    @objc
    private func handleCloseTapped() {
        self.dismiss(animated: true)
    }
    
}
