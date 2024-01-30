//
//  ScrollViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/31/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class ScrollViewController: ViewController {
    
    public var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    /// Use this value to adjust for addition UI elements
    public var adjustedInsets: UIEdgeInsets = .zero {
        didSet {
            if adjustedInsets == oldValue { return }
            additionalSafeAreaInsets = adjustedInsets
            
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
        }
    }
    
    private var bottomConstraint: Constraint?
    private var keyboardIsShowing: Bool = false
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        registerNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterNotifications()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.keyboardDismissMode = .interactive
        if scrollView.superview == nil {
            self.view.addSubview(scrollView)
            configureConstraits()
        } else {
            configureConstraits()
        }
    }
    
    // MARK: - Layout
    
    private func configureConstraits() {
        scrollView.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }

    // MARK: - Notifications
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Adjustments
    
    @objc
    private func handleKeyboardWillShow(notification: Notification) {
        shouldShowKeyboard(true, notification: notification)
    }
    
    @objc
    private func handleKeyboardWillHide(notification: Notification) {
        shouldShowKeyboard(false, notification: notification)
    }
    
    private func shouldShowKeyboard(_ show: Bool, notification: Notification, completion: ((Bool)->Void)? = nil) {
        guard
            let userInfo = notification.userInfo,
            let keyboardHeight = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let animationCurveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveNumber)
        keyboardIsShowing = show
        bottomConstraint?.update(offset: (show ? -1 : 1) * (self.view.h - keyboardHeight.y))
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}
