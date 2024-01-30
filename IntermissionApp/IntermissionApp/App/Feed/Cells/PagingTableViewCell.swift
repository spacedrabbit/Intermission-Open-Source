//
//  PagingTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - PagingTableViewCell -

/** Paging tableview cell used to display a video post. Used in the top position on the feed to show featured content
 */
class PagingTableViewCell: TableViewCell {
    private var posts: [Post] = []
    weak var delegate: PagingVideoTableCellDelegate?

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .cta
        
        return pageControl
    }()
    
    // MARK: - Initializers -

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentInsets = .zero
        self.contentView.addSubview(collectionView)
        self.contentView.addSubview(pageControl)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoCollectionCell.self, forCellWithReuseIdentifier: VideoCollectionCell.reuseIdentifier)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with posts: [Post]) {
        self.posts = posts
        pageControl.numberOfPages = posts.count

//        self.setNeedsLayout()
//        self.layoutIfNeeded()
        
        collectionView.reloadData()
    }
    
    func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20.0).priority(998.0)
            make.leading.trailing.width.equalToSuperview()
            make.height.equalTo(VideoCollectionCell.height(for: self.w) + 2.0).priority(995.0) // +2.0 to make up for rounding errors
            make.bottom.equalToSuperview().offset(-20.0).priority(998.0)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20.0)
            make.height.equalTo(20.0)
        }
    }
    
    // At initialization, a tableview cell is given an arbitrary "encapsulated" width of 320.0 pts. So we need to make sure to
    // update our collection view height as it depends on the current cell width.
    override func updateConstraints() {
        collectionView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(20.0).priority(998.0)
            make.leading.trailing.width.equalToSuperview()
            make.height.equalTo(VideoCollectionCell.height(for: self.w) + 2.0).priority(995.0)  // +2.0 to make up for rounding errors
            make.bottom.equalToSuperview().offset(-20.0).priority(998.0)
        }
        
        super.updateConstraints()
    }
 
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate -

extension PagingTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionCell.reuseIdentifier, for: indexPath) as! VideoCollectionCell
        
        if posts.count >= indexPath.row + 1, let video = posts[indexPath.row].video {
            let post = posts[indexPath.row]
            cell.configure(with: post.title, subtitle: video.duration.minuteString(), url: video.thumbnailURL, isNewPost: post.isNew)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.w, height:VideoCollectionCell.height(for: self.w))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pagingVideoTableCell(self, didSelectItem: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

}

// MARK: - PagingVideoTableCellDelegate Protocol -

protocol PagingVideoTableCellDelegate: class {
    
    func pagingVideoTableCell(_ pagingVideoTableCell: PagingTableViewCell, didSelectItem index: Int)
    
}
