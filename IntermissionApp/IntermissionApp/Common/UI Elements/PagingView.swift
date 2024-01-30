//
//  PagingView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/30/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - PagingView -

/** A scrollview that allows paging between a set of managed subviews
 */
final class PagingView: UIScrollView {
    weak var pageDelegate: PagingViewDelegate?
    
    // Each managed view gets placed in a scrollView to allow for vertical scrolling
    private var containerViews = [UIScrollView]()
    private var managedViews = [UIView]()
    private var maxHeight: CGFloat?
    private var managedViewContainerInset: UIEdgeInsets = .zero
    private var targetWidth: CGFloat = 0.0
    
    private var _currentIndex: Int = 0
    var currentIndex: Int { return _currentIndex }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        
        self.isPagingEnabled = true
        self.clipsToBounds = true
        
        self.delegate = self
        
        // This is needed b/c we're messing with the safe area insets in the VC this is being presented in.
        // And apparently, this container scroll view inherits the safe insets from it's first parent?
        self.contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with views: [UIView], inset: UIEdgeInsets = .zero, maxHeight: CGFloat? = nil, targetWidth: CGFloat) {
        self.targetWidth = targetWidth
        self.maxHeight = maxHeight
        self.managedViewContainerInset = inset
        
        // Clear managed views
        managedViews.forEach { $0.removeFromSuperview() }
        managedViews.removeAll()
        
        // Clear container views
        containerViews.forEach { $0.removeFromSuperview() }
        containerViews.removeAll()

        views.forEach {
            $0.isUserInteractionEnabled = true
            managedViews.append($0)
            
            let container = UIScrollView()
            container.alwaysBounceVertical = true
            container.addSubview($0)
            
            // This is needed b/c we're messing with the safe area insets in the VC this is being presented in.
            // And apparently, this container scroll view inherits the safe insets from it's first parent??
            // If we don't set this to never, the content gets inset to whichever value the VC has. weird.
            container.contentInsetAdjustmentBehavior = .never
            
            containerViews.append(container)
            self.addSubview(container)
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func scrollTo(index: Int, animated: Bool) {
        guard index <= managedViews.count else { return }
        let offset = CGPoint(x: self.w * CGFloat(index), y: 0.0)
        self.setContentOffset(offset, animated: animated)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = max(self.w, targetWidth)
        guard managedViews.count > 0 else {
            self.frame = CGRect(x: self.x, y: self.y, width: w, height: 0.0)
            return
        }

        // Layout left-to-right
        var yPos: CGFloat = 0.0
        var xPos: CGFloat = 0.0
        
        containerViews.forEach {
            $0.frame = CGRect(x: xPos, y: yPos, width: w, height: maxHeight ?? 140.0)
            xPos += w
        }
        yPos += maxHeight ?? 140.0
        
        // Managed views are relative their own container's coordinates, so it will be uniform
        let managedWidth: CGFloat = w - managedViewContainerInset.left - managedViewContainerInset.right
        managedViews.forEach {
            $0.frame = CGRect(x: (w - managedWidth) / 2.0,
                              y: managedViewContainerInset.top,
                              width: managedWidth,
                              height: $0.h)
        }
        
        containerViews.enumerated().forEach { (idx, view) in
            view.contentSize = CGSize(width: w, height: managedViews[idx].h)
        }
        
        self.contentSize = CGSize(width: w * CGFloat(managedViews.count), height: yPos)
        self.frame = CGRect(x: self.x, y: self.y, width: w, height: yPos)
    }
}

// MARK: - UIScrollViewDelegate -

extension PagingView: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / scrollView.w
        pageDelegate?.pagingView(self, didMoveToIndex: Int(index))
    }
}

// MARK: - PagingViewDelegate Protocol -

protocol PagingViewDelegate: class {
    
    func pagingView(_ pagingView: PagingView, didMoveToIndex index: Int)
    
}
