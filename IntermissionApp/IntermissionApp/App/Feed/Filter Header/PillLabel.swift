//
//  PillView.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 1/28/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// TODO: Selection & Highlight States
/**
 A "pill" styled label. Pills are able to calculate their own required size, so do not directly
 adjust this view's frame.size. Simply position where you want it to be.
 
 */
class PillLabel: Label {
    private let horizontalMargin: CGFloat = 12.0
    private let verticalMargin: CGFloat = 4.0
    
    enum PillStyle {
        case lightGreenFill
        case lightGreenOutline
        case whiteOutline
        case lavenderFill
        case grayFill
    }
    
    override var text: String? {
        didSet { configure(for: pillStyle) }
    }
    
    var pillStyle: PillStyle = .grayFill {
        didSet { configure(for: pillStyle) }
    }
    
    /*
     We create a rect inset from the original to effectively push out the bounds of the label so
     that we have space between the text and the edges of the view.
     
    */
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: horizontalMargin, dy: -verticalMargin))
    }
    
    // MARK: - Initializers
    
    convenience init(style: PillStyle = .grayFill) {
        self.init()
        self.pillStyle = style
        self.layer.masksToBounds = true
        self.textAlignment = .center
    }
    
    private override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func configure(for style: PillStyle) {
        switch style {
        case .lightGreenFill:
            self.backgroundColor = .lightGreen
            self.layer.borderColor = nil
            self.layer.borderWidth = 0.0
            self.textColor = .white
            self.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            
        case .lightGreenOutline:
            self.backgroundColor = .clear
            self.layer.borderColor = UIColor.lightGreen.cgColor
            self.layer.borderWidth = 1.0
            self.textColor = .lightGreen
            self.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            
        case .whiteOutline:
            self.backgroundColor = .clear
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 1.0
            self.textColor = .white
            self.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            
        case .lavenderFill:
            self.backgroundColor = .paleLavendar
            self.layer.borderColor = nil
            self.layer.borderWidth = 0.0
            self.textColor = .textColor
            self.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            
        case .grayFill:
            self.backgroundColor = .paleLavendar
            self.layer.borderColor = nil
            self.layer.borderWidth = 0.0
            self.textColor = .tagTextColor
            self.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Drawing & Layout
    
    // Overriding drawText requires that we override intrinsicContentSize
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += (2.0 * horizontalMargin)
        contentSize.height += (2.0 * verticalMargin)
        return contentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.h / 2.0
    }
}
