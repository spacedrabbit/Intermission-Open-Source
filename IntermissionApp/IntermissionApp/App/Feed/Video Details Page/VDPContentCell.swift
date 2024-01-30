//
//  VDPContentCellCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - VDPContentCell -

class VDPContentCell: TableViewCell {
    weak var delegate: VDPContentCellDelegate?
    private var post: Post?
    // we keep tabs of the post, but we're really using the videoHistoryEntry for some data modeling. it has more of the display info we need. This isn't great to have two sources of "truth", so eventually this should be refactored
    private var videoHistoryEntry: VideoHistoryEntry?
    private var tags: [Tag] = []
    
    // Margins
    private let largeMargin: CGFloat = 20.0
    private let mediumMargin: CGFloat = 8.0
    private let smallMargin: CGFloat = 4.0
    
    // Views
    private let heroImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.progressTintColor = UIColor.cta
        progressBar.trackTintColor = UIColor.paleLavendar
        return progressBar
    }()
    
    private var playButtonView: ImageView = {
        let imageView = ImageView(image: Icon.Play.filledCTA.image)
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.style = Styles.styles[Font.vdpVideoTitleText]
        return label
    }()

    // MARK: - Constructors -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.contentView.addSubviews([
            heroImageView, progressBar, playButtonView,
            durationIconView, durationLabel, titleLabel ])
        
        playButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressPlayButtonView(sender:))))
    }
    
    func setupConstraints() {
        titleLabel.safelyEnforceSizeOnAutoLayout()
        durationLabel.safelyEnforceSizeOnAutoLayout()
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().priority(998.0)
            make.width.height.equalTo(self.contentView.snp.width)
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(5.0)
        }
        
        playButtonView.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-largeMargin)
            make.centerY.equalTo(progressBar.snp.centerY)
            make.height.width.equalTo(60.0)
        }
        
        durationIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(largeMargin)
            make.top.equalTo(progressBar.snp.bottom).offset(mediumMargin)
            make.height.equalTo(22.0).priority(999.0)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(durationIconView.snp.trailing).offset(mediumMargin)
            make.top.equalTo(progressBar.snp.bottom).offset(mediumMargin)
            make.centerY.equalTo(durationIconView.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(largeMargin)
            make.trailing.equalToSuperview().inset(largeMargin)
            make.top.equalTo(durationLabel.snp.bottom).offset(self.mediumMargin)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with entry: VideoHistoryEntry) {
        self.videoHistoryEntry = entry
        heroImageView.setImage(url: entry.thumbnailURL)
        progressBar.setProgress(Float(max(0.0, entry.progress)), animated: true)
        self.durationLabel.styledText = entry.durationSeconds.minuteString()
        self.titleLabel.styledText = entry.postTitle
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Actions -
    
    @objc
    func didPressPlayButtonView(sender: UIView) {
        delegate?.vdpContentCellDidPressPlay(self)
    }
}

// MARK: - VDPContentCellDelegate Protoco -

protocol VDPContentCellDelegate: class {
    
    func vdpContentCellDidPressPlay(_ vdpContentCellCell: VDPContentCell)
    
}
