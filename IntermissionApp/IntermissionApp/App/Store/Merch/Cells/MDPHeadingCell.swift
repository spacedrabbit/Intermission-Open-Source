//
//  MDPHeadingCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class MDPHeadingCell: TableViewCell {
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor.darkBlueGrey
        
        return label
    }()
    
    // TODO: this label
    private let descriptionLabel: Label = {
        return Label()
    }()
    
//    var merch: TempMerch?
    
    private let imageHeightWidth: CGFloat = 50.0
    private let largePadding: CGFloat = 16.0
    private let smallPadding: CGFloat = 8.0
    
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
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        
        self.topSeparator.backgroundColor = .clear
        self.bottomSeparator.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.top.equalToSuperview().offset(self.largePadding)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.smallPadding)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalToSuperview().offset(-self.largePadding)
            make.bottom.equalToSuperview().offset(-self.smallPadding)
        }
    }
}
