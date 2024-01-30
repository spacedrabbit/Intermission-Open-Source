//
//  UIView+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/31/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - Constraint Convenience -
extension UIView {
    
    /// Convenience for safeAreaLayoutGuide.topAnchor
    public var topSafeAnchor: NSLayoutYAxisAnchor { return self.safeAreaLayoutGuide.topAnchor }
    
    /// Convenience for safeAreaLayoutGuide.bottomAnchor
    public var bottomSafeAnchor: NSLayoutYAxisAnchor { return self.safeAreaLayoutGuide.bottomAnchor }
    
    /// Convenience for safeAreaLayoutGuide.leadingAnchor
    public var leadingSafeAnchor: NSLayoutXAxisAnchor { return self.safeAreaLayoutGuide.leadingAnchor }
    
    /// Convenience for safeAreaLayoutGuide.trailingAnchor
    public var trailingSafeAnchor: NSLayoutXAxisAnchor { return self.safeAreaLayoutGuide.trailingAnchor }
}

// MARK: - Frame Convenience -
extension UIView {
    
    /// Convenience for self.frame.origin.x
    public var x: CGFloat { return self.frame.origin.x }
    
    /// Convenience for self.frame.origin.y
    public var y: CGFloat { return self.frame.origin.y }
    
    /// Convenience for self.frame.size.width
    public var w: CGFloat { return self.frame.size.width }
    
    /// Convenience for self.frame.size.height
    public var h: CGFloat { return self.frame.size.height }
    
}

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    
}

extension Collection where Element == UIView {
    
    func removeContraints() {
        self.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
}

// MARK: - Snapshots

extension UIView {
    
    /**
     Note: This uses an older, slower, pre-iOS7 API. It can be more reliable in some scenarios though --
     like when snapshotting views that aren't currently part of the view heirarchy -- so we keep it around
     pretty much just for this purpose.
     
     */
    public func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
    
}


/**
 First responder-related extensions for `UIView`.
 
 */
extension UIView {
    
    public func findFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        
        for subview in self.subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
    
    public func findAndResignFirstResponder() {
        findFirstResponder()?.resignFirstResponder()
    }
    
}

/**
 Size to Fit extensions for `UIView`.
 
 */
extension UIView {
    
    public func sizeToFit(width: CGFloat, horizontalPadding: CGFloat = 0.0, verticalPadding: CGFloat = 0.0) {
        let maxWidth = max(0.0, width - (horizontalPadding * 2.0))
        var size = self.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        size.width = min(size.width, maxWidth)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size.width + (horizontalPadding * 2.0), height: size.height + (verticalPadding * 2.0))
    }
}

/**
 Working with shadows
 
 */

extension UIView {
    
    // This doesn't seem to work for some reason...
    var shadowOpacity: CGFloat {
        set { self.layer.shadowOpacity = Float(shadowOpacity) }
        get { return CGFloat(self.layer.shadowOpacity) }
    }
    
    var shadowRadius: CGFloat {
        set { self.layer.shadowRadius = shadowRadius }
        get { return self.layer.shadowRadius }
    }
    
    var shadowOffset: CGSize {
        set { self.layer.shadowOffset = shadowOffset }
        get { return self.layer.shadowOffset}
    }
    
    var shadowPath: CGPath? {
        set { self.layer.shadowPath = shadowPath }
        get { return self.layer.shadowPath }
    }
    
    var shadowColor: UIColor? {
        set { self.layer.shadowColor = shadowColor?.cgColor }
        get {
            guard let cg = self.layer.shadowColor else { return nil }
            return UIColor(cgColor: cg)
        }
    }
    
    func shadow(color: UIColor, opacity: CGFloat = 0.0, radius: CGFloat = 0.0, offset: CGSize = .zero) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = Float(opacity)
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
    }
    
    func applyShadowPath(cornerRadius: CGFloat) {
        guard superview != nil else { return }
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
