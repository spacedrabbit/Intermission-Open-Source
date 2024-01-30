//
//  MDPMenuCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class MDPMenuCell: TableViewCell {
    
    private let primarySizeLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.callout
        label.textColor = UIColor.tagTextColor
        label.text = "Size"
        
        return label
    }()
    
    private let primaryQuantityLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.callout
        label.textColor = UIColor.tagTextColor
        label.text = "Quantity"
        
        return label
    }()
    
    private let secondarySizeLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.largeTitle
        label.textColor = UIColor.battleshipGrey
        label.text = "Select size"
        
        return label
    }()
    
    private let secondaryQuantityLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.largeTitle
        label.textColor = UIColor.battleshipGrey
        label.text = "Select quantity"
        
        return label
    }()
    
    private let imageHeightWidth: CGFloat = 50.0
    private let largePadding: CGFloat = 16.0
    
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
        self.contentView.addSubview(primarySizeLabel)
        self.contentView.addSubview(primaryQuantityLabel)
        self.contentView.addSubview(secondarySizeLabel)
        self.contentView.addSubview(secondaryQuantityLabel)
        
        self.topSeparator.backgroundColor = .clear
        self.bottomSeparator.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        primarySizeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalTo(self.snp.centerX)
            make.height.equalTo(20)
        }
        primaryQuantityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(self.snp.centerX)
            make.trailing.equalToSuperview().offset(-self.largePadding)
            make.height.equalTo(20)
        }
        secondarySizeLabel.snp.makeConstraints { make in
            make.top.equalTo(primarySizeLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalTo(self.snp.centerX)
            make.bottom.equalToSuperview()
        }
        secondaryQuantityLabel.snp.makeConstraints { make in
            make.top.equalTo(primaryQuantityLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.snp.centerX)
            make.trailing.equalToSuperview().offset(-self.largePadding)
            make.bottom.equalToSuperview()
        }
    }
}
