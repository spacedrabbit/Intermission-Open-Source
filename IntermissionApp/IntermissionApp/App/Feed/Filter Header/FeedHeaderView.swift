//
//  FeedHeaderView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/23/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

/** The "Navigation Bar" at the top of the feed page. Really, it's just a view that we're using to mimic a nav view
    The FeedHeaderView contains an view used to filter videos based on tag.
 
    The show/hide of the filter fires a notification (similar to keyboard show/hide) in order to alert relevant views
    that they should adjust.
 */
class FeedHeaderView: UIView {
    weak var delegate: FeedHeaderViewDelegate?
    private var filterMenuActive: Bool = false
    
    private var selectedTags: [Tag] = [] {
        didSet {
            if selectedTags.count > 0 {
                filterButton.showBadge(0, animated: true)
                filterButton.isSelected = true
                clearFiltersButton.isHidden = false
                delegate?.feedHeaderView(self, didUpdateFilters: selectedTags)
            } else {
                filterButton.isSelected = false
                filterButton.hideBadge(animated: true)
                clearFiltersButton.isHidden = true
                delegate?.feedHeaderViewDidClearFilters(self)
            }
        }
    }
    
    private var selectedTagButtons: [TagPillButton] = []
    private var categoryMap: [Category : [Tag]] = [:]
    private var state: State = .hidden
    
    private var targetWidth: CGFloat = 0.0
    private var lastSelectedIndex: Int = -1
    
    private let presentationAnimationDuration: TimeInterval = 0.30
    private let dismissalAnimationDuration: TimeInterval = 0.20
    private let animationOptions: UIView.AnimationOptions = [.curveEaseInOut, .beginFromCurrentState]
    
    // Will have the appearance of a navigation bar, but is really a view
    private let mockNavBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.navBarGreen
        return view
    }()
    
    // Goes in mockNav
    private let titleLabel: Label = {
        let label = Label()
        label.text = "Feed"
        label.style = Style {
            $0.font = UIFont.init(name: Font.identifier(for: .italic), size: 20.0)
            $0.color = UIColor.white
            $0.kerning = .point(0.2)
        }
        return label
    }()
    
    // Goes in mockNav
    private let filterButton: TogglingButton = {
        let button = TogglingButton()
        button.setImage(Icon.NavBar.filter.image, for: .normal)
        button.setImage(Icon.NavBar.filterActive.image, for: .highlighted)
        button.setImage(Icon.NavBar.filterActive.image, for: .selected)
//        button.adjustsImageWhenHighlighted = true
        return button
    }()

    // Collapsable view to show/hide category bar and filter tag options
    private let filterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.navBarGreen
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var pagingBarView: PagingAnimatedBarView?
    
    private let waveImageView: UIImageView = {
        let imageView = UIImageView(image: Decorative.Wave.greenWave.image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var clearFiltersButton: RoundedCTAButton = RoundedCTAButton()
    
    // Simple enum tracking (essentially) a bool state. Just gives some better context this way.
    private enum State {
        case visible, hidden
        
        mutating func toggle() {
            switch self {
            case .visible: self = .hidden
            case .hidden: self = .visible
            }
        }
    }
    
    // MARK: Margins
    private struct Margins {
        static let navContainerHeight: CGFloat = 40.0
        static let horizontalEdgeMargins: CGFloat = 20.0
        static let verticalFilterMargin: CGFloat = 10.0
    }
    
    // MARK: - Constructors
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        filterButton.addTarget(self, action: #selector(handleFilterTapped), for: .touchUpInside)
        clearFiltersButton.isHidden = true
        clearFiltersButton.setText("CLEAR FILTERS")
        clearFiltersButton.addTarget(self, action: #selector(handleClearFiltersTapped), for: .touchUpInside)
        
        mockNavBarView.addSubview(clearFiltersButton)
        mockNavBarView.addSubview(titleLabel)
        mockNavBarView.addSubview(filterButton)

        self.addSubview(mockNavBarView)
        self.addSubview(filterView)
        self.addSubview(waveImageView)
        
        clearFiltersButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(filterButton.snp.leading).inset(-10.0)
            make.top.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with dict: [Category : [Tag]], targetWidth: CGFloat) {
        // Don't reconfigure this if it's the same info
        guard self.categoryMap != dict else { return }
        let selectedIndex = pagingBarView?.selectedIndex ?? 1
        self.targetWidth = targetWidth
        self.categoryMap = dict
        
        // Clear previously used items
        pagingBarView?.removeFromSuperview()
        pagingBarView = nil
        filterView.subviews.forEach { $0.removeFromSuperview() }
        
        // Use the "order" property on Category to have the display order of the keys
        // We need to do this for design purposes as well, it looks the most balanced by having
        // "Movement" & "Mindfulness" on the left and right sides with "Music" in the middle
        let orderedKeys = dict.keys.sorted(by: { $0.order > $1.order })
        let pageBarItems = orderedKeys.compactMap { (category: Category) -> PageBarItem? in
            
            // Create the helper objects for arranging the tabbed items
            guard let tags = dict[category] else { return nil }
            let pills = tags.compactMap({ (tag: Tag) -> TagPillButton in
                let pill = TagPillButton()
                pill.configure(with: tag)
                if selectedTags.contains(tag) { pill.isSelected = true }
                
                pill.sizeToFit()
                
                return pill
            })
            
            // I dont love that the we're setting the delegate to these as the FeedHeader
            // There's less safety doing it this way but it has to be done for now
            let pillLayoutView = PillButtonLayoutView()
            pillLayoutView.configure(with: pills)
            pillLayoutView.delegate = self
            
            return PageBarItem(labelText: category.title, page: pillLayoutView)
        }
        
        let pagingAnimatedBarView = PagingAnimatedBarView(barAttributes: .darkBackground)
        pagingBarView = pagingAnimatedBarView
        pagingBarView?.configure(pageBarItems: pageBarItems,
                                 inset: .zero,
                                 targetWidth: self.targetWidth - Margins.horizontalEdgeMargins - Margins.horizontalEdgeMargins)
        filterView.addSubview(pagingAnimatedBarView)
        pagingBarView?.selectBarItem(at: max(selectedIndex, 1), animated: false)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc
    private func handleFilterTapped() {
        filterMenuActive.toggle()
        filterButton.setSelected(filterMenuActive)
        self.state.toggle()

        self.delegate?.feedHeaderView(self, filterWasSelected: filterMenuActive)
        
        if filterMenuActive {
            NotificationCenter.default.post(name: .feedHeaderWillShowFilter, object: nil, userInfo: [
                FeedHeaderFilterKey.animationPresentationDuration : self.presentationAnimationDuration,
                FeedHeaderFilterKey.animationDismissalDuration : self.dismissalAnimationDuration,
                FeedHeaderFilterKey.animationOptions : self.animationOptions
                ])
        } else {
            NotificationCenter.default.post(name: .feedHeaderWillHideFilter, object: nil, userInfo: [
                FeedHeaderFilterKey.animationPresentationDuration : self.presentationAnimationDuration,
                FeedHeaderFilterKey.animationDismissalDuration : self.dismissalAnimationDuration,
                FeedHeaderFilterKey.animationOptions : self.animationOptions
                ])
        }
        let animationDuration = filterMenuActive
            ? presentationAnimationDuration
            : dismissalAnimationDuration
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            // Hack to properly draw the underline...
            if self.lastSelectedIndex == -1 {
                self.pagingBarView?.selectBarItem(at: 1, animated: false)
                self.lastSelectedIndex = 1
            }
        }, completion: nil)
    }
    
    @objc
    private func handleClearFiltersTapped() {
        selectedTags = []
        selectedTagButtons.forEach { (button) in
            button.isSelected = false
        }
        selectedTagButtons = []
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var yPos: CGFloat = 0.0
        let maxContentWidth: CGFloat = self.w - (Margins.horizontalEdgeMargins * 2.0)
        
        mockNavBarView.frame = CGRect(x: 0.0, y: 0.0, width: self.w, height: Margins.navContainerHeight)
        yPos += mockNavBarView.h
        
        // Container elements pin to top of container
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: Margins.horizontalEdgeMargins, y: 0.0, width: titleLabel.w, height: titleLabel.h)
        filterButton.sizeToFit()
        filterButton.frame = CGRect(x: mockNavBarView.w - filterButton.w - Margins.horizontalEdgeMargins, y: 0.0,
                                    width: filterButton.w, height: filterButton.h)
        
        pagingBarView?.frame = CGRect(x: Margins.horizontalEdgeMargins, y: 0.0, width: maxContentWidth, height: pagingBarView?.h ?? 0.0)
        
        if state == .visible {
            filterView.frame = CGRect(x: 0.0, y: yPos, width: self.w, height: pagingBarView?.h ?? 0.0)
            yPos += filterView.h
        } else {
            filterView.frame = CGRect(x: 0.0, y: yPos, width: self.w, height: 0.0)
        }
        
        waveImageView.frame = CGRect(x: 0.0, y: yPos, width: self.w, height: waveImageView.h)
        yPos += waveImageView.h + Margins.verticalFilterMargin
        
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: yPos)
    }
    
    // MARK: - Helpers
    
    func requiredContentHeight() -> CGFloat {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        return self.h
    }
}

// MARK: - PillButtonLayoutViewDelegate -

extension FeedHeaderView: PillButtonLayoutViewDelegate {
    
    func pillButtonLayoutView(_ pillButtonLayoutView: PillButtonLayoutView, didPressPillButton button: TagPillButton, forTag tag: Tag, at index: Int, tagSelected tagIsSelected: Bool) {
        guard let category = categoryMap.filter({ $0.value.contains(tag) }).keys.first else { return }
        
        // TODO: fix badging, re-implement
        var count = 0
        if let currentCount = pagingBarView?.currentCount(for: category.title) {
            count = currentCount
        }
        
        if tagIsSelected {
            // I want to preserve order so instead of using a Set for uniqueness, I do a few sanity checks to make
            // sure that we don't get duplicate items
            //
            // So if we select a tag, and it's already in the array, remove it and add it to the end.
            if let idx = selectedTags.index(of: tag) {
                let existingTag = selectedTags.remove(at: idx)
                selectedTags.append(existingTag)
            } else {
            // Otherwise, just append it
                selectedTags.append(tag)
                selectedTagButtons.append(button)
            }
            
//            pagingBarView?.updateBadging(for: category.title, count: count + 1)
        } else if let idx = selectedTags.index(of: tag) {
            selectedTags.remove(at: idx)
            if let buttonIndex = selectedTagButtons.index(of: button) {
                selectedTagButtons.remove(at: buttonIndex)
            }
//            pagingBarView?.updateBadging(for: category.title, count: max(0, count - 1))
        }
    }
}

// MARK: - FeedHeaderView Delegate Protocol -

protocol FeedHeaderViewDelegate: class {
    
    func feedHeaderView(_ feedHeaderView: FeedHeaderView, filterWasSelected filterActive: Bool)
    
    func feedHeaderView(_ feedHeaderView: FeedHeaderView, didUpdateFilters filteredTags: [Tag])
    
    func feedHeaderViewDidClearFilters(_ feedHeaderView: FeedHeaderView)
    
}

// MARK: - FeedHeaderFilterKey -

struct FeedHeaderFilterKey {
    
    static let animationPresentationDuration = "com.ia.feedHeader.animationPresentationDuration"
    
    static let animationDismissalDuration = "com.ia.feedHeader.animationDismissalDuration"
    
    static let animationOptions = "com.ia.feedHeader.animationOptions"
    
}

// MARK: - Filter Notification Keys -

extension Notification.Name {
    
    static let feedHeaderWillShowFilter = Notification.Name(rawValue: "com.ia.feedHeader.filterWillShow")
    
    static let feedHeaderWillHideFilter = Notification.Name(rawValue: "com.ia.feedHeader.filterWillHide")
    
}
