//
//  DashboardHelperTextCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/// Simple cell to display some helper text and an associated icon on the Dashboard
class DashboardHelperTextCell: TableViewCell {
    
    enum Style {
        case dashboardHistory, dashboardfavorites, retreatPrices
    }
    
    private struct Strings {
        static let historyTitle = "Journey with Mindfulness"
        static let historySubtitle = "Where we've been helps shape where we're headed. Your last viewed videos will show up here to guide your next steps."
        static let favoritesTitle = "Spread the love, see it here!"
        static let favoritesSubtitle = "Keep track of all the videos that have resonated with you. Look for \"Love\" on videos to find them more easily."
        static let retreatPricesTitle = "Applying for a Retreat"
        static let retreatPricesSubtitle = "To join us on this Retreat, make sure to use the links provided in the description. In the future you'll be able to register through the app!"
    }
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = .title3
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: Label = {
        let label = Label()
        label.numberOfLines = 0 // 3 is ideal for UI, but there will be overflow on small screens
        label.font = .callout
        label.textAlignment = .left
        return label
    }()
    
    private let iconImageView: ImageView = {
        let imageView = ImageView(image: Icon.Hearts.outlineDark.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        setupViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        self.backgroundView?.backgroundColor = .paleLavendar
        self.contentView.backgroundColor = .paleLavendar
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        self.contentView.addSubview(iconImageView)
    }
    
    private func configureConstraints() {
        let alignmentView = UILayoutGuide()
        self.contentView.addLayoutGuide(alignmentView)
        
        titleLabel.enforceSizeOnAutoLayout()
        subtitleLabel.enforceSizeOnAutoLayout()
        
        let verticalMargin: CGFloat = 30.0
        let horizontalMargin: CGFloat = 20.0
        
        // Alignment view providers trailing margin for text and horizontal alignment for icon
        alignmentView.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(verticalMargin)
            make.trailing.equalToSuperview().inset(horizontalMargin)
            make.bottom.equalToSuperview().inset(verticalMargin).priority(900.0)
            make.width.equalTo(horizontalMargin * 2.0)
        })
        
        titleLabel.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.trailing.equalTo(alignmentView.snp.leading)
            make.top.equalToSuperview().offset(verticalMargin)
        })
        
        subtitleLabel.snp.makeConstraints({ make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.bottom.equalToSuperview().inset(verticalMargin).priority(999.0)
        })
        
        iconImageView.snp.makeConstraints({ make in
            make.trailing.equalTo(alignmentView.snp.trailing)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.height.equalTo(24.0)
        })
    }
    
    // MARK: - Configure
    
    func configure(with style: DashboardHelperTextCell.Style) {
        switch style {
        case .dashboardHistory:
            iconImageView.image = Icon.History.dark.image
            titleLabel.text = Strings.historyTitle
            subtitleLabel.text = Strings.historySubtitle
            
            titleLabel.setNeedsLayout()
            subtitleLabel.setNeedsLayout()
            
        case .dashboardfavorites:
            iconImageView.image = Icon.Hearts.outlineDark.image
            titleLabel.text = Strings.favoritesTitle
            subtitleLabel.text = Strings.favoritesSubtitle
            
            titleLabel.setNeedsLayout()
            subtitleLabel.setNeedsLayout()
            
        case .retreatPrices:
            iconImageView.image = Icon.Retreat.low.image
            titleLabel.text = Strings.retreatPricesTitle
            subtitleLabel.text = Strings.retreatPricesSubtitle
            
            titleLabel.setNeedsLayout()
            subtitleLabel.setNeedsLayout()
        }
        
        // TODO: I don't think that all these layout calls are needed. Test later and remove unneeded redraws
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

}
