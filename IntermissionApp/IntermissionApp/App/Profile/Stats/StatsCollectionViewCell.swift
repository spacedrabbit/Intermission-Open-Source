//
//  StatsCollectionViewCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/30/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - StatsCollectionViewCell -

/// Displays a user's particular stat
class StatsCollectionViewCell: CollectionViewCell {
    
    private let iconView: ImageView = {
        let imageView = ImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let valueLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Style {
            $0.font =  UIFont(name: Font.identifier(for: .regular), size: 40.0)
            $0.color = UIColor.darkBlueGrey
            $0.alignment = .left
        }
        
        return label
    }()
    
    private let descriptionLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Style {
            $0.font =  UIFont(name: Font.identifier(for: .regular), size: 14.0)
            $0.color = UIColor.darkBlueGrey
            $0.alignment = .left
        }
        
        return label
    }()
    
    // MARK: - Initializers -

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // View Setup
        self.contentView.addSubview(iconView)
        self.contentView.addSubview(valueLabel)
        self.contentView.addSubview(descriptionLabel)
        
        // Constraints
        valueLabel.enforceHeightOnAutoLayout()
        valueLabel.safelyEnforceWidthOnAutoLayout()
        
        descriptionLabel.enforceHeightOnAutoLayout()
        descriptionLabel.safelyEnforceWidthOnAutoLayout()
        
        
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30.0).priority(995.0)
            make.trailing.equalTo(self.contentView.snp.centerX).offset(-5.0)
            make.height.width.equalTo(30.0)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.centerX).offset(5.0)
            make.trailing.equalToSuperview().priority(998.0)
            make.centerY.equalTo(iconView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(8.0)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(10.0).priority(990.0)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with value: String, statItem: StatItem) {
        valueLabel.styledText = value
        descriptionLabel.styledText = statItem.detailString
        iconView.image = statItem.icon
        // TODO: not used yet
//        iconView.highlightedImage = statItem.iconHighlighted
        
        valueLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
    }
}
