//
//  BadgeView.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/17/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class BadgeLabel: UILabel {
    
    static let size = CGSize(width: 22, height: 22)
    static let offset: CGFloat = 4
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .accent
        textColor = .textColor
        layer.masksToBounds = true
        isHidden = true
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    var count: Int = 0 {
        didSet {
            text = String(count)
        }
    }
}
