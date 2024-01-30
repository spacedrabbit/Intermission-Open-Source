//
//  AnimatedBarView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/12/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/** View that displays 2-3 labels and an animateable line that travels between them on tap.
 */
class AnimatedBarView: UIView {
    weak var delegate: AnimatedBarViewDelegate?
    private var barItemTitles: [String] = []
    private var labels: [StyledBarLabel] = []
    private var attributes: AnimatedBarViewAttributes
    
    private var _selectedIndex: Int = 999
    var selectedIndex: Int { return _selectedIndex }
    
    private let underlineView = UIView()
    private let trackView = UIView()

    private var targetWidth: CGFloat = 0.0
    
    init(with attributes: AnimatedBarViewAttributes = .default) {
        self.attributes = attributes
        super.init(frame: .zero)
        
        self.addSubview(trackView)
        self.addSubview(underlineView)
        
        trackView.backgroundColor = attributes.trackColor
        underlineView.backgroundColor = attributes.underlineColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with labelText: [String], targetWidth: CGFloat) {
        self.targetWidth = targetWidth
        
        if labels.count > 0 {
            labels.forEach { $0.removeFromSuperview() }
            labels.removeAll()
            barItemTitles.removeAll()
        }
        
        barItemTitles = labelText
        labels = labelText.map(generateLabelItem)
        labels.forEach { self.addSubview($0) }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func generateLabelItem(_ text: String) -> StyledBarLabel {
        let label = StyledBarLabel(with: attributes)
        label.setStyledText(text)
        return label
    }
    
    func setSelected(_ index: Int, animated: Bool = true, normalizeUnderline: Bool = false) {
        guard index <= labels.count else { return }
        guard index != _selectedIndex else { return }
        
        _selectedIndex = index
        labels.forEach { $0.set(selected: false) }
        labels[index].set(selected: true)
        
        // We need to make sure the labels are laid out properly before we can accurately
        // draw the line, so do one more layout pass.
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let normalizationFactor: CGFloat = normalizeUnderline ? 1.55 : 1.0
        let lineWidth = labels[index].w * normalizationFactor
        let lineCenter = labels[index].x + (labels[index].w / 2.0)
        let underlineViewRect = CGRect(x: lineCenter - (lineWidth / 2.0), y: self.h - 3.0, width: lineWidth, height: 3.0)
        
        guard animated else {
            self.underlineView.frame = underlineViewRect
            return
        }

        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [.beginFromCurrentState], animations: {
            self.underlineView.frame = underlineViewRect
        }, completion: nil)
    }
    
    @objc
    func handleTapped(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: self)
        if labels.count == 2 { // find which 1/2 the screen the tap was on
            if location.x <= (self.w / 2.0) {
                setSelected(0)
                self.delegate?.animatedBarView(self, didSelectItemAt: 0)
            } else {
                setSelected(1)
                self.delegate?.animatedBarView(self, didSelectItemAt: 1)
            }
        } else if labels.count == 3 { // find with 1/3 the screen the tap was on
            if location.x <= (self.w * 0.334) {
                setSelected(0)
                self.delegate?.animatedBarView(self, didSelectItemAt: 0)
            } else if location.x > (self.w * 0.334) && location.x <= (self.w * 0.667) {
                setSelected(1)
                self.delegate?.animatedBarView(self, didSelectItemAt: 1)
            } else {
                setSelected(2)
                self.delegate?.animatedBarView(self, didSelectItemAt: 2)
            }
        }
    }
    
    // Assumes either 2 or 3 labels, and that the length of the labels dont exceed the width of the bar view
    override func layoutSubviews() {
        super.layoutSubviews()
        labels.forEach{ $0.sizeToFit() }
        let bottomOffset: CGFloat = 8.0
        let w = max(self.w, targetWidth)
        
        if labels.count == 2 {
            let totalLabelWidth = labels.reduce(0.0) { (result, label) -> CGFloat in result + label.w }
            let layoutSpace = w - totalLabelWidth
            let unit = layoutSpace / 8.0
            
            labels[0].frame = CGRect(x: (w / 2.0) - unit - labels[0].w, y: (self.h - labels[0].h - bottomOffset),
                                     width: labels[0].w, height: labels[0].h)
            labels[1].frame = CGRect(x: labels[0].x + labels[0].w + unit + unit, y: (self.h - labels[1].h - bottomOffset),
                                     width: labels[1].w, height: labels[1].h)
        } else if labels.count == 3 { // simply left-edge, right-edge and center align
            labels[0].frame = CGRect(x: 0.0, y: (self.h - labels[0].h - bottomOffset), width: labels[0].w, height: labels[0].h)
            labels[1].frame = CGRect(x: (w - labels[1].w) / 2.0, y: (self.h - labels[1].h - bottomOffset), width: labels[1].w, height: labels[1].h)
            labels[2].frame = CGRect(x: (w - labels[2].w), y: (self.h - labels[2].h - bottomOffset), width: labels[2].w, height: labels[2].h)
        }
        
        trackView.frame = CGRect(x: 0.0, y: self.h - 2.0, width: w, height: 1.0)
        underlineView.layer.cornerRadius = underlineView.h / 2.0
        
        self.frame = CGRect(x: self.x, y: self.y, width: w, height: AnimatedBarView.height)
    }
    
    // MARK: - Helpers
    
    class var height: CGFloat {
        return 40.0
    }
    
    func updateBadging(forLabelWith value: String, count: Int) {
        
        guard let label = labels.filter({ $0.styledText?.lowercased() == value.lowercased() }).first else { return }
        label.showBadge(count, animated: true)
    }
    
    func currentBadgeCount(forLabelWith value: String) -> Int? {
        guard let label = labels.filter({ $0.styledText?.lowercased() == value.lowercased() }).first else { return nil }
        return label.currentBadgeCount()
    }
}

// MARK: - AnimatedBarViewDelegate Protocol -

protocol AnimatedBarViewDelegate: class {
    
    func animatedBarView(_ animatedBarView: AnimatedBarView, didSelectItemAt index: Int)
    
}

// MARK: - AnimatedBarViewAttributes -

struct AnimatedBarViewAttributes {
    let trackColor: UIColor
    let underlineColor: UIColor
    let backgroundColor: UIColor
    let activeTextStyle: Style
    let inactiveTextStyle: Style
    
    /// Used for store and profile. text/lightText color fonts, accent lines
    static var `default`: AnimatedBarViewAttributes {
        let active = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 13.0)
            $0.color = UIColor.textColor
            $0.kerning = .point(1.18)
            $0.alignment = .center
        }
        
        let inactive = Style {
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 13.0)
            $0.color = UIColor.lightTextColor
            $0.kerning = .point(1.0)
            $0.alignment = .center
        }
        
        return AnimatedBarViewAttributes(trackColor: .secondaryBackground,
                                         underlineColor: .accent,
                                         backgroundColor: .clear,
                                         activeTextStyle: active,
                                         inactiveTextStyle: inactive)
    }
    
    /// Used in Login, white text & lines
    static var lightBackground: AnimatedBarViewAttributes {
        let active = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 13.0)
            $0.color = UIColor.background
            $0.kerning = .point(1.18)
            $0.alignment = .center
        }
        
        let inactive = Style {
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 13.0)
            $0.color = UIColor.background
            $0.kerning = .point(1.0)
            $0.alignment = .center
        }
        
        return AnimatedBarViewAttributes(trackColor: .background,
                                         underlineColor: .background,
                                         backgroundColor: .clear,
                                         activeTextStyle: active,
                                         inactiveTextStyle: inactive)
    }
    
    /// Used in Filter, white/light text color text & lines
    static var darkBackground: AnimatedBarViewAttributes {
        let active = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 13.0)
            $0.color = UIColor.white
            $0.kerning = .point(1.18)
            $0.alignment = .center
        }
        
        let inactive = Style {
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 13.0)
            $0.color = UIColor.lightTextColor
            $0.kerning = .point(1.0)
            $0.alignment = .center
        }
        
        return AnimatedBarViewAttributes(trackColor: .lightTextColor,
                                         underlineColor: .white,
                                         backgroundColor: .clear,
                                         activeTextStyle: active,
                                         inactiveTextStyle: inactive)
    }
}
