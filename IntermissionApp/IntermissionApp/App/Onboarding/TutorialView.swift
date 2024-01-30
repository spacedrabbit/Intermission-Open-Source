//
//  TutorialView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/7/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

/// Simple view to display a page on the tutorial screen
/// Text and button content will scroll vertically if there isn't enough space
class TutorialView: UIView {
    private let stage: TutorialStage
    weak var delegate: TutorialViewDelegate?
    
    private let contentView = UIScrollView()
    private let backgroundBlockingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let borderImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let yogiImageView: ImageView = {
        let imageView = ImageView()
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
    
    private let subtitleLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.font = .callout
        label.textAlignment = .center
        return label
    }()
    
    private let primaryCTAButton: CTAButton = {
        let button = CTAButton()
        button.isHidden = true
        return button
    }()
    
    private let secondaryCTAButton: OutlineCTAButton = {
        let button = OutlineCTAButton()
        button.isHidden = true
        return button
    }()
    
    private var hideCTAButtons: Bool { return primaryCTAButton.isHidden || secondaryCTAButton.isHidden }
    
    // MARK: - Initializers
    
    init(stage: TutorialStage, delegate: TutorialViewDelegate?) {
        self.stage = stage
        self.delegate = delegate
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        yogiImageView.image = stage.yogiImage
        borderImageView.image = stage.borderImage
        titleLabel.text = stage.titleText
        subtitleLabel.text = stage.subtitleText
        
        primaryCTAButton.setText(stage.primaryCTAText)
        secondaryCTAButton.setText(stage.secondaryCTAText)
        
        primaryCTAButton.isHidden = stage.primaryCTAText.isEmpty
        secondaryCTAButton.isHidden = stage.secondaryCTAText.isEmpty
        
        self.addSubview(backgroundBlockingView)
        self.addSubview(yogiImageView)
        self.addSubview(contentView)
        self.addSubview(borderImageView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        if !hideCTAButtons {
            contentView.addSubview(primaryCTAButton)
            contentView.addSubview(secondaryCTAButton)
            
            primaryCTAButton.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)
            secondaryCTAButton.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)
        }
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func configureConstraints() {
        titleLabel.setAutoLayoutWidthEnforcement(990.0)
        titleLabel.setAutoLayoutHeightEnforcement(995.0)
        subtitleLabel.setAutoLayoutWidthEnforcement(990.0)
        subtitleLabel.setAutoLayoutHeightEnforcement(lowerThan: titleLabel)
        
        backgroundBlockingView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300.0)
        }
        
        borderImageView.snp.makeConstraints { make in
            make.top.equalTo(backgroundBlockingView.snp.bottom)
            make.leading.trailing.width.equalToSuperview()
        }
        
        yogiImageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.bottom.equalTo(borderImageView.snp.top)
        }
        
        // We want to let this slide under the border wave to give a sense of depth
        contentView.snp.makeConstraints { make in
            make.top.equalTo(backgroundBlockingView.snp.bottom)
            make.width.centerX.bottom.equalToSuperview()
        }
        
        // I guess setting the contentLayoutGuide explicitly helps with any possible ambiguity of contentSize
        contentView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.contentLayoutGuide).offset(60.0)
            make.centerX.equalTo(contentView.contentLayoutGuide)
            make.width.equalTo(contentView.contentLayoutGuide).inset(20.0).priority(991.0)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.contentLayoutGuide)
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.width.equalTo(contentView.contentLayoutGuide).inset(40.0).priority(991.0)
            
            if hideCTAButtons {
                make.bottom.equalTo(contentView.contentLayoutGuide.snp.bottom).inset(20.0)
            }
        }
        
        if !hideCTAButtons {
            primaryCTAButton.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(60.0)
                make.centerX.equalToSuperview()
                make.width.equalTo(contentView.contentLayoutGuide).inset(40.0).priority(990.0)
                make.height.equalTo(50.0)
            }
            
            secondaryCTAButton.snp.makeConstraints { make in
                make.top.equalTo(primaryCTAButton.snp.bottom).offset(14.0)
                make.centerX.equalToSuperview()
                make.width.equalTo(contentView.contentLayoutGuide).inset(40.0).priority(990.0)
                make.height.equalTo(28.0)
                make.bottom.equalTo(contentView.contentLayoutGuide).inset(20.0)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func handleButtonTapped(_ sender: Button) {
        if sender === primaryCTAButton {
            self.delegate?.tutorialViewDidPressPrimaryCTA(self)
        } else if sender === secondaryCTAButton {
            self.delegate?.tutorialViewDidPressSecondaryCTA(self)
        }
    }
}

// MARK: - TutorialViewDelegate Protocol -

protocol TutorialViewDelegate: class {
    
    func tutorialViewDidPressPrimaryCTA(_ tutorialView: TutorialView)
    
    func tutorialViewDidPressSecondaryCTA(_ tutorialView: TutorialView)
    
}

// MARK: - TutorialStage -

/// Simple enum to organize tutorial page information
enum TutorialStage {
    case first, second, third
    
    var yogiImage: UIImage? {
        switch self {
        case .first: return Onboarding.Yogi.left.image
        case .second: return Onboarding.Yogi.middle.image
        case .third: return Onboarding.Yogi.right.image
        }
    }
    
    var titleText: String {
        switch self {
        case .first: return Strings.firstTitle
        case .second: return Strings.secondTitle
        case .third: return Strings.thirdTitle
        }
    }
    
    var subtitleText: String {
        switch self {
        case .first: return Strings.firstSubtitle
        case .second: return Strings.secondSubtitle
        case .third: return Strings.thirdSubtitle
        }
        
    }
    
    var borderImage: UIImage? {
        switch self {
        case .first: return Onboarding.Other.leftWave.image
        case .second: return Onboarding.Other.middleWave.image
        case .third: return Onboarding.Other.rightWave.image
        }
    }
    
    var primaryCTAText: String {
        switch self {
        case .third: return "SIGN UP / LOG IN"
        default: return ""
        }
    }
    
    var secondaryCTAText: String {
        switch self {
        case .third: return "CONTINUE AS GUEST"
        default: return ""
        }
    }
    
    private struct Strings {
        static let firstTitle = "Breathe with Music"
        static let firstSubtitle = "Imagine a space where making music felt enjoyable from head to toe, where you could take an Intermission from the stresses of music and simply play. Exhale: you've arrived."
        static let secondTitle = "Flow with Movement"
        static let secondSubtitle = "Balance the emotional creativity of music-making with physical strength and resilience to enjoy a healthy, sustainable life in music."
        static let thirdTitle = "Live with Mindfulness"
        static let thirdSubtitle = "Whether you're onstage, in the practice room, or on the road, practicing mindfulness can unlock a world of inner peace, calm, and focus."
    }
    
}
