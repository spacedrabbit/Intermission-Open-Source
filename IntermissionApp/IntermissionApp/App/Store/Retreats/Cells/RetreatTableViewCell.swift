//
//  RetreatTableViewCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - RetreatTableViewCell -

/** Cell used to display information about a retreat on the store tab
 
 */
class RetreatTableViewCell: TableViewCell {
    private var retreat: Retreat?
    
    private let cardMaskingView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private let cardShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = false
        view.shadow(color: .black, opacity: 0.28, radius: 4.0, offset: .zero)
        return view
    }()
    
    private let heroImageView: ImageView = {
        let imageView = ImageView()
        imageView.backgroundColor = .paleLavendar
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let pillLabel = PillLabel(style: .lavenderFill)
    
    private let titleLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.storeRetreatCellTitleText]
        label.numberOfLines = 2
        return label
    }()
    
    private let locationLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.storeRetreatCellDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.storeRetreatCellDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers -
    
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
        self.contentView.addSubview(cardShadowView)
        self.contentView.addSubview(cardMaskingView)
        
        cardMaskingView.addSubview(heroImageView)
        cardMaskingView.addSubview(titleLabel)
        cardMaskingView.addSubview(locationLabel)
        cardMaskingView.addSubview(dateLabel)
        
        heroImageView.addSubview(pillLabel)
    }
    
    private func setupConstraints() {
        cardShadowView.snp.makeConstraints { (make) in
            make.edges.equalTo(cardMaskingView)
        }
        
        cardMaskingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28.0).priority(999.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0)
            make.bottom.equalToSuperview().offset(-28.0).priority(999.0)
        }
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(max(340.0, UIScreen.main.bounds.height * 0.45)) // arbitrary
        }
        
        titleLabel.setAutoLayoutHeightEnforcement(992.0)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10.0)
            make.leading.equalToSuperview().offset(10.0)
            make.width.equalToSuperview().inset(10.0)
            make.bottom.equalToSuperview().offset(-20.0)
        }
        
        locationLabel.setAutoLayoutHeightEnforcement(lowerThan: titleLabel)
        locationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10.0)
            make.top.equalTo(heroImageView.snp.bottom).offset(20.0)
        }
        
        dateLabel.safelyEnforceHeightOnAutoLayout()
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10.0)
            make.baseline.equalTo(locationLabel)
        }
        
        pillLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.heroImageView).offset(10.0)
            make.bottom.equalTo(self.heroImageView).offset(-10.0)
        }
    }
    
    // MARK: - Configure
    
    func configure(with retreat: Retreat) {
        self.retreat = retreat
        
        if let url = retreat.heroImage?.url {
            heroImageView.setImage(url: url)
        }
        
        titleLabel.styledText = retreat.name
        locationLabel.styledText = retreat.location
        dateLabel.styledText = Date.setupDateString(with: retreat)
 
        pillLabel.text = "$\(retreat.priceString)"
        pillLabel.isHidden = !Flags.shouldDisplayShop
    }

}
