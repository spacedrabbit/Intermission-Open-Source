//
//  SettingsFooterView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - SettingsFooterView -

/// Displays the current app version and a logout button at the bottom of the SettingsVC
class SettingsFooterView: UIView {
    
    private let separatorLine: UIView = UIView()
    private let appVersionLabel = Label()
    let logoutButton = CTAButton()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        separatorLine.backgroundColor = .secondaryBackground
        
        self.addSubview(separatorLine)
        self.addSubview(appVersionLabel)
        self.addSubview(logoutButton)
        
        logoutButton.setText("SIGN OUT")
        appVersionLabel.attributedText = AppManager.appVersionDisplayString
        
        appVersionLabel.enforceHeightOnAutoLayout()
        appVersionLabel.safelyEnforceWidthOnAutoLayout()
        
        separatorLine.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1.0)
        }
        
        logoutButton.snp.makeConstraints { (make) in
            make.top.equalTo(appVersionLabel.snp.bottom).offset(10.0)
            make.size.equalTo(CTAButton.defaultSize)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20.0)
        }
        
        appVersionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10.0)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
