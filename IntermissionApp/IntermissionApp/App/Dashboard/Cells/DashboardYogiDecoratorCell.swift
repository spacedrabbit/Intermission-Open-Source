//
//  DashboardYogiDecoratorCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/// Simple decorator cell at the bottom of Dashboard. Will always be visible.
class DashboardYogiDecoratorCell: TableViewCell {
    
    enum Style {
        case dashboardFavorites, dashboardHistory
    }
    
    private let yogiImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .paleLavendar
        self.backgroundView?.backgroundColor = .paleLavendar
        self.contentView.backgroundColor = .paleLavendar
        self.selectionStyle = .none
        
        var insets = super.contentInsets
        insets.top = 44.0
        self.contentInsets = insets
        
        self.contentView.addSubview(yogiImageView)
        
        yogiImageView.snp.makeConstraints( {make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().priority(999.0) // scaleAspectFill + width will size height appropriately automatically
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with style: DashboardYogiDecoratorCell.Style) {
        switch style {
        case .dashboardFavorites:
            yogiImageView.image = Decorative.Yogi.yogaWarrior2LargeRightAligned.image
            
        case .dashboardHistory:
            yogiImageView.image = Decorative.Yogi.yogiSeatedLegPullCTA.image
            
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
