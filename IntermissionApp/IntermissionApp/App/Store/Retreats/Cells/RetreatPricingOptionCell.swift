//
//  RetreatPricingOptionCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class RetreatPricingOptionCell: TableViewCell {
    
    private let leftAccessoryView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let optionNameLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = Styles.styles[Font.retreatPriceOptionCellText]
        return label
    }()
    
    private let priceLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.retreatPriceOptionCellPriceText]
        return label
    }()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .default
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
        self.bottomSeparator.isHidden = true
        
        // View setup
        self.contentView.addSubview(leftAccessoryView)
        self.contentView.addSubview(priceLabel)
        self.contentView.addSubview(optionNameLabel)
        
        // Constraints
        optionNameLabel.setAutoLayoutHeightEnforcement(990.0)
        optionNameLabel.setAutoLayoutWidthEnforcement(990.0)
        priceLabel.enforceSizeOnAutoLayout()
        
        
        leftAccessoryView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44.0, height: 44.0))
        }
        
        optionNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(priceLabel.snp.leading).offset(-20.0)
            make.leading.equalToSuperview().offset(20.0)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with pricingOption: RetreatPricingOption) {
        optionNameLabel.styledText = pricingOption.name
        priceLabel.styledText = "$" + pricingOption.priceString

        var leftImage: UIImage? = nil
        if let priceLevel = pricingOption.priceLevel {
            switch priceLevel {
            case .low: leftImage = Icon.Retreat.low.image
            case .mid: leftImage = Icon.Retreat.mid.image
            case .high: leftImage = Icon.Retreat.high.image
            }

            leftAccessoryView.image = leftImage
            leftAccessoryView.isHidden = false
        }

        remakeConstraintsIfNecessary()
    }
    
    /// This adjusts the leading and trailing constraints on the text label depending on the
    /// presence of the left & right image accessory views
    private func remakeConstraintsIfNecessary() {
        
        if leftAccessoryView.image == nil {
            optionNameLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(20.0).priority(995.0)
                make.trailing.equalTo(priceLabel.snp.leading).inset(20.0).priority(991.0)
            }
        } else {
            optionNameLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalTo(leftAccessoryView.snp.trailing).offset(10.0).priority(995.0)
                make.trailing.equalTo(priceLabel.snp.leading).offset(-20.0).priority(991.0)
            }
        }
    }
    
    // MARK: - Size Helpers
    
    static var height: CGFloat {
        return 74.0
    }
}
