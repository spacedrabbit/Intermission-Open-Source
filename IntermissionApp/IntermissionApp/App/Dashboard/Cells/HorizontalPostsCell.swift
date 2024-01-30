//
//  CollectionModuleTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString
import SnapKit

/// Simple class to display a row of horizontally scrolling cells representing either a Post or a VideoHistoryEntry
class HorizontalPostsCell: TableViewCell {
    private var posts: [Post] = []
    weak var delegate: HorizontalPostsCellDelegate?
    
    private let horizontalInset: CGFloat = 20.0
    private let minimumLineSpacing: CGFloat = 20.0
    private let numCardsToDisplayPerRow: CGFloat = 1.25 // show 1 full + .25 of 1 more to indicate scrolling
    private var cellWidth: CGFloat {
        return (self.w - (horizontalInset + (numCardsToDisplayPerRow.rounded(.down) * minimumLineSpacing))) / numCardsToDisplayPerRow
    }
    
    private var collectionViewHeightConstraint: Constraint?
    
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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        self.selectionStyle = .none
        chevronButton.addTarget(self, action: #selector(handleChevronTapped(sender:)), for: .touchUpInside)
        
        // Collection Set up
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        // Cell Registering
        collectionView.register(PostPreviewCell.self, forCellWithReuseIdentifier: PostPreviewCell.reuseIdentifier)
        
        // View Setup
        self.contentView.addSubview(headingLabel)
        self.contentView.addSubview(chevronButton)
        self.contentView.addSubview(collectionView)
        
        // Constraints
        headingLabel.enforceHeightOnAutoLayout()
        headingLabel.setContentCompressionResistancePriority(.init(990.0), for: .horizontal)
        headingLabel.setContentHuggingPriority(.init(991.0), for: .horizontal)
        
        headingLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.top.equalToSuperview().offset(40.0)
        }

        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headingLabel.snp.bottom).offset(10.0)
            make.trailing.leading.width.equalToSuperview()
            make.height.equalTo(PostPreviewCell.height(for: cellWidth) + 4.0).priority(999.0)
            make.bottom.equalToSuperview().priority(999.0)
        }
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Chevron button requires frames to layout correctly
        chevronButton.sizeToFit()
        let chevronYPos: CGFloat = {
            if (headingLabel.text?.isEmpty == true) || (headingLabel.text == nil) {
                return 20.0
            } else {
                return headingLabel.y + ((headingLabel.h - chevronButton.h) / 2.0)
            }
        }()
        chevronButton.frame = CGRect(x: self.contentView.w - chevronButton.w - 20.0,
                                     y: chevronYPos,
                                     width: chevronButton.w, height: chevronButton.h)
    }
    
    // At initialization, a tableview cell is given an arbitrary "encapsulated" width of 320.0 pts. So we need to make sure to
    // update our collection view height as it depends on the current cell width.
    override func updateConstraints() {
        collectionView.snp.updateConstraints { (make) in
            make.top.equalTo(self.headingLabel.snp.bottom).offset(10.0)
            make.trailing.leading.width.equalToSuperview()
            make.height.equalTo(PostPreviewCell.height(for: cellWidth) + 4.0).priority(999.0)
            make.bottom.equalToSuperview().priority(999.0)
        }
        
        super.updateConstraints() // this gets called last
    }
    
    
    // MARK: - Configure -
    
    func configure(with posts: [Post], relatedTag tag: Tag?, style: DashboardCTAStyle = .none) {
        self.headingLabel.styledText = style.headingText
        self.posts = posts
        
        let normalStyle = Styles.styles[Font.chevronButtonNormal] ?? Style()
        let highlightStyle = Styles.styles[Font.chevronButtonHighlighted] ?? Style()
        self.chevronButton.isHidden = false
        
        if let tag = tag {
            self.chevronButton.setAttributedTitle("See more for \(tag.title)".uppercased().set(style: normalStyle), for: .normal)
            self.chevronButton.setAttributedTitle("See more for \(tag.title)".uppercased().set(style: highlightStyle), for: .highlighted)
        } else if style != .none {
            self.chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: normalStyle), for: .normal)
            self.chevronButton.setAttributedTitle(style.ctaText.uppercased().set(style: highlightStyle), for: .highlighted)
        } else {
            self.chevronButton.isHidden = true
        }

        headingLabel.setNeedsLayout()
        headingLabel.layoutIfNeeded()
        
        chevronButton.setNeedsLayout()
        chevronButton.layoutIfNeeded()
        
        self.collectionView.reloadData()
    }
    
    func configure(with feedModule: FeedModule) {
        let attributedString = feedModule.moduleTitle.set(style: Font.feedModuleTitle)
        if feedModule.emphasizedWords.count > 0 {
            let emphasizedRanges = feedModule.emphasizedWords.compactMap { (word) -> NSRange? in
                let range = (feedModule.moduleTitle as NSString).range(of: word, options: .caseInsensitive)
                if range.location != NSNotFound {
                    return range
                }
                return nil
            }

            if emphasizedRanges.count > 0 {
                emphasizedRanges.forEach {
                    attributedString?.add(style: Font.feedModuleTitleBold, range: $0)
                }
            }
        }
        
        self.headingLabel.attributedText = attributedString
        self.chevronButton.isHidden = true
        
        if case let .posts(posts) = feedModule.type {
            self.posts = posts
        }
        
        headingLabel.setNeedsLayout()
        headingLabel.layoutIfNeeded()
        
        self.collectionView.reloadData()
    }
    
    // MARK: - Actions -
    
    @objc
    private func handleChevronTapped(sender: Button) {
        guard let chevron = sender as? ChevronButton else { return }
        delegate?.horizontalPostsCell(self, didPressChevron: chevron)
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout -

extension HorizontalPostsCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostPreviewCell.reuseIdentifier, for: indexPath) as! PostPreviewCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: PostPreviewCell.height(for: cellWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.horizontalPostsCell(self, didSelectItem: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: horizontalInset, bottom: 0.0, right: horizontalInset)
    }
}

// MARK: - HorizontalPostsCellDelegate Protocol -

protocol HorizontalPostsCellDelegate: class {
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didSelectItem index: Int)
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didPressChevron button: ChevronButton)
    
}
