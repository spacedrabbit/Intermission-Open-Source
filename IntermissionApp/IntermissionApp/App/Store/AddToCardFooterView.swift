//
//  AddToCardFooterView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class AddToCardFooterView: UIView {
    
    let addToCartButton: CTAButton = {
        let button = CTAButton()
        button.setText("ADD TO CART")
        return button
    }()
    
    // MARK: - Initializers -
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.addSubview(addToCartButton)
        addToCartButton.snp.makeConstraints { make in
            make.height.equalTo(50.0)
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
