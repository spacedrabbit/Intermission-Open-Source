//
//  ImageView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Kingfisher

class ImageView: UIImageView {
    private var url: URL?
    
    // MARK: - Setting Image -
    
    /// Standard way to set an image. If placeholder is nil, we use a PlaceholderView by default.
    func setImage(url: URL, placeholder: UIImage? = nil) {
        self.url = url
        let options: KingfisherOptionsInfo = [
            .transition(.fade(0.22)),
        ]
        
        self.kf.setImage(with: url, placeholder: placeholder ?? PlaceholderView(), options: options)
    }
    
    // Taken from https://github.com/onevcat/Kingfisher/wiki/Cheat-Sheet
    /// Use specifically for profile photos
    func setImageAsThumbnail(url: URL, size: CGSize) {
        self.url = url
        let options: KingfisherOptionsInfo = [ .processor(DownsamplingImageProcessor(size: size)),
                                               .scaleFactor(UIScreen.main.scale),
                                               .cacheOriginalImage  ]
        
        self.kf.setImage(with: url, placeholder: nil, options: options, progressBlock: nil) { _ in }
    }
    
    func setImage(url: URL, placeholder: UIImage? = nil, completion: ((IAResult<ImageResponse, ImageDownloadError>) -> Void)? = nil) {
        self.url = url
        
        self.kf.setImage(with: url, placeholder: placeholder, options: [], progressBlock: nil) { (result) in
            switch result {
            case .success(let retrieveImageResult):
                completion?(.success(ImageResponse(imageResult: retrieveImageResult)))
            case .failure(let kingfisherError):
                completion?(.failure(.kingfisher(kingfisherError)))
            }
        }
    }
    
    // MARK: - Helpers -
    
    /// Checks to see if the cache contains the url associated with this image view
    var imageCached: Bool {
        guard let u = url else { return false }
        return ImageCache.default.isCached(forKey: u.absoluteString)
    }
    
}

// MARK: - PlaceholderView -

/// Simple View to use as a placeholder for KF
fileprivate class PlaceholderView: UIView, Placeholder {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .paleLavendar
        self.addSubview(imageView)

        imageView.image = Logo.placeholder.image
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(88.0)
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ImageDownloadError -

enum ImageDownloadError: Error {
    case kingfisher(KingfisherError)
}

// MARK: - HighlightingImageView -

/// Basic ImageView subclass to show a masking view with a set opacity when the imageview is not nil
class HighlightingImageView: ImageView {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted && shouldShowMask {
                self.addSubview(highlightMask)
                self.bringSubviewToFront(highlightMask)
            } else {
                self.highlightMask.removeFromSuperview()
            }
        }
    }
    
    var shouldShowMask: Bool = true
    
    private let highlightMask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cta.withAlphaComponent(0.3)
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.addSubview(highlightMask)
        self.sendSubviewToBack(highlightMask)
        
        self.isUserInteractionEnabled = true
        highlightMask.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        highlightMask.frame = self.bounds
    }
    
}
