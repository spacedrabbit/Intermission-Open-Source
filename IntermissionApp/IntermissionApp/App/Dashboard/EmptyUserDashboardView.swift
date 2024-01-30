//
//  EmptyUserDashboardView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

class EmptyUserDashboardView: UIView {
    weak var delegate: EmptyUserDashboardViewDelegate?
    
    private let imageView: ImageView = {
        let image = Decorative.Yogi.yogiWarrior2Small.image
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let headerLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.font = .callout
        label.textAlignment = .left
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
    
    // MARK: - Constructors
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setupViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func setHeaderText(_ text: String) {
        headerLabel.attributedText = text.set(style: Font.emptyViewTitle)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        
        self.addSubview(container)
        container.addSubview(headerLabel)
        container.addSubview(imageView)
        container.addSubview(detailLabel)
        container.addSubview(ctaButton)
        
        ctaButton.addTarget(self, action: #selector(handleCTATapped), for: .touchUpInside)
        ctaButton.setText("START EXPLORING")
        
        detailLabel.attributedText = "This page will collect all of your watched and favorite videos, along with some recommendations from us. Come back and check your progress after exploring a little.".set(style: Font.emptyViewDetail)
    }
    
    private func configureConstraints() {
        // Force a set size for headerLabel based on its contents
        headerLabel.safelyEnforceHeightOnAutoLayout()
        detailLabel.safelyEnforceHeightOnAutoLayout()
        
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(self.safeAreaLayoutGuide).priority(999.0)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(container.contentLayoutGuide).offset(36.0).priority(999.0)
            make.centerX.equalTo(container.contentLayoutGuide)
            make.width.equalTo(container.frameLayoutGuide).inset(40.0).priority(990.0)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(50.0)
            make.leading.trailing.equalTo(container.contentLayoutGuide)
            make.width.centerX.equalTo(container.frameLayoutGuide) // setting width + .scaleAspectFill will get the correct image height for its aspect ratio
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20.0)
            make.centerX.equalTo(container.contentLayoutGuide)
            make.width.equalTo(container.frameLayoutGuide).inset(40.0).priority(990.0)
        }
        
        ctaButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 250.0, height: 50.0))
            make.top.equalTo(detailLabel.snp.bottom).offset(30.0)
            make.centerX.equalTo(container.frameLayoutGuide)
            make.bottom.equalTo(container.contentLayoutGuide).offset(-20.0).priority(999.0)
        }
        
    }
    
    // MARK: - Actions
    
    @objc
    private func handleCTATapped() {
        self.delegate?.emptyUserDashboardViewDidPressCTA(self)
    }
    
}

protocol EmptyUserDashboardViewDelegate: class {
    
    func emptyUserDashboardViewDidPressCTA(_ emptyDashView: EmptyUserDashboardView)
    
}
