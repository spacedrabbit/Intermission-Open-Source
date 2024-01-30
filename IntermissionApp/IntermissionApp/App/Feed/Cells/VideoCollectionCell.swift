//
//  PagingVideoCollectionViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

/// Basic cell to display the thumbnail, duration and title of a video. Also displays a play button
class VideoCollectionCell: CollectionViewCell {
    
    private let videoImageView: ImageView = {
        let imageView = ImageView()
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    
    private let playIconButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.Play.filledCTA.image, for: .normal)
        button.setImage(Icon.Play.filledDark.image, for: .highlighted)
        return button
    }()
    
    private let videoTitleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.font = .title2
        label.textColor = .textColor
        return label
    }()
    
    private let durationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "duration_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let durationLable: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = .caption2
        label.textColor = .lightTextColor
        return label
    }()
    
    private let featuredLabel: PillLabel = PillLabel(style: .lightGreenFill)
    
    // MARK: - Initializers -
 
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        featuredLabel.text = "NEW"
        
        self.contentView.addSubview(videoImageView)
        self.contentView.addSubview(playIconButton)
        self.contentView.addSubview(videoTitleLabel)
        self.contentView.addSubview(durationIconImageView)
        self.contentView.addSubview(durationLable)
        videoImageView.addSubview(featuredLabel)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with title: String, subtitle: String?, url: URL, isNewPost: Bool, showsPlayIcon: Bool = false) {
        let titleStyle = Style {
            $0.font = UIFont.title2
            $0.color = UIColor.textColor
            $0.lineSpacing = 0.0
            $0.maximumLineHeight = 28.0
            $0.alignment = .left
        }
        
        videoTitleLabel.attributedText = title.set(style: titleStyle)
        durationLable.text = subtitle
        videoImageView.setImage(url: url, placeholder: nil)
        
        playIconButton.isHidden = !showsPlayIcon
        featuredLabel.isHidden = !isNewPost
    }
    
    private func configureConstraints() {
        
        videoImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(995.0)
            make.height.equalTo(videoImageView.snp.width).multipliedBy(9.0/16.0)
        }
        
        durationIconImageView.snp.makeConstraints { make in
            make.top.equalTo(videoImageView.snp.bottom).offset(8.0)
            make.width.height.equalTo(12.0)
            make.leading.equalTo(videoImageView.snp.leading)
        }
        
        durationLable.enforceSizeOnAutoLayout()
        durationLable.snp.makeConstraints { make in
            make.leading.equalTo(durationIconImageView.snp.trailing).offset(4.0)
            make.centerY.equalTo(durationIconImageView.snp.centerY)
        }

        videoTitleLabel.safelyEnforceHeightOnAutoLayout()
        videoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(durationLable.snp.bottom).offset(6.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(990.0)
        }
        
        playIconButton.snp.makeConstraints { make in
            make.centerY.equalTo(videoImageView.snp.bottom).inset(18.0)
            make.trailing.equalTo(videoImageView.snp.trailing).inset(8.0)
            make.width.height.equalTo(44.0)
        }
        
        featuredLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.trailing.equalToSuperview().offset(-8.0)
        }
    }
    
    // MARK: - Helpers -
    
    static func height(for width: CGFloat) -> CGFloat {
        let imageHeight = (9.0/16.0) * (width - 20.0 - 20.0)
        return imageHeight + 120.0 // 120.0 is arbitrary, just picking something that works
    }
    
}
