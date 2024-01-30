//
//  ProCTAInterstitialCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/3/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class ProCTAInterstitialCell: TableViewCell {
    private let titleLabel: Label = {
        let label = Label()
        label.text = "Upgrade to Pro!"
        label.numberOfLines = 1
        label.font = .title3
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: Label = {
        let label = Label()
        label.text = "Lorem ipsum dolor sit amet."
        label.numberOfLines = 1
        label.font = .callout
        label.textAlignment = .center
        return label
    }()
    
    private let yogiImageView: ImageView = {
        let image = UIImage(named: "standing_back_bend_yogi")
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textAlignmentView = UIView()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .secondaryBackground
        self.backgroundView?.backgroundColor = .secondaryBackground
        self.selectionStyle = .default
        
        let clearView = UIView()
        clearView.backgroundColor = .clear
        self.selectedBackgroundView = clearView
        
        self.contentView.addSubview(yogiImageView)
        self.contentView.addSubview(textAlignmentView)
        textAlignmentView.addSubview(titleLabel)
        textAlignmentView.addSubview(subtitleLabel)
        
        self.contentInsets = .zero
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    private func configureConstraints() {
        
        let horizontalMargin: CGFloat = 38.0
        let topMargin: CGFloat = 20.0
        let imageHeight: CGFloat = 120.0
        let imageWidth: CGFloat = 140.0
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        textAlignmentView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.left).offset(horizontalMargin)
            make.centerY.equalToSuperview()
            make.right.equalTo(yogiImageView.snp.left).offset(horizontalMargin) // overlaps image a little
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.lessThanOrEqualToSuperview()
            make.width.greaterThanOrEqualTo(1.0).priority(999.0)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.lessThanOrEqualToSuperview().priority(999.0)
            make.width.lessThanOrEqualTo(self.contentView).multipliedBy(0.6).priority(999.0)
            make.left.right.greaterThanOrEqualTo(1.0).priority(900.0)
        }
        
        yogiImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-horizontalMargin)
            make.top.equalToSuperview().offset(topMargin)
            make.size.equalTo(CGSize(width: imageWidth, height: imageHeight))
        }
    }
}
