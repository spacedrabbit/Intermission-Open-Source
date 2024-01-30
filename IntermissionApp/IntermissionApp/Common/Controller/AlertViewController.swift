//
//  AlertViewController.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 5/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import SnapKit
import SwiftRichString

struct AlertAction {
    let title: String
    let action: (AlertViewController, Button) -> Void
    
    static let okAction = AlertAction(title: "OK", action: { (controller, _) in
        controller.dismiss(animated: true, completion: nil)
    })
}

// MARK: - AlertViewController -

class AlertViewController: UIViewController {
    private var primaryAction: AlertAction
    private var secondaryAction: AlertAction?
    private var allowsTapToDismiss: Bool = true
    
    private let contentView = UIView()
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.style = Styles.styles[Font.alertTitleText]
        return label
    }()
    
    private let messageLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.style = Styles.styles[Font.alertDetailText]
        return label
    }()
    
    private let secondaryButton: InvertedCTAButton = InvertedCTAButton()
    private let primaryButton: CTAButton = CTAButton()
    
    // MARK: - Initializers -
    
    init(with title: String, message: String, primaryAction: AlertAction, secondaryAction: AlertAction? = nil) {
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.clear

        titleLabel.styledText = title
        messageLabel.styledText = message
        
        self.primaryAction = primaryAction
        primaryButton.setText(primaryAction.title)
        primaryButton.addTarget(self, action: #selector(handlePrimaryActionPressed(sender:)), for: .touchUpInside)
        
        self.secondaryAction = secondaryAction
        secondaryButton.setText(secondaryAction?.title ?? "")
        secondaryButton.isHidden = secondaryAction == nil
        secondaryButton.addTarget(self, action: #selector(handleSecondaryActionPressed(sender:)), for: .touchUpInside)

        // Add tap to dismiss if there is no secondary action (assumes "OK" is the default)
        if secondaryAction == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissed))
            tapGesture.delegate = self
            self.view.addGestureRecognizer(tapGesture)
        }
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    func allowTapToDismiss(_ allow: Bool) {
        self.allowsTapToDismiss = allow
    }
    
    // MARK: - Actions -
    
    @objc
    private func handlePrimaryActionPressed(sender: Button) {
        primaryAction.action(self, sender)
    }
    
    @objc
    private func handleSecondaryActionPressed(sender: Button) {
       secondaryAction?.action(self, sender)
    }
    
    @objc
    private func handleDismissed() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Setup -
    
    func setupViews() {
        self.view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(primaryButton)
        contentView.addSubview(secondaryButton)
        contentView.layer.cornerRadius = 6.0
        
        contentView.backgroundColor = UIColor.white
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(30.0)
            make.height.lessThanOrEqualToSuperview().inset(40.0).priority(999.0)
            make.height.greaterThanOrEqualTo(250.0).priority(995.0)
        }
        
        titleLabel.enforceHeightOnAutoLayout()
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(990.0)
        }
        
        messageLabel.safelyEnforceHeightOnAutoLayout()
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(990.0)
        }
        
        primaryButton.snp.makeConstraints { make in
            // This constraint is intentially going to be ignored if it would result in the total height
            // of the view would be less than 250 --> Priority is set to 994 while the height on the alertview
            // requiring a minimum of 250.0 is 995
            make.top.equalTo(messageLabel.snp.bottom).offset(50.0).priority(994.0)
            make.height.equalTo(50.0).priorityRequired()
            make.width.equalToSuperview().inset(20.0)
            make.centerX.equalToSuperview()

            if let _ = secondaryAction {
                make.bottom.equalTo(secondaryButton.snp.top).offset(-10.0)
            } else {
                make.bottom.equalToSuperview().offset(-20.0)
            }
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.height.equalTo(50.0).priorityRequired()
            make.width.equalToSuperview().inset(20.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20.0)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate -

extension AlertViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchLocation = gestureRecognizer.location(in: self.view)
        if contentView.frame.contains(touchLocation) || !allowsTapToDismiss {
            return false
        }
        return true
    }
    
}
