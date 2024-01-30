//
//  UTPCTAViewController.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class UTPCTAViewController: ViewController {
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.title1
        label.text = "Upgrade to Pro!"
        label.textAlignment = .center
        
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.font = UIFont.callout
        label.textColor = UIColor.darkBlueGrey
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Auctor augue mauris augue neque. Arcu vitae elementum curabitur vitae nunc."
        label.textAlignment = .center
        
        return label
    }()
    
    private let monthButton: CTAButton = {
        let button = CTAButton()
        button.setText("$1.99 / MONTH")
        return button
    }()
    
    private let orLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.caption2
        label.textAlignment = .center
        label.textColor = UIColor.battleshipGrey
        label.text = "or"
        return label
    }()
    
    private let yearButton: CTAButton = {
        let button = CTAButton()
        button.setText("$19.99 / YEAR")
        return button
    }()
    
    private let yogiImageView: ImageView = {
        let imageView = ImageView()
        imageView.image = UIImage(named: "yogi_backbend_translucent_bkgd")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let leadingTrailingMargin: CGFloat = 16
    private let largeLeadingTrailingMargin: CGFloat = 32
    private let buttonHeight: CGFloat = 60
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Common
    
    private func commonInit() {
        self.isNavigationBarHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(monthButton)
        self.view.addSubview(orLabel)
        self.view.addSubview(yearButton)
        self.view.addSubview(yogiImageView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(85)
            make.centerX.equalToSuperview()
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(self.leadingTrailingMargin)
            make.leading.equalToSuperview().offset(self.largeLeadingTrailingMargin)
            make.trailing.equalToSuperview().offset(-self.largeLeadingTrailingMargin)
        }
        monthButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(self.largeLeadingTrailingMargin)
            make.leading.equalToSuperview().offset(self.buttonHeight)
            make.trailing.equalToSuperview().offset(-self.buttonHeight)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.buttonHeight)
        }
        orLabel.snp.makeConstraints { make in
            make.top.equalTo(monthButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(yearButton.snp.top).offset(-20)
        }
        yearButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.buttonHeight)
            make.trailing.equalToSuperview().offset(-self.buttonHeight)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.buttonHeight)
        }
        yogiImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
