//
//  ProfileImageButton.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/9/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class ProfileImageButton: Button {
    
    private let iaImageView: ImageView = {
        let imageView = ImageView()
        
        imageView.image = ProfileIcon.avatar.image
        imageView.highlightedImage = ProfileIcon.avatar.highlightedImage
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4.0
        imageView.clipsToBounds = true
        imageView.backgroundColor = .paleLavendar

        return imageView
    }()
    
    // Not allowing touch events to go through... not sure why
    private let backingShadowView: UIView = {
        let view = UIView()
        
        view.isUserInteractionEnabled = true
        view.layer.shadowColor = UIColor.red.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 10.0
        view.backgroundColor = .paleLavendar
        
        return view
    }()
    
    private let decoratorView: ImageView = {
        let imageView = ImageView()
        
        imageView.image = ProfileIcon.add.image
        imageView.highlightedImage = ProfileIcon.add.highlightedImage
        
        return imageView
    }()
    
    override var isHighlighted: Bool {
        didSet {
            iaImageView.isHighlighted = isHighlighted
            decoratorView.isHighlighted = isHighlighted
        }
    }
    
//    var showShadow: Bool = false {
//        didSet {
//            backingShadowView.isHidden = !showShadow
//        }
//    }
    
    // MARK: - Constructors -
    
    override init() {
        super.init()
        self.clipsToBounds = false
        
//        self.addSubview(backingShadowView)
        self.addSubview(iaImageView)
        self.addSubview(decoratorView)

        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func setImage(url: URL?) {
        if let url = url {
            iaImageView.setImage(url: url, placeholder: ProfileIcon.avatar.image)
            iaImageView.highlightedImage = nil
        } else {
            iaImageView.image = ProfileIcon.avatar.image
            iaImageView.highlightedImage = ProfileIcon.avatar.highlightedImage
        }
        
        adjustDecorator()
    }
    
    func adjustForOnboarding(image: UIImage?) {
        adjustForGuest(image: image)
    }
    
    func adjustForGuest(image: UIImage?) {
        decoratorView.isHidden = true
        iaImageView.image = image
        self.isEnabled = false
    }
    
    private func adjustDecorator() {
        decoratorView.isHidden = false
        if iaImageView.image != nil {
            guard decoratorView.image != ProfileIcon.edit.image else { return }
            decoratorView.image = ProfileIcon.edit.image
            decoratorView.highlightedImage = ProfileIcon.edit.highlightedImage
        } else {
            guard decoratorView.image != ProfileIcon.add.image else { return }
            decoratorView.image = ProfileIcon.add.image
            decoratorView.highlightedImage = ProfileIcon.add.highlightedImage
        }
        
        self.setNeedsLayout()
    }
    
    // MARK: - Layout -
    
    private func configureConstraints() {
        
        iaImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(4.0) // push out the width a little for extra touch area
            make.height.equalTo(iaImageView.snp.width)
        }
        
//        backingShadowView.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//            make.width.equalToSuperview().inset(4.0) // push out the width a little for extra touch area
//            make.height.equalTo(backingShadowView.snp.width)
//        }
        
        decoratorView.snp.makeConstraints { (make) in
            make.width.height.equalTo(24.0)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iaImageView.layer.cornerRadius = iaImageView.w / 2.0
        
        // Place the center of the decorator on edge of the iaImageView
        let radius = iaImageView.w / 2.0
        let xCoord = radius * cos(degToRad(45.0))
        let yCoord = radius * sin(degToRad(45.0))
        let adjustedCoords = CGPoint(x: iaImageView.center.x + xCoord,
                                     y: iaImageView.center.y + yCoord)
        decoratorView.center = adjustedCoords
//
//        backingShadowView.layer.shadowColor = UIColor.red.cgColor
//        backingShadowView.layer.shadowOffset = .zero
//        backingShadowView.layer.shadowOpacity = 1.0
//        backingShadowView.layer.shadowRadius = 10.0
//
//        backingShadowView.layer.cornerRadius = backingShadowView.w / 2.0
    }
    
}

// TODO: move elsewhere
public func degToRad(_ val: CGFloat) -> CGFloat {
    return (val * CGFloat.pi) / 180.0
}

public func radToDeg(_ val: CGFloat) -> CGFloat {
    return val * (180.0 / CGFloat.pi)
}
