//
//  StoreHeaderView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - StoreHeaderView -

/** The "Navigation Bar" at the top of the store page. Really, it's just a view that we're using to mimic a nav view */
class StoreHeaderView: UIView {
    weak var delegate: StoreHeaderViewDelegate?
    private var targetWidth: CGFloat = 0.0
    
    // MARK: Margins
    private struct Margins {
        static let navContainerHeight: CGFloat = 40.0
        static let horizontalEdgeMargins: CGFloat = 20.0
    }
    
    // Will have the appearance of a navigation bar, but is really a view
    private let mockNavBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.navBarGreen
        return view
    }()
    
    private let waveImageView: UIImageView = {
        let imageView = UIImageView(image: Decorative.Wave.greenWave.image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Goes in mockNav
    private let titleLabel: Label = {
        let label = Label()
        label.text = Flags.shouldDisplayShop ? "Store" : "Retreats"
        label.style = Style {
            $0.font = UIFont.init(name: Font.identifier(for: .italic), size: 20.0)
            $0.color = UIColor.white
            $0.kerning = .point(0.2)
        }
        return label
    }()
    
    // Goes in mockNav
    private let cartButton: Button = {
        let button = Button()
        button.setImage(Icon.NavBar.cartLight.image, for: .normal)
        button.setImage(Icon.NavBar.cartDark.image, for: [.highlighted, .selected])
        button.adjustsImageWhenHighlighted = true
        return button
    }()
    
    // MARK: - Constructors
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    
        setupSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.addSubview(mockNavBarView)
        self.addSubview(waveImageView)
        mockNavBarView.addSubview(titleLabel)
        mockNavBarView.addSubview(cartButton)
        
        cartButton.addTarget(self, action: #selector(handleCartTapped(sender:)), for: .touchUpInside)
        cartButton.isHidden = !Flags.shouldDisplayShop
    }
    
    private func configureConstraints() {
        mockNavBarView.snp.makeConstraints { (make) in
            make.width.centerX.top.equalTo(self)
            make.height.equalTo(Margins.navContainerHeight)
        }
        
        waveImageView.snp.makeConstraints { (make) in
            make.top.equalTo(mockNavBarView.snp.bottom)
            make.centerX.width.equalToSuperview()
        }
        
        titleLabel.enforceSizeOnAutoLayout()
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Margins.horizontalEdgeMargins)
            make.top.equalToSuperview()
        }
        
        cartButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.0)
            make.top.equalToSuperview()
        }
    }
    
    // MARK: - Events
    
    @objc
    private func handleCartTapped(sender: Button) {
        self.delegate?.storeHeaderView(self, didTapCart: sender)
    }
    
    // MARK: - Helpers
    
    class var requiredContentHeight: CGFloat {
        return 60.0
    }
    
}

// MARK: - StoreHeaderViewDelegate Protocol -

protocol StoreHeaderViewDelegate: class {
    
    func storeHeaderView(_ storeHeaderView: StoreHeaderView, didTapCart button: Button)
    
}
