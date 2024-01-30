//
//  VDPTagLabelCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/12/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - VDPTagLabelCell -

class VDPTagLabelCell: TableViewCell {
    private let pillLabelView = PillLabelLayoutView()
    private var targetWidth: CGFloat = 0.0
    // MARK: - Constructors
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(pillLabelView)
        self.selectionStyle = .none
        self.bottomSeparator.isHidden = true
        self.topSeparator.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with tags: [Tag], style: PillLabel.PillStyle, targetWidth: CGFloat) {
        self.targetWidth = targetWidth
        pillLabelView.configure(with: tags, style: .grayFill, targetWidth: targetWidth)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pillLabelView.frame = CGRect(x: 20.0, y: 10.0, width: pillLabelView.w, height: pillLabelView.h)
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: pillLabelView.x + pillLabelView.h + 10.0)
    }
}
