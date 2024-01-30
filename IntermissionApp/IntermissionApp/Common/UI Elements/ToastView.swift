//
//  ToastView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/// Banner to display notification text and an image
class ToastView: UIView {
    private var title: NSAttributedString?
    private var leftAccessory: ToastAccessory?
    private let style: ToastStyle
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        return label
    }()
    
    private let leftAccessoryView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    // MARK: - Initializers -
    
    init(style: ToastStyle) {
        self.style = style
        super.init(frame: .zero)
        
        self.clipsToBounds = true
        self.backgroundColor = style.backgroundColor.withAlphaComponent(0.90)
        self.layer.borderColor = style.borderColor?.cgColor
        self.layer.borderWidth = style.borderWidth
        
        // View Setup
        self.addSubview(titleLabel)
        self.addSubview(leftAccessoryView)
        
        // Constraints
        titleLabel.enforceHeightOnAutoLayout()
        
        // Re-enable the blur view later if it turns out we want it
//        blurView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
        leftAccessoryView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.trailing.equalToSuperview().inset(20.0).priority(990.0)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with text: String, highlightedText: String?, leftAccessory: ToastAccessory?) {
        
        let attrib: NSMutableAttributedString = NSMutableAttributedString(string: "")
        if let textStyle = style.textStyle {
            let allText = text.set(style: textStyle)
            
            if let highlightText = highlightedText, let highlightStyle = style.highlightTextStyle {
                allText.add(style: highlightStyle, range: (text as NSString).range(of: highlightText))
            }
            
            attrib.append(allText)
        }
        
        title = attrib
        titleLabel.attributedText = title
        
        if let accessory = leftAccessory {
            leftAccessoryView.image = accessory.image
            leftAccessoryView.isHidden = false
        } else {
            leftAccessoryView.image = nil
            leftAccessoryView.isHidden = true
        }
        
        remakeConstraintsIfNecessary()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout -
    
    private func remakeConstraintsIfNecessary() {
        
        if leftAccessoryView.image == nil {
            titleLabel.snp_remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(20.0)
                make.trailing.equalToSuperview().inset(20.0)
                make.centerY.equalToSuperview()
                make.top.bottom.equalToSuperview().offset(20.0).priority(990.0)
            }
        } else {
            titleLabel.snp.remakeConstraints { (make) in
                make.leading.equalTo(leftAccessoryView.snp.trailing).offset(20.0)
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(20.0).priority(990.0)
            }
            
            leftAccessoryView.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(20.0)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24.0)
                make.top.bottom.equalToSuperview().inset(20.0).priority(990.0)
            }
        }
        
    }
}

enum ToastAccessory {
    case heart, cart, checkmark
    
    var image: UIImage? {
        switch self {
        case .heart: return Icon.Hearts.outlineFilledRed.image
        case .cart: return Icon.NavBar.cartDark.image
        case .checkmark: return Icon.Checkmark.dark.image
        }
    }
}

// MARK: - Toast Styles -

enum ToastStyle {
    case accent
    
    var backgroundColor: UIColor {
        switch self {
        case .accent: return UIColor.accent
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .accent: return 0.0
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .accent: return nil
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .accent: return UIColor.textColor
        }
    }
    
    var textStyle: StyleProtocol? {
        switch self {
        case .accent: return Styles.styles[Font.toastRegularText]
        }
    }
    
    var highlightTextStyle: StyleProtocol? {
        switch self {
        case .accent: return Styles.styles[Font.toastHighlightedText]
        }
    }
}


/// Common types of Toasts we'll show

public enum ToastType {
    case favoritedVideo(name: String)
    case addedToCart(name: String)
    case sharedItem(name: String)
    case sentEmail(title: String)
}
