//
//  RDPHeroCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - GalleryTableCell -

class GalleryTableCell: TableViewCell {
    private var imageURLs: [URL] = []
    weak var cellDelegate: GalleryTableCellDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = true

        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .cta
        pageControl.hidesForSinglePage = true

        return pageControl
    }()
    
    private let pillLabel = PillLabel(style: .lavenderFill)
    
    var currentIndex: Int {
        return pageControl.currentPage
    }
    
    // MARK: - Constructors -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    private func setupViews() {
        self.contentView.addSubview(collectionView)
        self.contentView.addSubview(pillLabel)
        self.contentView.addSubview(pageControl)
        
        pageControl.currentPage = 0
        
        self.topSeparator.isHidden = true
        self.bottomSeparator.isHidden = true
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview().priority(999.0)
            make.width.equalToSuperview()
            make.height.equalTo(collectionView.snp.width).priority(999.0)
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(20.0)
            make.bottom.equalToSuperview().offset(-20.0)
        }
        
        pillLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.0)
            make.bottom.equalToSuperview().offset(-20.0)
        }
    }

    // MARK: - Configure -
    
    func configure(with retreat: Retreat) {
        imageURLs = ([retreat.heroImage?.url] + retreat.imageGallery.map { $0.url }).compactMap { $0 }
        pillLabel.text = "$ \(String(retreat.priceString))"
        pillLabel.isHidden = !Flags.shouldDisplayShop
        
        pageControl.numberOfPages = imageURLs.count
        pageControl.setNeedsLayout()
        pageControl.layoutIfNeeded()
        
        collectionView.reloadData()
    }
    
    func configure(with detailSection: DetailSectionWithGallery) {
        pillLabel.isHidden = true
        
        guard let imageGallery = detailSection.imageGallery else { return }
        imageURLs = imageGallery.compactMap({ $0.url })
        
        pageControl.numberOfPages = imageURLs.count
        pageControl.setNeedsLayout()
        pageControl.layoutIfNeeded()
        
        collectionView.reloadData()
    }
    
    // MARK: - Helpers
    
    /// Update the current (paged) index
    func setPage(index: Int) {
        guard collectionView.w > 0.0 else { return } // prevent divide by zero, but also potentially having a huge page # count
        let numberOfPages = Int(collectionView.contentSize.width / collectionView.w)
        guard index <= numberOfPages - 1 else { return }
        
        collectionView.setContentOffset(CGPoint(x: collectionView.w * CGFloat(index), y: 0.0), animated: false)
        pageControl.currentPage = index
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout -

extension GalleryTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as! ImageCollectionCell
        cell.imageView.setImage(url: imageURLs[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellDelegate?.galleryTableCellWasTapped(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.w, height: self.contentView.w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - UIScrollViewDelegate -

extension GalleryTableCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        
        pageControl.currentPage = currentPage
    }
}

// MARK: - ImageCollectionCell -

class ImageCollectionCell: CollectionViewCell {
    
    let imageView: ImageView = {
        let imageView = ImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.center.width.height.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - GalleryTableCellDelegate Protocol - 

protocol GalleryTableCellDelegate: class {

    func galleryTableCellWasTapped(_ galleryTableCell: GalleryTableCell)
    
}

