//
//  MDPHeroCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class MDPHeroCell: TableViewCell {
    
    private let heroImageView: ImageView = {
        let imageView = ImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let pillLabel: PillLabel = {
        let label = PillLabel(style: .grayFill)
        
        return label
    }()
    
    private let imageHeightWidth: CGFloat = 50.0
    private let largePadding: CGFloat = 16.0
    
//    var merch: TempMerch?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func configure(with merch: TempMerch) {
//        self.merch = merch
//
//        heroImageView.image = merch.image
//        configurePillLabel(with: merch)
//    }
    
    private func setupViews() {
        self.contentView.addSubview(heroImageView)
        self.contentView.addSubview(pillLabel)
        
        self.topSeparator.backgroundColor = .clear
        self.bottomSeparator.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        heroImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(self.contentView.snp.width)
        }
        pillLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.largePadding)
            make.bottom.equalTo(self.heroImageView.snp.bottom).offset(-self.largePadding)
        }
    }
    
//    private func configurePillLabel(with merch: TempMerch) {
//        pillLabel.text = "\(String(merch.price))"
//        pillLabel.pillStyle = .grayFill
//        pillLabel.textColor = .black
//    }
}
