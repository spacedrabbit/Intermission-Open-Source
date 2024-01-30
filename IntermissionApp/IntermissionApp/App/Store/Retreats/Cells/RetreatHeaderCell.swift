//
//  RDPHeadingCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/28/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

// MARK: - RetreatHeaderCell -

class RetreatHeaderCell: TableViewCell {
    
    private let locationLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.storeRetreatCellDetailText]
        return label
    }()
    
    private let separatorLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.text = " ∙ "
        label.style = Styles.styles[Font.storeRetreatCellDetailText]
        return label
    }()
    
    private let dateLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.storeRetreatCellDetailText]
        return label
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = Styles.styles[Font.storeRetreatCellTitleText]
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.bottomSeparator.isHidden = true
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        self.contentView.addSubview(locationLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(separatorLabel)
        self.contentView.addSubview(dateLabel)
    }
 
    private func setupConstraints() {
        locationLabel.enforceSizeOnAutoLayout()
        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.top).offset(20.0).priority(995.0)
            make.leading.equalToSuperview().offset(20.0)
        }
        
        separatorLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(locationLabel.snp.trailing).offset(4.0)
            make.centerY.equalTo(locationLabel)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.baseline.equalTo(locationLabel)
            make.leading.equalTo(separatorLabel.snp.trailing).offset(4.0)
        }
        
        titleLabel.enforceSizeOnAutoLayout()
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(10.0)
            make.leading.equalToSuperview().offset(20.0)
            make.width.equalToSuperview().inset(20.0)
            make.bottom.equalToSuperview().inset(20.0).priority(995.0)
        }
    }
    
    // MARK: - Configure
    
    func configure(with retreat: Retreat) {
        locationLabel.styledText = retreat.location
        dateLabel.styledText = Date.setupDateString(with: retreat)
        titleLabel.styledText = retreat.name
    }
}
