//
//  PostPreviewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/23/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/// Use these cells to display thumbnails related to Posts or VideoHistoryEntry's in horizontally scrolling collection view's
class PostPreviewCell: CollectionViewCell {
    
    private let videoImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5.0
        return view
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = Styles.styles[Font.videoCollectionCellTitle]
        return label
    }()
    
    private let durationIconView: ImageView = {
        let imageView = ImageView(image: Icon.Duration.light.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let durationLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.durationText]
        return label
    }()
    
    private let proLabel: PillLabel = PillLabel(style: .lightGreenFill)
    private let featuredLabel: PillLabel = PillLabel(style: .lightGreenFill)
    
    // MARK: - Initializers -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    private func setupViews() {
        proLabel.text = "PRO"
        featuredLabel.text = "NEW"
        
        self.contentView.addSubview(shadowView)
        self.contentView.addSubview(videoImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(durationIconView)
        self.contentView.addSubview(durationLabel)
        
        videoImageView.addSubview(proLabel)
        videoImageView.addSubview(featuredLabel)
    }
    
    private func setupConstraints() {
        titleLabel.safelyEnforceHeightOnAutoLayout()
        titleLabel.setContentCompressionResistancePriority(.init(990.0), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(991.0), for: .horizontal)
        durationLabel.safelyEnforceSizeOnAutoLayout()
        
        videoImageView.snp.makeConstraints { make in
            make.centerX.width.top.equalToSuperview()
            make.height.equalTo(self.videoImageView.snp.width).multipliedBy(9.0 / 16.0)
        }
        
        proLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8.0)
        }
        
        featuredLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.trailing.equalToSuperview().offset(-8.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.videoImageView.snp.bottom).offset(10.0)
            make.leading.equalToSuperview().offset(10.0)
            make.width.equalToSuperview().inset(20.0)
        }
        
        durationIconView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5.0)
            make.leading.equalTo(self.titleLabel)
            make.width.equalTo(14.0)
            make.height.equalTo(11.0)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.durationIconView.snp.trailing).offset(4.0)
            make.centerY.equalTo(self.durationIconView.snp.centerY)
        }
        
        shadowView.snp.makeConstraints { make in
            make.size.centerX.centerY.equalTo(videoImageView)
        }
    }
    
    // MARK: - Configure -
    
    func configure(with post: Post) {
        if let imageUrl = post.video?.displayImageURL {
            videoImageView.setImage(url: imageUrl)
        }
        
        titleLabel.styledText = post.title
        durationLabel.styledText = post.video?.duration.minuteString()
        
        proLabel.isHidden = !post.subscriberOnly
        featuredLabel.isHidden = !post.isNew
        
        // Only the shadow view needs laying out, the rest are handled by autolayout
        shadowView.setNeedsLayout()
        shadowView.layoutIfNeeded()
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8.0).cgPath
    }
    
    // MARK: - Size Helpers -
    
    static func height(for width: CGFloat) -> CGFloat {
        let imageHeight = (9.0/16.0) * width
        return imageHeight + 100.0 // 100.0 is arbitrary, just picking something that works
    }
}
