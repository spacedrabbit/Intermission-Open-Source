//
//  MerchCollectionViewCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/* @Hari @Tom
 
 - Let's do a group discussion on cell layout implementations
     - Merch cells are breaking constraints, but Im also having issues with Snapkit that I'd like to go over.
 
 */

class MerchCollectionViewCell: CollectionViewCell {
    
    private let itemImageView: ImageView = {
        let imageView = ImageView()
        imageView.image = UIImage(named: "placeholder")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 22)
        
        return label
    }()
    
    private let pillLabel: PillLabel = {
        let pillLabel = PillLabel()
        pillLabel.clipsToBounds = true
        
        return pillLabel
    }()
    
    private let largePadding: CGFloat = 16.0
    private let mediumPadding: CGFloat = 12.0
    
//    var merch: TempMerch?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.contentView.addSubview(itemImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(pillLabel)
        
        self.contentView.backgroundColor = UIColor.darkBlueGrey.withAlphaComponent(0.07)
    }
    
    private func setupConstraints() {
        itemImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(self.largePadding)
            make.height.equalTo(self.itemImageView.snp.width)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.itemImageView.snp.bottom)
            make.leading.equalToSuperview().offset(self.largePadding)
            make.trailing.equalTo(self.itemImageView)
            make.bottom.lessThanOrEqualToSuperview()
        }
        pillLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.itemImageView).offset(self.mediumPadding)
            make.bottom.equalTo(self.itemImageView.snp.bottom).offset(-self.mediumPadding)
        }
    }
    
//    func configure(with merch: TempMerch) {
//        self.merch = merch
//        titleLabel.text = merch.title
//        pillLabel.text = merch.price
//        pillLabel.pillStyle = .lavenderFill
//    }
}
