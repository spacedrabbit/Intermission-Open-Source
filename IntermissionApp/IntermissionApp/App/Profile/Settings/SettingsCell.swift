//
//  SettingsCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - SettingsCell -

/// Simple cell consisting of an optional left & right image view and a single line label
/// Used in the SettingsVC
class SettingsCell: TableViewCell {
    
    private let leftAccessoryView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let rightAccessoryView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let settingsTextLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.highlightedTextColor = .white
        label.style = Styles.styles[Font.settingsCellText]
        return label
    }()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .default
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .cta
        
        // View setup
        self.contentView.addSubview(leftAccessoryView)
        self.contentView.addSubview(rightAccessoryView)
        self.contentView.addSubview(settingsTextLabel)
        
        // Constraints
        settingsTextLabel.enforceHeightOnAutoLayout()
        settingsTextLabel.safelyEnforceWidthOnAutoLayout()
        
        rightAccessoryView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(18.0)
        }
        
        leftAccessoryView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24.0, height: 24.0))
        }
        
        settingsTextLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(rightAccessoryView.snp.leading).inset(10.0)
            make.leading.equalToSuperview().offset(20.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with text: String, leftAccessory: SettingsCellAccessory? = nil, rightAccessory: SettingsCellAccessory? = nil) {
        settingsTextLabel.styledText = text
        
        if let left = leftAccessory {
            leftAccessoryView.image = left.image
            leftAccessoryView.highlightedImage = left.highlightedImage
            leftAccessoryView.isHidden = false
        } else {
            leftAccessoryView.isHidden = true
            leftAccessoryView.image = nil
            leftAccessoryView.highlightedImage = nil
        }
        
        if let right = rightAccessory {
            rightAccessoryView.image = right.image
            rightAccessoryView.highlightedImage = right.highlightedImage
            rightAccessoryView.isHidden = false
        } else {
            rightAccessoryView.image = nil
            rightAccessoryView.highlightedImage = nil
            rightAccessoryView.isHidden = true
        }
        
        remakeConstraintsIfNecessary()
    }
    
    /// This adjusts the leading and trailing constraints on the text label depending on the
    /// presence of the left & right image accessory views
    private func remakeConstraintsIfNecessary() {
        
        if leftAccessoryView.image == nil {
            settingsTextLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(20.0).priority(995.0)
                if rightAccessoryView.image == nil {
                    make.trailing.equalTo(rightAccessoryView.snp.leading).inset(10.0).priority(991.0)
                } else {
                    make.trailing.equalToSuperview().inset(20.0).priority(991.0)
                }
            }
        } else {
            settingsTextLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalTo(leftAccessoryView.snp.trailing).offset(10.0).priority(995.0)
                if rightAccessoryView.image == nil {
                    make.trailing.equalTo(rightAccessoryView.snp.leading).inset(10.0).priority(991.0)
                } else {
                    make.trailing.equalToSuperview().inset(20.0).priority(991.0)
                }
            }
        }
    }
    
    // MARK: - Size Helpers
    
    static var height: CGFloat {
        return 60.0
    }
}

// MARK: - SettingsCellAccessory -

enum SettingsCellAccessory {
    case chevron, facebook, github
    
    var image: UIImage? {
        switch self {
        case .chevron: return Icon.Chevron.backCTA.image
        case .facebook: return Icon.Facebook.facebook.image
        case .github: return Social.github.image
        }
    }
    
    var highlightedImage: UIImage? {
        switch self {
        case .chevron: return Icon.Chevron.backLight.image
        case .facebook: return nil
        case .github: return Social.github.lightImage
        }
    }
}
