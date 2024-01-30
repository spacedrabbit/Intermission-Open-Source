//
//  GridModuleTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - GridTableViewCell -

/// Simple table view cell to display a 2x2 grid of images, corresponding to Posts or VideoHistoryEntrys, on the Dashboard
class GridTableViewCell: TableViewCell {
    weak var delegate: GridModuleTableViewCellDelegate?
    
    private let headingLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.style = Styles.styles[Font.dashboardVideoHeaderText]
        return label
    }()
    
    private let chevronButton: ChevronButton = {
        let button = ChevronButton()
        button.setTitleColor(.cta, for: .normal)
        button.setTitleColor(.ctaHighlighted, for: .highlighted)
        button.isHidden = true
        return button
    }()
    
    private let topLeftImageView = ImageView()
    private let topRightImageView = ImageView()
    private let bottomLeftImageView = ImageView()
    private let bottomRightImageView = ImageView()
    private var imageViews: [ImageView] { return [topLeftImageView, topRightImageView,
                                                  bottomLeftImageView, bottomRightImageView] }
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        self.selectionStyle = .none
        
        chevronButton.addTarget(self, action: #selector(handleChevronTapped(sender:)), for: .touchUpInside)
        
        // View Setup
        self.contentView.addSubview(headingLabel)
        self.contentView.addSubview(chevronButton)
        
        imageViews.enumerated().forEach { (idx, imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.tag = idx
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTapped))
            imageView.addGestureRecognizer(tapGesture)
            
            self.contentView.addSubview(imageView)
        }
        
        // Constraints
        headingLabel.enforceHeightOnAutoLayout()
        headingLabel.setContentCompressionResistancePriority(.init(990.0), for: .horizontal)
        headingLabel.setContentHuggingPriority(.init(991.0), for: .horizontal)
        
        headingLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0).priority(999.0)
            make.top.equalToSuperview().offset(40.0)
        }
        
        // none of the sizes for the images are explicitly set, they are allowed to expand such that they maintain
        // 20.0pt outer margins and 10.0pt inner margins and that their widths == heights.
        topLeftImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0).priority(999.0)
            make.top.equalTo(headingLabel.snp.bottom).offset(10.0)
            make.height.equalTo(topLeftImageView.snp.width)
        }
        
        topRightImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0).priority(999.0)
            make.top.equalTo(headingLabel.snp.bottom).offset(10.0)
            make.leading.equalTo(topLeftImageView.snp.trailing).offset(10.0)
            make.size.equalTo(topLeftImageView)
        }
        
        bottomLeftImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.top.equalTo(topLeftImageView.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview().inset(20.0).priority(999.0)
            make.size.equalTo(topLeftImageView)
        }
        
        bottomRightImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0)
            make.top.equalTo(topRightImageView.snp.bottom).offset(10.0)
            make.leading.equalTo(bottomLeftImageView.snp.trailing).offset(10.0)
            make.bottom.equalToSuperview().inset(20.0).priority(999.0)
            make.size.equalTo(topLeftImageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Chevron button requires frames to layout correctly. does not work with autolayout
        chevronButton.sizeToFit()
        chevronButton.frame = CGRect(x: self.contentView.w - chevronButton.w - 20.0,
                                     y: headingLabel.y + ((headingLabel.h - chevronButton.h) / 2.0),
                                     width: chevronButton.w, height: chevronButton.h)
        
        topLeftImageView.layer.maskedCorners = .layerMinXMinYCorner
        topLeftImageView.layer.cornerRadius = 12.0
        
        bottomRightImageView.layer.maskedCorners = .layerMaxXMaxYCorner
        bottomRightImageView.layer.cornerRadius = 12.0
        
        bottomLeftImageView.layer.maskedCorners = .layerMinXMaxYCorner
        bottomLeftImageView.layer.cornerRadius = 12.0
    }
    
    // MARK: - Configure
    
    func configure(with videoEntries: [VideoHistoryEntry], style: DashboardCTAStyle) {
        headingLabel.styledText = style.headingText
        
        let normalStyle = Styles.styles[Font.chevronButtonNormal] ?? Style()
        let highlightStyle = Styles.styles[Font.chevronButtonHighlighted] ?? Style()
        chevronButton.isHidden = false
        
        chevronButton.setTitleColor(.cta, for: .normal)
        chevronButton.setTitleColor(.ctaHighlighted, for: .highlighted)
        chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: normalStyle), for: .normal)
        chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: highlightStyle), for: .highlighted)
        
        defer {
            headingLabel.setNeedsLayout()
            chevronButton.setNeedsLayout()
            imageViews.forEach { $0.setNeedsLayout() }

            self.layoutIfNeeded()
        }
        
        imageViews.enumerated().forEach { (idx, imageView) in
            guard videoEntries.count >= idx + 1 else {
                imageView.image = Icon.Hearts.filledHeartedDark.image
                imageView.contentMode = .center
                
                let borderView = CAShapeLayer()
                borderView.strokeColor = UIColor.cta.cgColor
                borderView.lineDashPattern = [2, 4]
                borderView.lineWidth = 2.0
                borderView.frame = imageView.bounds
                borderView.fillColor = nil
                borderView.path = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: 6.0).cgPath
                imageView.layer.addSublayer(borderView)
                
                return
            }
            
            imageView.contentMode = .scaleAspectFill
            imageView.setImage(url: videoEntries[idx].thumbnailURL)
        }

    }
    
    // MARK: - Action Handling
    
    @objc
    private func handleVideoTapped(sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        delegate?.gridModuleTableViewCell(self, didSelectItem: index)
    }
    
    @objc
    private func handleChevronTapped(sender: Button) {
        delegate?.gridModuleTableViewCellDidPressCTA(self)
    }

}

// MARK: - GridModuleTableViewCellDelegate Protocol -

protocol GridModuleTableViewCellDelegate: class {
    
    func gridModuleTableViewCell(_ gridModuleTableViewCell: GridTableViewCell, didSelectItem index: Int)
    
    func gridModuleTableViewCellDidPressCTA(_ gridModuleTableViewCell: GridTableViewCell)
    
}
