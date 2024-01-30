//
//  JourneyTableViewCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/17/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class JourneyTableViewCell: TableViewCell {
    private var journeyItem: VideoHistoryEntry?
        
    private let bulletImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = ProfileIcon.openCircle.image
        imageView.highlightedImage = ProfileIcon.openCircle.highlightedImage
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let dateLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.profileJourneyDateText]
        return label
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = Styles.styles[Font.profileJourneyTitleText]
        return label
    }()
    
    private let standardTrailLine = UIView()
    private let optionalTopTrailLine = UIView()
    private let optionalBottomTrailLine = UIView()
    
    // MARK: - Trail Line options
    
    /// These are used to control if there is a top line extending from the top of the bullet, beyond the margins to the prior cell and an extra long trail line extending from the bottom of the bullet point to the next cell
    struct TrailLineOption: OptionSet {
        let rawValue: Int
        
        static let top = TrailLineOption(rawValue: 1 << 0)
        static let bottom = TrailLineOption(rawValue: 1 << 1)
    }
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentInsets = .zero
        
        self.backgroundColor = .clear
        
        // View Setup
        self.bottomSeparator.isHidden = true
        optionalTopTrailLine.isHidden = true
        optionalBottomTrailLine.isHidden = true
        
        standardTrailLine.backgroundColor = .navBarGreen
        optionalTopTrailLine.backgroundColor = .navBarGreen
        optionalBottomTrailLine.backgroundColor = .navBarGreen
        
        self.contentView.addSubview(bulletImageView)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(standardTrailLine)
        self.contentView.addSubview(optionalTopTrailLine)
        self.contentView.addSubview(optionalBottomTrailLine)
        
        // Constraints
        titleLabel.safelyEnforceWidthOnAutoLayout()
        titleLabel.enforceHeightOnAutoLayout()
        dateLabel.safelyEnforceSizeOnAutoLayout()
        
        bulletImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.0)
            make.centerY.equalTo(dateLabel)
            make.height.width.equalTo(11.0)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.0)
            make.leading.equalTo(self.bulletImageView.snp.trailing).offset(10.0)
            make.width.equalToSuperview().inset(20.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(6.0)
            make.leading.equalTo(dateLabel)
            make.width.equalToSuperview().inset(40.0)
            make.bottom.equalToSuperview().inset(20.0)
        }
        
        standardTrailLine.snp.makeConstraints { (make) in
            make.top.equalTo(bulletImageView.snp.bottom).offset(4.0)
            make.bottom.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.width.equalTo(1.0)
            make.centerX.equalTo(bulletImageView.snp.centerX)
        }
        
        optionalTopTrailLine.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(bulletImageView.snp.top).offset(-4.0)
            make.centerX.width.equalTo(standardTrailLine)
        }
        
        optionalBottomTrailLine.snp.makeConstraints { (make) in
            make.top.equalTo(standardTrailLine.snp.bottom)
            make.width.centerX.equalTo(standardTrailLine)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with videoHistoryEntry: VideoHistoryEntry, trailOptions: TrailLineOption) {
        if let lastWatched = videoHistoryEntry.lastDateWatched {
            dateLabel.styledText = lastWatched.setupDateString()
        }
        
        titleLabel.styledText = videoHistoryEntry.postTitle
        
        optionalBottomTrailLine.isHidden = !trailOptions.contains(.bottom)
        optionalTopTrailLine.isHidden = !trailOptions.contains(.top)
    }
}
