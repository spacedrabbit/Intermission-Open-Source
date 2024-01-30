//
//  PagingAnimatedBarView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/30/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/** A view that contains an AnimatedBarView and a PagingView designed to synchronize
    bar item taps and paging contents
 */
class PagingAnimatedBarView: UIView {
    static let standardHeight: CGFloat = 140.0
    private let animatedBarView: AnimatedBarView
    private let pagingView: PagingView
    private var pageItems: [PageBarItem] = []
    private var contentInset: UIEdgeInsets = .zero
    private(set) var selectedIndex: Int = -1
    
    // MARK: - Constructors
    
    init(barAttributes: AnimatedBarViewAttributes) {
        animatedBarView = AnimatedBarView(with: barAttributes)
        pagingView = PagingView(frame: .zero)
        super.init(frame: .zero)
 
        self.addSubview(animatedBarView)
        self.addSubview(pagingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(pageBarItems: [PageBarItem], inset: UIEdgeInsets = .zero, targetWidth: CGFloat, maxVisibleHeight: CGFloat = PagingAnimatedBarView.standardHeight) {
        self.contentInset = inset
        
        animatedBarView.configure(with: pageBarItems.map({ $0.labelText }),
                                  targetWidth: targetWidth - inset.left - inset.right)
        pagingView.configure(with: pageBarItems.map({ $0.page }),
                             inset: inset,
                             maxHeight: maxVisibleHeight,
                             targetWidth: targetWidth - inset.left - inset.right)
        
        animatedBarView.delegate = self
        pagingView.pageDelegate = self
        
        if selectedIndex >= 0 {
            selectBarItem(at: selectedIndex, animated: true)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func selectBarItem(at index: Int, animated: Bool) {
        animatedBarView.setSelected(index, animated: animated, normalizeUnderline: false)
        pagingView.scrollTo(index: index, animated: animated)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var yPos: CGFloat = 0.0
        animatedBarView.frame = CGRect(x: self.contentInset.left, y: 0.0,
                                       width: animatedBarView.w, height: AnimatedBarView.height)
        yPos += animatedBarView.h + 15.0
        
        pagingView.frame = CGRect(x: self.contentInset.left, y: yPos, width: self.w - contentInset.left - contentInset.right, height: pagingView.h)
        yPos += pagingView.h
        
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: yPos)
    }
    
    // MARK: - Helpers
    
    func updateBadging(for tab: String, count: Int) {
        animatedBarView.updateBadging(forLabelWith: tab, count: count)
    }
    
    func currentCount(for tab: String) -> Int? {
        guard let count = animatedBarView.currentBadgeCount(forLabelWith: tab) else { return nil }
        return count
    }
    
}

// MARK: - PagingViewDelegate -

extension PagingAnimatedBarView: PagingViewDelegate {
    
    func pagingView(_ pagingView: PagingView, didMoveToIndex index: Int) {
        animatedBarView.setSelected(index, animated: true)
    }
    
}

// MARK: - AnimatedBarViewDelegate -

extension PagingAnimatedBarView: AnimatedBarViewDelegate {
    
    func animatedBarView(_ animatedBarView: AnimatedBarView, didSelectItemAt index: Int) {
        pagingView.scrollTo(index: index, animated: true)
    }
    
}

// MARK: - PageBarItem -

/// Simple object to manage displaying items in a PagingAnimatedBarView
struct PageBarItem: Equatable {
    let labelText: String
    let page: UIView
    
    static func ==(lhs: PageBarItem, rhs: PageBarItem) -> Bool {
        return lhs.page === rhs.page
    }
}

