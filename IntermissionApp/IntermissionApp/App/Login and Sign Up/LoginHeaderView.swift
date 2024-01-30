//
//  LoginHeaderView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class LoginHeaderView: UIView {
    
    private let logoImageView: ImageView = {
        let imageView = ImageView(image: Logo.black.image)
        imageView.contentMode = .center
        return imageView
    }()
    
    private let waveBorderImageView: ImageView = {
        let imageView = ImageView(image: Decorative.Wave.lightWaveTop.image)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // Yes, this is a little hacky. But in order to prevent the gradient on the login screen from showing when you pull
    // down on the tableview, I add this to the top of the header to have it go off screen at the top.
    private let topFilledBlockingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let filledContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Constructor
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func configure() {
        self.backgroundColor = .clear
        
        self.addSubview(filledContainerView)
        filledContainerView.addSubview(logoImageView)
        self.addSubview(waveBorderImageView)
        self.addSubview(topFilledBlockingView)
        
        topFilledBlockingView.snp.makeConstraints { (make) in
            make.bottom.equalTo(filledContainerView.snp.top)
            make.height.equalTo(1000.0)
            make.centerX.width.equalToSuperview()
        }
        
        filledContainerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(waveBorderImageView.snp.top)
        }
        
        logoImageView.snp.makeConstraints({ make in
            make.centerWithinMargins.equalToSuperview()
        })
        
        waveBorderImageView.snp.makeConstraints({ make in
            make.centerX.bottom.width.equalToSuperview()
        })
        
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: LoginHeaderView.height)
    }
    
    class var height: CGFloat {
        return 180.0
    }
    
}
