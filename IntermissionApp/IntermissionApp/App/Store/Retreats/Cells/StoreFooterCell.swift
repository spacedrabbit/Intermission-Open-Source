//
//  StoreFooterCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class StoreFooterCell: TableViewCell {
    
    private let addToCartButton: CTAButton = {
        let button = CTAButton()
        button.setText("ADD TO CART")
        return button
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
        self.contentView.addSubview(addToCartButton)
        
        self.topSeparator.backgroundColor = .clear
        self.bottomSeparator.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        addToCartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.largePadding)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalToSuperview().offset(-self.largePadding)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
}
