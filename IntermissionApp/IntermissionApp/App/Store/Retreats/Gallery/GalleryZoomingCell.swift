//
//  GalleryZoomingCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Kingfisher

// MARK: - GalleryZoomingCell -

class GalleryZoomingCell: UICollectionViewCell {
    
    weak var delegate: GalleryZoomingCellDelegate?
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 0.999
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 0.999
        return scrollView
    }()
    
    let imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private var interactionPanGesture: UIPanGestureRecognizer? = nil
    private var isZooming: Bool = false
    private var scrollViewPanGesture: UIPanGestureRecognizer {
        return self.scrollView.panGestureRecognizer
    }
    
    var isZoomedIn: Bool { return scrollView.zoomScale > scrollView.minimumZoomScale }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.isUserInteractionEnabled = true
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        interactionPanGesture = gesture
        gesture.delegate = self
        imageView.addGestureRecognizer(gesture)
        
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    // MARK: - Configure
    
    func configure(with url: URL) {
        imageView.setImage(url: url)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func reset() {
        scrollView.zoomScale = scrollView.minimumZoomScale
        imageView.frame.size = CGSize(width: self.w, height: self.w)
        imageView.frame.origin = CGPoint(x: 0.0, y: (self.h - imageView.h) / 2.0)
    }
    
    func resetZoomScale(duration: TimeInterval, completion: (()->Void)? ) {
        guard isZoomedIn else { return }
        
        // Running the completion block this way (instead of in the animation's completion) cuts down on the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + (duration * 0.8)) {
            completion?()
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        }, completion: nil)
    }
    
    // MARK: - Events
    
    @objc
    private func handleDoubleTap() {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            }, completion: { (complete) in
                // The double tap gesture doesn't trigger the delegate zoom calls for scroll view, so update the PDPGalleryZoomCellDelegate here as well
                guard complete, let imageView = self.scrollView.delegate?.viewForZooming?(in: self.scrollView) else { return }
                self.delegate?.galleryZoomingCell(self, didZoomToScale: self.scrollView.zoomScale, withCenter: imageView.center, forView: imageView)
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.scrollView.zoomScale = 1.75
            }, completion: { (complete) in
                // The double tap gesture doesn't trigger the delegate zoom calls for scroll view, so update the PDPGalleryZoomCellDelegate here as well
                guard complete, let imageView = self.scrollView.delegate?.viewForZooming?(in: self.scrollView) else { return }
                self.delegate?.galleryZoomingCell(self, didZoomToScale: self.scrollView.zoomScale, withCenter: imageView.center, forView: imageView)
            })
        }
    }
    
    @objc
    private func handlePan(gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == scrollView.minimumZoomScale, let _ = gesture.view else { return }
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            self.delegate?.galleryZoomingCell(self, didStartPanning: gesture, withOffset: translation)
        case .changed:
            self.delegate?.galleryZoomingCell(self, continuedPanning: gesture, withOffset: translation, velocity: velocity)
        case .ended:
            self.delegate?.galleryZoomingCell(self, didEndPanning: gesture, withOffset: translation, velocity: velocity)
            reset()
        default: break
        }
    }
    
    // MARK: - Layout
    
    fileprivate func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.contentView.bounds
    }
}

// MARK: - UIGestureRecognizerDelegate -

extension GalleryZoomingCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let interactionGesture = self.interactionPanGesture else { return false }
        
        // Detect if we're making more of a vertical pan than horizontal, if so allow the interaction pan to be recognized
        if gestureRecognizer === interactionGesture {
            let xTranslation = max(1.0, abs(interactionGesture.translation(in: self).x))
            let yTranslation = max(1.0, abs(interactionGesture.translation(in: self).y))
            if yTranslation / xTranslation >= 0.7 {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
}

// MARK: - UIScrollViewDelegate -

extension GalleryZoomingCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
        guard let zoomView = view else { return }
        delegate?.galleryZoomingCell(self, didZoomToScale: scale, withCenter: zoomView.center, forView: zoomView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isZooming = false
        
        delegate?.galleryZoomingCell(self,
                                     willEndPanning: scrollView.panGestureRecognizer,
                                     atCurrentOffset: scrollView.panGestureRecognizer.translation(in: self.contentView),
                                     withTargetOffset: targetContentOffset.pointee,
                                     withVelocity: velocity)
        
        if isZoomedIn, let imageView = scrollView.delegate?.viewForZooming?(in: scrollView) {
            delegate?.galleryZoomingCell(self,
                                         didEndPanningWhileZoomed: scrollView.zoomScale,
                                         withCenter: imageView.center,
                                         forView: imageView,
                                         withTargetOffset: targetContentOffset.pointee)
        }
    }
    
}

// MARK: - GalleryZoomingCellDelegate Protocol

protocol GalleryZoomingCellDelegate: class {
    /// Used to signal that a dismissal interactive pan has begun. Offset is how much the pan has moved from its original position since the pan was recognized.
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didStartPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint)
    
    /** Used to track the current position of the image view that is in the middle of an interactive dismissal.
     The offset is used to make any necessay frame position changes as a finger drags around on screen.
     
     - Note: You can safely assume that the image view is not zoomed in if this method is triggered.
     */
    func galleryZoomingCell(_ cell: GalleryZoomingCell, continuedPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint, velocity: CGPoint)
    
    /** Used to signal that the pan gesture tracking an interactive dismissal has ended. The offset is used to make
     any necessary frame position adjustments just prior to a canceled or finished drag dismissal.
     
     - Note: You can safely assume that the image view is not zoomed in if this method is triggered.
     */
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didEndPanning gesture: UIPanGestureRecognizer, withOffset offset: CGPoint, velocity: CGPoint)
    
    /** Used to signal the image view of the cell is about to end being dragged around by the scrollview's pan gesture.
     
     - Note: You can safely assume that the image view is not zoomed in if this method is triggered.
     */
    func galleryZoomingCell(_ cell: GalleryZoomingCell, willEndPanning gesture: UIPanGestureRecognizer, atCurrentOffset currentOffset: CGPoint, withTargetOffset targetOffset: CGPoint, withVelocity velocity: CGPoint)
    
    /// Used to update the the scale and center for a view that's been zoomed in on.
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didZoomToScale scale: CGFloat, withCenter center: CGPoint, forView: UIView)
    
    /// Used to update the center, scale and offset for a view that's been zoomed in on and moved around.
    func galleryZoomingCell(_ cell: GalleryZoomingCell, didEndPanningWhileZoomed zoomScale: CGFloat, withCenter center: CGPoint, forView view: UIView, withTargetOffset offset: CGPoint)
}

