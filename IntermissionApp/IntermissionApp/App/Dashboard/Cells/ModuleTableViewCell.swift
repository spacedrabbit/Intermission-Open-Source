//
//  ModuleTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

// MARK: - ModuleTableViewCell -

// TODO: @Louis refactor out of base
class ModuleTableViewCell: TableViewCell {
    
    let headingLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.dashboardVideoHeaderText]
        return label
    }()
    
    let chevronButton: ChevronButton = {
        let button = ChevronButton()
        button.setTitleColor(.cta, for: .normal)
        button.setTitleColor(.ctaHighlighted, for: .highlighted)
        
        return button
    }()
            
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        selectionStyle = .none
        contentView.addSubview(headingLabel)
        contentView.addSubview(chevronButton)
        
        self.contentView.backgroundColor = .white
        
        chevronButton.addTarget(self, action: #selector(handleChevronTapped(sender:)), for: .touchUpInside)
    }
    
    func setupConstraints() {
        headingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        headingLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        headingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44.0)
            make.leading.equalToSuperview().offset(20.0)
        }

        // no bottom constraints, subclass to implement the rest of the constraints
    }
    
    @objc
    func handleChevronTapped(sender: Button) {
        fatalError("Must be implemented in subclasses")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horizontalMargin: CGFloat = 20.0
        
        // TODO: seems like this mixed approach is totally fine. replace autolayout components w/ frames as needed
        chevronButton.sizeToFit()
        chevronButton.frame = CGRect(x: self.contentView.w - horizontalMargin - chevronButton.w,
                                     y: headingLabel.y + ((headingLabel.h - chevronButton.h) / 2.0),
                                     width: chevronButton.w, height: chevronButton.h)
    }
}
