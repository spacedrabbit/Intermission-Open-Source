//
//  PillButtonLayoutView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/// Simple view for laying out tag pills. This class needs revisiting for layout cleanup and refactor
class PillLabelLayoutView: UIView {
    private var pillLabels: [PillLabel] = []
    private var targetWidth: CGFloat = 0.0
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with tags: [Tag], style: PillLabel.PillStyle, targetWidth: CGFloat) {
        if pillLabels.count > 0 {
            pillLabels.forEach { $0.removeFromSuperview() }
            pillLabels = []
        }
        self.targetWidth = targetWidth
        
        pillLabels = tags.map {
            let pillLabel = PillLabel(style: style)
            pillLabel.text = $0.title.uppercased()
            pillLabel.sizeToFit()
            self.addSubview(pillLabel)
            return pillLabel
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horzMargin: CGFloat = 8.0
        let vertMargin: CGFloat = 6.0
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        
        let maxWidth: CGFloat = max(0.0, self.targetWidth)
        
        // Simply put: layout pills in a left-to-right so long as there's enough horizontal space
        // When there isn't, update the yPos value and start the next row
        for pill in pillLabels {
            pill.frame = CGRect(x: xPos, y: yPos,
                                width: pill.intrinsicContentSize.width,
                                height: pill.intrinsicContentSize.height)
            if (pill.x + pill.w) > maxWidth {
                yPos += pill.h + vertMargin
                xPos = 0.0
                pill.frame = CGRect(x: xPos, y: yPos, width: pill.w, height: pill.h)
                xPos += pill.w + horzMargin
            } else {
                xPos += pill.w + horzMargin
            }
            
            if pill == pillLabels.last {
                yPos += pill.h + 15.0
            }
        }
        
        self.frame = CGRect(x: self.x, y: self.y, width: targetWidth, height: yPos)
    }
    
}

/**
 Simple view that lays out TagPillButtons. Do not attempt to set the height of this view's
 frame. Just set the required width and the elements will lay themselves out after you've used
 this class's "cofigure" method.
 
 */
class PillButtonLayoutView: UIView {
    weak var delegate: PillButtonLayoutViewDelegate?
    private var pillButtons: [TagPillButton] = []
    
    // MARK: - Actions
    
    @objc
    private func handleTagPillButtonTapped(sender: TagPillButton) {
        guard let index = pillButtons.index(of: sender),
            let tag = pillButtons[index].contentTag else { return }
        
        delegate?.pillButtonLayoutView(self, didPressPillButton: pillButtons[index], forTag: tag, at: index, tagSelected: sender.isSelected)
    }
    
    // MARK: - Configure
    
    func configure(with pills: [TagPillButton]) {
        self.isUserInteractionEnabled = true
        
        if pillButtons.count > 0 {
            pillButtons.forEach { $0.removeFromSuperview() }
            pillButtons = []
        }
        
        pillButtons = pills
        pillButtons.forEach {
            self.addSubview($0)
            // Ideally, this action fires on .touchDown, however because we have delegates observing
            // a .touchUpInside state, running an action on .touchDown means that the selection state for
            // the button isn't accurate since .touchDown occurs before .touchUpInside (naturally)
            $0.addTarget(self, action: #selector(handleTagPillButtonTapped(sender:)), for: .touchUpInside)
            $0.sizeToFit()
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horzMargin: CGFloat = 8.0
        let vertMargin: CGFloat = 6.0
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        
        // Simply put: layout pills in a left-to-right so long as there's enough horizontal space
        // When there isn't, update the yPos value and start the next row
        for pill in pillButtons {
            pill.frame = CGRect(x: xPos, y: yPos, width: pill.w, height: pill.h)
            if (pill.x + pill.w) > self.w {
                yPos += pill.h + vertMargin
                xPos = 0.0
                pill.frame = CGRect(x: xPos, y: yPos, width: pill.w, height: pill.h)
                xPos += pill.w + horzMargin
            } else {
                xPos += pill.w + horzMargin
            }
            
            if pill == pillButtons.last {
                yPos += pill.h + 15.0
            }
        }
        
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: yPos)
    }
}

// MARK: - PillButtonLayoutViewDelegate Protocol -

protocol PillButtonLayoutViewDelegate: class {

    func pillButtonLayoutView(_ pillButtonLayoutView: PillButtonLayoutView, didPressPillButton button: TagPillButton, forTag tag: Tag, at index: Int, tagSelected tagIsSelected: Bool)
    
}
