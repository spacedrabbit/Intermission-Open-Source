//
//  DashboardVideoHistoryCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

// MARK: - DashboardVideoHistoryCell -

/// Used to display "Last Viewed" video on Dashboard
class DashboardVideoHistoryCell: TableViewCell {
    weak var delegate: DashboardVideoHistoryCellDelegate?
    
    private let headingLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.dashboardVideoHeaderText]
        return label
    }()
    
    private let chevronButton: ChevronButton = {
        let button = ChevronButton()
        return button
    }()
    
    private let videoImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playIconImageView: ImageView = {
        let imageView = ImageView()
        imageView.image = UIImage(named: "play_circle")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let durationIcon: ImageView = {
        let imageView = ImageView()
        imageView.image = UIImage(named: "duration_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let durationLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.durationText]
        return label
    }()
    
    private let videoTitleLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.dashboardVideoTitle]
        label.numberOfLines = 2
        return label
    }()
    
    private let videoProgressBar: UIProgressView = {
        let view = UIProgressView()
        view.isHidden = true
        view.trackTintColor = UIColor.background
        view.progressTintColor = .accent
        return view
    }()
    
    // MARK: - Constructor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(headingLabel)
        self.contentView.addSubview(chevronButton)
        self.contentView.addSubview(videoImageView)
        self.contentView.addSubview(videoProgressBar)
        self.contentView.addSubview(playIconImageView)
        self.contentView.addSubview(durationIcon)
        self.contentView.addSubview(durationLabel)
        self.contentView.addSubview(videoTitleLabel)
        
        self.selectionStyle = .none
        self.bottomSeparator.isHidden = true
        
        chevronButton.addTarget(self, action: #selector(handleCTALabelTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    private func handleCTALabelTapped() {
        delegate?.dashboardHistoryCellCTAWasTapped(self)
    }
    
    // MARK: - Configure
    
    func configure(with videoHistory: VideoHistoryEntry, style: DashboardCTAStyle) {
        videoImageView.setImage(url: videoHistory.thumbnailURL)
        headingLabel.styledText = style.headingText
        
        let normalStyle = Styles.styles[Font.chevronButtonNormal] ?? Style()
        let highlightStyle = Styles.styles[Font.chevronButtonHighlighted] ?? Style()
        chevronButton.setTitleColor(.cta, for: .normal)
        chevronButton.setTitleColor(.ctaHighlighted, for: .highlighted)
        chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: normalStyle), for: .normal)
        chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: highlightStyle), for: .highlighted)
        
        durationLabel.styledText = TimeInterval(videoHistory.durationSeconds).minuteString()
        videoTitleLabel.styledText = videoHistory.postTitle
        
        if videoHistory.progress > 0.0 {
            videoProgressBar.setProgress(Float(videoHistory.progress), animated: true)
            videoProgressBar.isHidden = false
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var yPos: CGFloat = 0.0
        let horizontalMargin: CGFloat = 20.0
        let verticalMargin: CGFloat = 20.0
        let maxTextWidth: CGFloat = self.contentView.w - horizontalMargin - horizontalMargin
        
        headingLabel.sizeToFit()
        headingLabel.frame = CGRect(x: horizontalMargin, y: verticalMargin, width: headingLabel.w, height: headingLabel.h)
        yPos += headingLabel.y + headingLabel.h + 10.0
        
        chevronButton.sizeToFit()
        chevronButton.frame = CGRect(x: self.contentView.w - horizontalMargin - chevronButton.w,
                                     y: headingLabel.y + ((headingLabel.h - chevronButton.h) / 2.0),
                                     width: chevronButton.w, height: chevronButton.h)
        
        videoImageView.frame = CGRect(x: 0.0, y: yPos, width: self.contentView.w, height: (9.0 / 16.0) * self.contentView.w)
        yPos += videoImageView.h
        
        videoProgressBar.frame = CGRect(x: 0.0, y: yPos, width: self.contentView.w, height: 10.0)
        yPos += videoProgressBar.h + 10.0
        
        durationIcon.frame = CGRect(x: horizontalMargin, y: yPos, width: 14.0, height: 14.0)
        
        durationLabel.sizeToFit()
        durationLabel.frame = CGRect(x: durationIcon.x + durationIcon.w + 4.0,
                                     y: durationIcon.y + ((durationIcon.h - durationLabel.h) / 2.0),
                                     width: durationLabel.w, height: durationLabel.h)
        
        yPos += max(durationIcon.h, durationLabel.h) + 8.0
        
        videoTitleLabel.sizeToFit(width: maxTextWidth)
        videoTitleLabel.frame = CGRect(x: horizontalMargin, y: yPos, width: videoTitleLabel.w, height: videoTitleLabel.h)
        yPos += videoTitleLabel.h + verticalMargin
        
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: max(yPos, 0.0))
    }
    
}

// MARK: - DashboardVideoHistoryCellDelegate Protocol -

protocol DashboardVideoHistoryCellDelegate: class {
    
    func dashboardHistoryCellCTAWasTapped(_ dashboardHistoryCell: DashboardVideoHistoryCell)
    
}

// MARK: - DashboardCTAStyle -

/// Simple enum to help with setting text on Dashboard cells
enum DashboardCTAStyle {
    case history, browse, all, none
    
    var headingText: String {
        switch self {
        case .history: return "Pick up where you left off"
        case .browse: return "Try something new"
        case .all: return "Rewatch your favorites"
        default: return ""
        }
    }
    
    var ctaText: String {
        switch self {
        case .history: return "SEE HISTORY"
        case .browse: return "BROWSE VIDEOS"
        case .all: return "SEE ALL"
        default: return ""
        }
    }
}
