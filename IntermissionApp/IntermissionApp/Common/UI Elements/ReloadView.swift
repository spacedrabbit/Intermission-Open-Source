//
//  ReloadView.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

/** A UI-Blocking view controller mostly meant to be used on initial load while the app determines if we have a
    guest or user session.
 
 It should be noted that while the RootViewController places this in its view controller hierarchy,
 the calls to loadingState, readyState, and errorState trigger an app-wide blocking UI on the UIWindow. Removing
 this view from the current hierarchy will not stop the UI blocking activity indicator by virtue of how
 NVActivityIndicatorView implements its NVActivityIndicatorViewable default protocol.
 
 I will leave this in as is, because once I am ready to do a custom app launch animation I will be adding its
 implementation here, as it's functional calls should be correct in the RootVC
 */
class LoadingViewController: UIViewController, NVActivityIndicatorViewable {
    
    func readyState() {
        stopAnimating()
    }
    
    func loadingState() {
        startAnimating(CGSize(width: 60.0, height: 60.0),
                       message: "Meditating...",
                       messageFont: UIFont.body,
                       type: .ballTrianglePath,
                       color: UIColor.battleshipGrey,
                       padding: 20.0,
                       displayTimeThreshold: 0,
                       minimumDisplayTime: 650,
                       backgroundColor: .white,
                       textColor: .battleshipGrey)
    }
    
    func errorState() {
        stopAnimating()
    }
    
    func networkConnectivityErrorState() {
        stopAnimating()
    }
    
}

/** Simple view used to display a centered activity indicator with a partially translucent background
 */
class ReloadView: UIView {
    weak var delegate: ReloadViewDelegate?
    private var activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0),
                                                            type: .ballTrianglePath,
                                                            color: UIColor.battleshipGrey,
                                                            padding: 10.0)
    private let opacityView = UIView()
    
    let reloadButton: Button = {
        let button = Button()
        button.setImage(Icon.Reload.normal.image, for: .normal)
        button.setImage(Icon.Reload.highlighted.image, for: .highlighted)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Initializers -
    init() {
        super.init(frame: .zero)

        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    private func handleReloadPressed() {
        delegate?.reloadButtonWasPressed(reloadButton)
    }
    
    // MARK: - Configure
    
    private func setupViewHierarchy() {
//        self.backgroundColor = UIColor.clear
        opacityView.alpha = 0.0
        opacityView.backgroundColor = UIColor.white
        
        self.addSubview(opacityView)
        self.addSubview(activityIndicator)
        self.addSubview(reloadButton)
    }
    
    private func configureConstraints() {
        opacityView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 60.0, height: 60.0))
        }
        
        reloadButton.snp.makeConstraints { (make) in
            make.centerWithinMargins.equalToSuperview()
            make.width.height.equalTo(60.0)
        }
    }
    
    func startAnimating() {
        guard !activityIndicator.isAnimating else { return }
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.15) {
            self.opacityView.alpha = 0.3
        }
    }

    func stopAnimating() {
        guard activityIndicator.isAnimating else { return }
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.15, animations: {
            self.opacityView.alpha = 0.0
        })
    }

    func showReloadButton() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0.0
            self.reloadButton.isHidden = false
        }
    }
    
    func hideReloadButton() {
        reloadButton.isHidden = true
    }
}

protocol ReloadViewDelegate: class {
    
    func reloadButtonWasPressed(_ reloadButton: Button)
    
}
