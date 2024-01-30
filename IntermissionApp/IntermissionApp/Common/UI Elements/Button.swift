//
//  Button.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class Button: UIButton, ActivityPresentable, Badgeable {
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.color = .cta
        return indicator
    }()
    
    private let badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .cta
        view.layer.cornerRadius = view.h / 2.0
        view.isHidden = true
        return view
    }()
    
    var badgePosition: BadgePosition  = .left
    var badgeHidesWhenZero: Bool {
        return true
    }
    
    // MARK: - Initializers -
    init() {
        super.init(frame: .zero)
        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func setupViewHierarchy() {
        addSubview(activityIndicator)
        addSubview(badgeView)
        activityIndicator.hidesWhenStopped = true
    }
    
    private func configureConstraints() {
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 40.0, height: 40.0))
        }
        
        badgeView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.trailing)
            make.centerY.equalTo(self.snp.top)
            make.width.height.equalTo(8.0)
        }
    }

    // MARK: - Activity Presentable -
    
    func showActivity() {
        isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func hideActivity() {
        isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    // MARK:- Badgeable
    
    func showBadge(_ count: Int, animated: Bool) {
        guard badgeView.isHidden else { return }
        
        if animated {
            badgeView.isHidden = false
            badgeView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.24, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [.beginFromCurrentState], animations: {
                self.badgeView.alpha = 1.0
                self.badgeView.transform = .identity
            }, completion: nil)
            
        } else {
            badgeView.isHidden = false
            badgeView.alpha = 1.0
        }
    }
    
    func hideBadge(animated: Bool) {
        guard !badgeView.isHidden else { return }
        
        if animated {
            
            UIView.animate(withDuration: 0.24, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: [.beginFromCurrentState], animations: {
                self.badgeView.alpha = 0.0
                self.badgeView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { (complete) in
                if complete {
                    self.badgeView.isHidden = true
                }
            }
            
        } else {
            badgeView.isHidden = true
            badgeView.alpha = 0.0
        }
    }
    
    func updateBadge(_ count: Int, animated: Bool) {
        // TODO
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        badgeView.layer.cornerRadius = badgeView.h / 2.0
    }
}

/// Styled CTA Button
final class CTAButton: Button {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted { self.backgroundColor = UIColor.ctaHighlighted }
            else { self.backgroundColor = UIColor.cta }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            self.backgroundColor = isEnabled
                ? UIColor.cta
                : UIColor.cta.withAlphaComponent(0.3)
        }
    }
    
    override init() {
        super.init()
        self.clipsToBounds = true
        self.backgroundColor = .cta
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ string: String) {
        self.setAttributedTitle(string.set(style: Font.ctaButton), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 8.0
    }
    
    class var defaultSize: CGSize {
        return CGSize(width: 250.0, height: 50.0)
    }
}

final class RoundedCTAButton: Button {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.ctaHighlighted
            }
            else {
                self.layer.borderColor = UIColor.white.cgColor
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    override init() {
        super.init()
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ string: String) {
        self.setAttributedTitle(string.set(style: Font.ctaButton), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 10.0, bottom: 2.0, right: 10.0)
        self.layer.cornerRadius = self.h / 2.0
    }
    
}

final class OutlineCTAButton: Button {
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted
                ? UIColor.navBarGreen.withAlphaComponent(0.15)
                : .clear
            
            self.layer.borderColor = isHighlighted
                ? UIColor.ctaHighlighted.cgColor
                : UIColor.cta.cgColor
        }
    }
    
    override init() {
        super.init()
        self.backgroundColor = .clear
        self.setTitleColor(UIColor.cta, for: .normal)
        self.layer.borderColor = UIColor.cta.cgColor
        self.layer.borderWidth = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ string: String) {
        self.setAttributedTitle(string.set(style: Font.invertedCTAButton), for: .normal)
        self.setAttributedTitle(string.set(style: Font.outlineCTAButtonHighlight), for: .highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
    
    class var defaultSize: CGSize {
        return CGSize(width: 250.0, height: 28.0)
    }
}

/// Inverted Styled CTA Button
final class InvertedCTAButton: Button {
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted
                ? .cta
                : .white
        }
    }
    
    override init() {
        super.init()
        self.backgroundColor = .white
        self.setTitleColor(UIColor.cta, for: .normal)
        self.layer.borderColor = UIColor.cta.cgColor
        self.layer.borderWidth = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ string: String) {
        self.setAttributedTitle(string.set(style: Font.invertedCTAButton), for: .normal)
        self.setAttributedTitle(string.set(style: Font.ctaButton), for: .highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
    
    class var defaultSize: CGSize {
        return CGSize(width: 250.0, height: 50.0)
    }
}

/// "Basic" button styling. Used in login/sign up
final class StandardButton: Button {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted { self.backgroundColor = UIColor.battleshipGrey }
            else { self.backgroundColor = UIColor.background }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled { self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0) }
            else { self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.75) }
        }
    }
    
    override init() {
        super.init()
        self.clipsToBounds = true
        self.backgroundColor = UIColor.background
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ string: String) {
        self.setAttributedTitle(string.set(style: Font.standardButton), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8.0
    }
}

/// Pre-styled button to use when needing to present a facebook login button
final class FacebookButton: Button {
    enum ButtonStyle {
        case signUp, login
    }
    
    private let iconMarginRatio: CGFloat = 0.14
    
    private let icon: ImageView = {
        let image = UIImage(named: "facebook_logo_blue")
        let imageView = ImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .facebookBlueDark
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted { self.backgroundColor = UIColor.facebookBlueDark }
            else { self.backgroundColor = UIColor.facebookBlue }
        }
    }
 
    override init() {
        super.init()
        
        self.backgroundColor = UIColor.facebookBlue
        self.adjustsImageWhenHighlighted = true
        self.addSubview(icon)
        self.addSubview(dividerView)
        
        // Push over the title to account for the space being given the Facebook icon
        self.titleEdgeInsets = UIEdgeInsets(top: self.titleEdgeInsets.top,
                                            left: self.w * iconMarginRatio,
                                            bottom: self.titleEdgeInsets.bottom,
                                            right: self.titleEdgeInsets.right)
        
        dividerView.isUserInteractionEnabled = false
        icon.isUserInteractionEnabled = false
        configure(with: .login)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with style: ButtonStyle) {
        switch style {
        case .login: self.setAttributedTitle("LOG IN WITH FACEBOOK".set(style: Font.ctaButton), for: .normal)
        case .signUp: self.setAttributedTitle("SIGN UP WITH FACEBOOK".set(style: Font.ctaButton), for: .normal)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        icon.frame.size = CGSize(width: 24.0, height: 24.0)
        // This centers the icon, which is offcenter by design, will look a little wonky
        icon.frame.origin = CGPoint(x: (self.w * iconMarginRatio * 0.5) - (icon.w / 2.0),
                                    y: (self.h - icon.h) / 2.0)
        
        dividerView.frame = CGRect(x: self.w * iconMarginRatio, y: 0.0, width: 1.0, height: self.h)
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
    }
}

class TogglingButton: Button {
//    private let normalStateImage: UIImage
//    private let selectedStateImage: UIImage
    
//    override var isHighlighted: Bool {
//        didSet {
//
//        }
//    }
//
    func setSelected(_ selected: Bool) {
        self.isSelected = selected
    }
    
//    override init(with normalImage: UIImage, toggledImage: UIImageView) {
//        super.init()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}

/**
 `ChevronButton` is a `UIButton` subclass that displays a text label with a chevron.
 
 Eg: VIEW ALL >
 
 The chevron is drawn dynamically, which means it can support any line width or size. It
 uses the button's title label for positioning and will match the button's title color for
 each control state. Calling `sizeToFit` or `sizeThatFits` will factor in the chevron when
 calculating the resulting size.
 */
class ChevronButton: Button {
    private let chevronLineWidth: CGFloat = 2.0
    private let chevronSpacing: CGFloat = 5.0
    private let chevronWidth: CGFloat = 5.0
    private let chevronVerticalMargin: CGFloat = 4.0
    private let chevronVerticalOffset: CGFloat = 0.0

    // MARK: - Constructors
    
    init(frame: CGRect = .zero) {
        super.init()
        self.contentHorizontalAlignment = .left
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    // MARK: - Highlighted & Selected Overrides
    
    override var isHighlighted: Bool {
        didSet { self.setNeedsDisplay() }
    }
    
    override var isSelected: Bool {
        didSet { self.setNeedsDisplay() }
    }
    
    // MARK: - Drawing
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let titleLabel = self.titleLabel, let titleColor = self.titleColor(for: self.state), titleLabel.frame != .zero else { return }
        
        let topY = titleLabel.y + chevronVerticalMargin + chevronVerticalOffset
        let bottomY = ((titleLabel.y + titleLabel.h) - chevronVerticalMargin) + chevronVerticalOffset
        let middleY = topY + ((bottomY - topY) / 2.0)
        
        let path = UIBezierPath()
        path.lineWidth = chevronLineWidth
        path.lineCapStyle = .round
        path.move(to: CGPoint(x: titleLabel.x + titleLabel.w + chevronSpacing, y: topY))
        path.addLine(to: CGPoint(x: titleLabel.x + titleLabel.w + chevronSpacing + chevronWidth, y: middleY))
        path.addLine(to: CGPoint(x: titleLabel.x + titleLabel.w + chevronSpacing, y: bottomY))
        titleColor.setStroke()
        path.stroke()
    }
    
    // MARK: - Sizing
    open override func sizeToFit() {
        let size = sizeThatFits(.zero)
        self.frame = CGRect(x: self.x, y: self.y, width: size.width, height: size.height)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var updatedSize = super.sizeThatFits(size)
        if size.width > 0.0 {
            // if the size's width is > 0.0, constrain the width to that size, if necessary
            updatedSize.width = min(size.width, updatedSize.width + chevronSpacing + chevronWidth + chevronLineWidth)
        } else {
            // if the size's width is 0.0, size to fit without any constraint
            updatedSize.width += chevronSpacing + chevronWidth + chevronLineWidth
        }
        return updatedSize
    }

}
