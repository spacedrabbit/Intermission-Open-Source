//
//  GalleryViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Kingfisher

class GalleryViewController: CollectionViewController {
    private var largeImageURLs: [URL] = []
    private let startingIndex: Int
    private var imagePrefetcher: ImagePrefetcher?
    
    // The transition object used to present this view controller
    private var transition: Transition? {
        return self.navigationController?.iaModalTransition
    }
    
    // Returns the current image index
    private var currentIndex: Int {
        get {
            guard
                collectionView.indexPathsForVisibleItems.count == 1,
                let index = collectionView.indexPathsForVisibleItems.first,
                index.row <= largeImageURLs.count - 1
                else { return startingIndex }
            return index.row
        }
    }
    
    private let closeButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.xCloseFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.xCloseFilledCTA.image, for: .highlighted)
        return button
    }()
    
    private struct ReuseIdentifier {
        static let galleryZoomingCell = "galleryZoomingCell"
    }
    
    weak var galleryDelegate: GalleryViewControllerDelegate?
    
    // MARK: - Constructors
    
    init(urls: [URL], selectedIndex: Int = 0) {
        self.startingIndex = selectedIndex
        self.largeImageURLs = urls // check on the image api availability for this
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.isNavigationBarHidden = true
        prefetch(at: selectedIndex)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = .black
        
        self.navigationItem.leftNavigationButtons = [closeButton]
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        
        self.collectionView.prefetchDataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.contentOffset = CGPoint(x: self.collectionView.frame.size.width * CGFloat(startingIndex), y: 0.0)
        self.collectionView.contentSize = CGSize(width: self.collectionView.frame.size.width * CGFloat(largeImageURLs.count), height: self.collectionView.contentSize.height)
        
        self.collectionView.register(GalleryZoomingCell.self, forCellWithReuseIdentifier: ReuseIdentifier.galleryZoomingCell)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard collectionView.numberOfItems(inSection: 0) >= startingIndex + 1 else { return }
        collectionView.scrollToItem(at: IndexPath(row: startingIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Events
    
    @objc
    private func handleCloseTapped() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    
    /// Attempts to prefetch a single image at a specified index. Should only be used on load
    private func prefetch(at index: Int) {
        guard largeImageURLs.count >= index + 1 else { return }
        ImagePrefetcher(urls: [largeImageURLs[index]], options: [.downloadPriority(1.0)]).start()
    }
}

// MARK: - UICollectionViewDataSourcePrefetching -

extension GalleryViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { largeImageURLs[$0.row] }
        self.imagePrefetcher = ImagePrefetcher(urls: urls, options: [.downloadPriority(1.0)])
        self.imagePrefetcher?.start()
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        self.imagePrefetcher?.stop()
    }
    
}

// MARK: - UICollectionViewDelegate & DataSource Methods

extension GalleryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return largeImageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.galleryZoomingCell, for: indexPath) as! GalleryZoomingCell
        cell.configure(with: largeImageURLs[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? GalleryZoomingCell else { return }
        cell.reset() // resets the cell after it scrolls off screen
        
        self.galleryDelegate?.galleryViewController(self, didUpdateIndex: currentIndex)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - GalleryZoomingCellDelegate -

extension GalleryViewController: GalleryZoomingCellDelegate {
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didStartPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint) {
    }
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, continuedPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint, velocity: CGPoint) {
    }
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didEndPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint, velocity: CGPoint) {
    }
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, willEndPanning gesture: UIPanGestureRecognizer, atCurrentOffset currentOffset: CGPoint, withTargetOffset targetOffset: CGPoint, withVelocity velocity: CGPoint) {
    }
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didZoomToScale scale: CGFloat, withCenter center: CGPoint, forView: UIView) {
    }
    
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didEndPanningWhileZoomed zoomScale: CGFloat, withCenter center: CGPoint, forView view: UIView, withTargetOffset offset: CGPoint) {
    }
}

// MARK: - GalleryViewController Protocol -

protocol GalleryViewControllerDelegate: class {
    
    func galleryViewController(_ galleryViewController: GalleryViewController, didUpdateIndex index: Int)
    
}
