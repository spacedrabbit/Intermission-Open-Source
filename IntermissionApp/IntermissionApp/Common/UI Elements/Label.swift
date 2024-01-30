//
//  Label.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Nantes
import SwiftRichString

class Label: UILabel, Badgeable {
    
    // MARK: - Badging
    private let badgeView = BadgeLabel()
    var badgePosition: BadgePosition  = .left
    var badgeHidesWhenZero: Bool { return true }
    
    private var inset: CGFloat = 0 {
        didSet {
            sizeToFit()
            setNeedsDisplay()
            // causes the label to correctly resize itself, making room for the badge
            invalidateIntrinsicContentSize()
        }
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0,
                                       left: badgePosition == .left ? inset : 0,
                                       bottom: 0,
                                       right: badgePosition == .right ? inset : 0)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset,
                      height: size.height)
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    // MARK: - Badgeable
    
    func showBadge(_ count: Int, animated: Bool) {
        
        guard badgeView.superview == nil else {
            badgeView.removeFromSuperview()
            showBadge(count, animated: animated)
            return
        }
        badgeView.count = count
        inset = BadgeLabel.size.width + BadgeLabel.offset
        addSubview(badgeView)
        bringSubviewToFront(badgeView) // sanity
        badgeView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(BadgeLabel.size)
            let edge = badgePosition == .left ? make.leading : make.right
            edge.equalToSuperview()
        }
        
        badgeView.isHidden = badgeHidesWhenZero && count == 0
        
        if animated {
            badgeView.alpha = 0
            UIView.animate(withDuration: 0.15) {
                self.badgeView.alpha = 1
            }
        }
    }
    
    func hideBadge(animated: Bool) {
        guard badgeView.superview != nil else { return }
        
        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.badgeView.alpha = 0
            }) { _ in
                self.inset = 0
                self.badgeView.removeFromSuperview()
                self.badgeView.alpha = 1
            }
        } else {
            inset = 0
            badgeView.removeFromSuperview()
        }
    }
    
    func updateBadge(_ count: Int, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.1, animations: {
                self.badgeView.alpha = 0
            }) { _ in
                self.badgeView.isHidden = self.badgeHidesWhenZero && count == 0
                self.badgeView.count = count
                UIView.animate(withDuration: 0.1, animations: {
                    self.badgeView.alpha = 1
                })
            }
        } else {
            badgeView.count = count
            badgeView.isHidden = badgeHidesWhenZero && count == 0
        }
    }
    
    func currentBadgeCount() -> Int {
        return badgeView.count
    }
}

/// LinkLabel is a thin wrapper around a NantesLabel for handling link detections
/// See https://github.com/instacart/Nantes/blob/master/Example/Nantes/ViewController.swift for futher customizations later on
class LinkLabel: NantesLabel, NantesLabelDelegate {
    
    enum LinkLabelStyle {
        case cta, white
    }
    
    static let placeholderLink = URL(string: "http://about:blank")
    weak var linkDelegate: LinkLabelDelegate?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.delegate = self
        
        self.linkAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.cta,
            NSAttributedString.Key.font : UIFont.caption1,
        ]
        
        self.activeLinkAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.ctaHighlighted,
            NSAttributedString.Key.font : UIFont.caption1,
        ]
    }
    
    convenience init(style: LinkLabelStyle) {
        self.init()
        
        switch style {
        case .cta:
            self.linkAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.cta,
                NSAttributedString.Key.font : UIFont(name: Font.identifier(for: .bold), size: 13.0) ?? UIFont.caption1
            ]
            
            self.activeLinkAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.ctaHighlighted,
                NSAttributedString.Key.font : UIFont(name: Font.identifier(for: .bold), size: 13.0) ?? UIFont.caption1
            ]
            
        case .white:
            self.linkAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont(name: Font.identifier(for: .bold), size: 13.0) ?? UIFont.caption1
            ]
            
            self.activeLinkAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.navBarGreen,
                NSAttributedString.Key.font : UIFont(name: Font.identifier(for: .bold), size: 13.0) ?? UIFont.caption1
            ]
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLinkText(_ text: String, linkText: String, url: URL? = LinkLabel.placeholderLink, delegate: LinkLabelDelegate? = nil) {
    
        self.attributedText = text.set(style: Font.helperText)
        guard let url = url, text.contains(linkText) else { return }
        self.addLink(to: url, withRange: (text as NSString).range(of: linkText))
        self.linkDelegate = delegate
    }
    
    // MARK: - NantesLabelDelegate -
    
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        self.linkDelegate?.linkLabel(self, didSelectLink: link)
    }

}

protocol LinkLabelDelegate: class {
    func linkLabel(_ linkLabel: LinkLabel, didSelectLink link: URL)
}


/// For use in AnimatedBarView only. Note, setting this label's attributed text has no effect.
final class StyledBarLabel: Label {
    private let attributes: AnimatedBarViewAttributes
    
    private var isSelected: Bool = false {
        didSet {
            if isSelected == oldValue { return }
            if let text = self.attributedText?.string, isSelected {
                self.attributedText = text.set(style: attributes.activeTextStyle)
            } else if let text = self.attributedText?.string, !isSelected {
                self.attributedText = text.set(style: attributes.inactiveTextStyle)
            }
        }
    }
    
    init(with attributes: AnimatedBarViewAttributes) {
        self.attributes = attributes
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyledText(_ text: String) {
        let style = isSelected ? attributes.activeTextStyle : attributes.inactiveTextStyle
        self.attributedText = text.set(style: style)
    }
    
    func set(selected: Bool) {
        isSelected = selected
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
