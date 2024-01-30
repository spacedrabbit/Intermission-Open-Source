//
//  TagPillButton.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/// Use as a Hashable-conforming, direct-analog to UIControl.State
enum ControlState: String {
    case normal, selected, highlighted
}

/// Simple button class with a PillLabel subview
class TagPillButton: Button {
    private let pillLabel: PillLabel = PillLabel()

    private let horizontalMargin: CGFloat = 12.0
    private let verticalMargin: CGFloat = 4.0
    private(set) var contentTag: Tag?
    
    private let pillStyles: [ControlState : PillLabel.PillStyle] = [
        .normal : .whiteOutline,
        .selected: .lightGreenOutline,
        .highlighted: .lightGreenOutline
    ]
    
    override var isHighlighted: Bool {
        // Show highlighted state, but if not highlighted then defer to it's selected-state style
        didSet {
            pillLabel.pillStyle = isHighlighted
                ? pillStyles[.highlighted] ?? pillLabel.pillStyle
                : isSelected
                    ? (pillStyles[.selected] ?? pillLabel.pillStyle)
                    : (pillStyles[.normal] ?? pillLabel.pillStyle)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            pillLabel.pillStyle = isSelected
                ? pillStyles[.selected] ?? pillLabel.pillStyle
                : pillStyles[.normal] ?? pillLabel.pillStyle
        }
    }
    
    
    // MARK: - Constructors
    
    override init() {
        super.init()
        self.backgroundColor = .clear
        
        self.addSubview(pillLabel)
        self.sendSubviewToBack(pillLabel)
        
        pillLabel.clipsToBounds = true
        pillLabel.pillStyle = pillStyles[.normal] ?? .lightGreenOutline

        self.addTarget(self, action: #selector(handleTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with tag: Tag) {
        self.contentTag = tag
        self.updateText(tag.title.uppercased())
    }
    
    func updateText(_ text: String) {
        pillLabel.text = text
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pillLabel.frame = CGRect(x: 0.0, y: 0.0,
                                 width: pillLabel.intrinsicContentSize.width,
                                 height: pillLabel.intrinsicContentSize.height)
        self.bounds = pillLabel.bounds
    }
    
    // MARK: - Actions
    
    @objc
    private func handleTapped() {
        isSelected.toggle()
    }
}
