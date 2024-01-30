//
//  UILabel+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/29/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - Autolayout Helpers -

extension UILabel {
    
    /// Sets compression resistance and hugging to .required on .horizontal & .vertical axis.
    func enforceSizeOnAutoLayout() {
        enforceWidthOnAutoLayout()
        enforceHeightOnAutoLayout()
    }
    
    /// Sets compression resistance and hugging to 999.0 on horizontal & vertical axis.
    /// You typically use this (instead of `enforeSizeOnAutoLayout`) in cases where your
    /// required constraints might conflict with temporary constraints the AutoLayout engine
    /// makes. These cases are usually when you'll setting a cell's dynamic height in either
    /// a tableview cell or collection view cell.
    func safelyEnforceSizeOnAutoLayout() {
        safelyEnforceWidthOnAutoLayout()
        safelyEnforceHeightOnAutoLayout()
    }
    
    func enforceWidthOnAutoLayout() {
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func enforceHeightOnAutoLayout() {
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func safelyEnforceWidthOnAutoLayout() {
        self.setContentCompressionResistancePriority(.almostRequired, for: .horizontal)
        self.setContentHuggingPriority(.almostRequired, for: .horizontal)
    }
    
    func safelyEnforceHeightOnAutoLayout() {
        self.setContentCompressionResistancePriority(.almostRequired, for: .vertical)
        self.setContentHuggingPriority(.almostRequired, for: .vertical)
    }
    
    func setAutoLayoutHeightEnforcement(_ value: Float) {
        var _value = value
        if value < 0 { _value = 0 }
        else if value > 1000.0 { _value = 1000.0 }
        
        self.setContentCompressionResistancePriority(.init(_value), for: .vertical)
        self.setContentHuggingPriority(.init(_value), for: .vertical)
    }
    
    func setAutoLayoutWidthEnforcement(_ value: Float) {
        var _value = value
        if value < 0 { _value = 0 }
        else if value > 1000.0 { _value = 1000.0 }
        
        self.setContentCompressionResistancePriority(.init(_value), for: .horizontal)
        self.setContentHuggingPriority(.init(_value), for: .horizontal)
    }
    
    func setAutoLayoutHeightEnforcement(lowerThan otherLabel: UILabel) {
        let hugging = otherLabel.contentHuggingPriority(for: .vertical)
        let compression = otherLabel.contentCompressionResistancePriority(for: .vertical)
        
        self.setAutoLayoutHeightEnforcement(min(hugging.rawValue, compression.rawValue) - 1.0)
    }
    
    func setAutoLayoutHeightEnforcement(lowerThan constraint: NSLayoutConstraint, by value: CGFloat = 1.0) {
        self.setAutoLayoutHeightEnforcement(constraint.priority.rawValue - Float(value))
    }
    
    func setAutoLayoutWidthEnforcement(lowerThan otherLabel: UILabel) {
        let hugging = otherLabel.contentHuggingPriority(for: .horizontal)
        let compression = otherLabel.contentCompressionResistancePriority(for: .horizontal)
        
        self.setAutoLayoutHeightEnforcement(min(hugging.rawValue, compression.rawValue) - 1.0)
    }
    
    func setAutoLayoutWidthEnforcement(lowerThan constraint: NSLayoutConstraint, by value: CGFloat = 1.0) {
        self.setAutoLayoutWidthEnforcement(constraint.priority.rawValue - Float(value))
    }
}

extension UILayoutPriority {
    
    static let almostRequired: UILayoutPriority = UILayoutPriority(999.0)
    
}
