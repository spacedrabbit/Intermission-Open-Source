//
//  TableViewCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

class TableViewCell: UITableViewCell, ActivityPresentable {
    private let reloadView: ReloadView = ReloadView()
    private static let separatorHeight: CGFloat = 1.0
    
    var contentInsets = UIEdgeInsets(top: separatorHeight, left: 0.0, bottom: separatorHeight, right: 0.0) {
        didSet {
            if oldValue == contentInsets { return }
            else {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    public let topSeparator: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .secondaryBackground
        view.isHidden = true
        return view
    }()
    
    public let bottomSeparator: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .secondaryBackground
        view.isHidden = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .background
        self.contentView.backgroundColor = .clear

        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = .white
        self.backgroundView?.addSubview(topSeparator)
        self.backgroundView?.addSubview(bottomSeparator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = CGRect(x: contentInsets.left,
                                        y: contentInsets.top,
                                        width: max(0.0, self.frame.w - (contentInsets.left + contentInsets.right)),
                                        height: max(0.0, self.frame.h - (contentInsets.top + contentInsets.bottom)))
        
        topSeparator.frame = CGRect(x: contentInsets.left,
                                    y: 0.0,
                                    width: max(0.0, self.frame.w - (contentInsets.left)),
                                    height: TableViewCell.separatorHeight)
        bottomSeparator.frame = CGRect(x: contentInsets.left,
                                       y: self.frame.h - TableViewCell.separatorHeight,
                                       width: max(0.0, self.frame.w - (contentInsets.left)),
                                       height: TableViewCell.separatorHeight)
    }
    
    // MARK: - Activity Presentable -
    
    func showActivity() {
        guard reloadView.superview == nil else {
            reloadView.removeFromSuperview()
            showActivity()
            return
        }
        
        reloadView.alpha = 0.0
        self.contentView.addSubview(reloadView)
        self.contentView.bringSubviewToFront(reloadView) // sanity
        reloadView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        reloadView.startAnimating()
        UIView.animate(withDuration: 0.15) {
            self.reloadView.alpha = 1.0
        }
    }
    
    func hideActivity() {
        guard reloadView.superview != nil else { return }
        reloadView.removeFromSuperview()
        reloadView.stopAnimating()
    }
}

// MARK: - BorderCell -

/** Basic cell to display a "border" image, which is usually a
 landscape image asset that resembles a curved line.
 
 */
class BorderCell: TableViewCell {
    private static let defaultInsets: UIEdgeInsets = .zero
    private var ia_heightConstraint: SnapKit.Constraint?
    
    private let borderImage: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    enum Style {
        case lavenderTop, lavenderBottom,
        navGreenBottom,
        whiteTop, whiteBottom
    }
    
    var insets: UIEdgeInsets = defaultInsets {
        didSet {
            if insets == oldValue { return }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentInsets = insets
        self.bottomSeparator.isHidden = true
        self.contentView.addSubview(borderImage)
        
        borderImage.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().priority(999.0)
            
            self.ia_heightConstraint = make.height.equalToSuperview().constraint
            self.ia_heightConstraint?.deactivate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with style: BorderCell.Style, targetInsets: UIEdgeInsets? = nil, targetHeight: CGFloat? = nil) {
        switch style {
        case .lavenderTop:
            borderImage.image = Decorative.Wave.lavendarWaveTopCap.image
            
        case .lavenderBottom:
            borderImage.image = Decorative.Wave.lavendarWaveBottomCap.image

        case .navGreenBottom:
            borderImage.image = Decorative.Wave.greenWave.image
            
        case .whiteTop:
            borderImage.image = Decorative.Wave.lightWaveTop.image
            
        case .whiteBottom:
            borderImage.image = Decorative.Wave.lightWaveBottom.image
        }
        
        if let height = targetHeight {
            // If the heightContraint exists, we need to update it
            if let _ = ia_heightConstraint {
                borderImage.snp.updateConstraints { (make) in
                    self.ia_heightConstraint = make.height.equalTo(height).priority(999.0).constraint
                }
            } else {
                borderImage.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                    make.width.equalToSuperview().priority(999.0)
                    self.ia_heightConstraint = make.height.equalTo(height).priority(999.0).constraint
                }
            }
        }
        
        if let insets = targetInsets {
            self.insets = insets // this already calls a layout pass, so just return now
            return
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

// MARK: - ButtonCell -

/** Simple cell with a standard CTA button. Interacts via delegation.
 
 */
class ButtonCell: TableViewCell {
    private let button = CTAButton()
    weak var delegate: ButtonCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(button)
        button.addTarget(self, action: #selector(handleButtonPressed), for: .touchUpInside)
        
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(50.0)
            make.width.equalTo(250.0)
            make.top.equalToSuperview().offset(40.0).priority(990.0)
            make.bottom.equalToSuperview().inset(20.0).priority(989.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func setButtonText(_ text: String) {
        button.setText(text)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleButtonPressed() {
        delegate?.buttonCellWasTapped(self)
    }
    
    // MARK: - Helpers
    
    class var height: CGFloat {
        return 110.0
    }
}

// MARK: - ButtonCellDelegate Protocol -

protocol ButtonCellDelegate: class {
    
    func buttonCellWasTapped(_ buttonCell: ButtonCell)
    
}

// MARK: - LabelTextCell -

/// Simple cell with a stylized text label.
class LabelTextCell: TableViewCell {
    
    private let label: Label = {
        let label = Label()
        label.style = Styles.styles[Font.helperText]
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(label)
        
        label.setAutoLayoutHeightEnforcement(990.0)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(16.0)
            make.bottom.equalToSuperview().inset(16.0)
            make.width.equalToSuperview().inset(40.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelText(_ text: String) {
        label.styledText = text
    }
}
