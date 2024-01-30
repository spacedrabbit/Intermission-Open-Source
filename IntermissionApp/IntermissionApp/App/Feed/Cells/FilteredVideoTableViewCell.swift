//
//  FilteredVideoTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class FilteredVideoTableViewCell: TableViewCell {
    
    private let videoImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6.0
        return imageView
    }()
    
    // TODO: pro label
    
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
        label.style = Styles.styles[Font.helperText]
        return label
    }()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([ videoImageView, titleLabel,
                                  durationLabel, durationIconView ])
        
        titleLabel.enforceHeightOnAutoLayout()
        // This extra step for the title label is necessary because we need to ensure that it has a lower
        // width priority than the imageView's width, otherwise a label with long text will push out
        // the width of the imageview (or compress it, if it's short) since there is a relationship between the two
        titleLabel.setContentCompressionResistancePriority(.init(991.0), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(990.0), for: .horizontal)
        durationLabel.safelyEnforceSizeOnAutoLayout()
        
        videoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(999.0)
            make.height.equalTo(self.contentView.snp.width).multipliedBy(9.0/16.0).priority(999.0)
        }
        
        durationIconView.snp.makeConstraints { (make) in
            make.leading.equalTo(videoImageView)
            make.top.equalTo(videoImageView.snp.bottom).offset(8.0)
            make.width.equalTo(24.0)
            make.height.equalTo(16.0)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(durationIconView.snp.centerY)
            make.leading.equalTo(durationIconView.snp.trailing).offset(4.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(videoImageView)
            make.width.equalTo(videoImageView).priority(998.0)
            make.top.equalTo(durationIconView.snp.bottom).offset(8.0)
            make.bottom.equalToSuperview().inset(20.0).priority(999.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with videoHistoryEntry: VideoHistoryEntry) {
        videoImageView.setImage(url: videoHistoryEntry.thumbnailURL)
        titleLabel.styledText = videoHistoryEntry.postTitle
        durationLabel.styledText = videoHistoryEntry.durationSeconds.minuteString()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}
