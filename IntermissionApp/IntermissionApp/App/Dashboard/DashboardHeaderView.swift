//
//  DashboardHeaderView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/7/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - DashboardHeaderView -

/// Displays user's name in the Dashboard, along with optional motivational messages
class DashboardHeaderView: UIView {
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = StylesManager.shared.styles[Font.largeHeaderTitle]
        label.styledText = " "
        return label
    }()
    
    // MARK: - Constructors -
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(with text: String) {
        titleLabel.styledText = text
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 20.0
        let maxWidth: CGFloat = self.w - margin - margin
        
        titleLabel.sizeToFit(width: maxWidth)
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: DashboardHeaderView.height)
        titleLabel.frame = CGRect(x: margin, y: self.h - titleLabel.h - margin,
                                  width: titleLabel.w, height: titleLabel.h)
    }
    
    class var height: CGFloat {
        return 120.0
    }
}
