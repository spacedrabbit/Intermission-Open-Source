//
//  ViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/10/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import Contentful
import SnapKit

class ViewController: UIViewController, ActivityPresentable {
    private let reloadView: ReloadView = ReloadView()
    
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    /** State determines what is seen on a view controller:
     - .ready: Whatever is suppose to already be there
     - .loading: Translucent view with activity indicator is overlayed on content
     - .error: Translucent view with a reload button in the center
     */
    var state: ViewController.State = .ready {
        didSet {
            switch state {
            case .ready:    hideActivity()
            case .loading:  startDelayedLoading()
            case .error:    showReload()
            }
        }
    }
    
    enum State {
        case ready, loading, error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .white
        
        reloadView.reloadButton.addTarget(self, action: #selector(handleReloadPressed), for: .touchUpInside)
    }
    
    open func reload() {
        fatalError("relaod must be implemented in subclasses")
    }
    
    @objc
    private func handleReloadPressed() {
        self.state = .loading
        self.reload()
    }
    
    // MARK: - Delayed Loading Plz
    
    private func startDelayedLoading() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {[weak self] (timer) in
            self?.showActivity()
        })
    }
    
    // MARK: - Custom Modal Transitions
    
    func present(_ viewControllerToPresent: UIViewController, transition: Transition, modalPresentationStyle: UIModalPresentationStyle = .custom, completion: EmptyCompletion? = nil) {
        viewControllerToPresent.iaModalTransition = transition
        viewControllerToPresent.transitioningDelegate = transition
        viewControllerToPresent.modalPresentationStyle = modalPresentationStyle
        self.present(viewControllerToPresent, animated: true, completion: completion)
    }
    
    // MARK: - Activity Presentable -
    
    func showActivity() {
        guard reloadView.superview == nil else {
            reloadView.removeFromSuperview()
            showActivity()
            return
        }
        
        reloadView.isHidden = true
        self.view.addSubview(reloadView)
        self.view.bringSubviewToFront(reloadView) // sanity
        reloadView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        reloadView.isHidden = false
        reloadView.startAnimating()
    }
    
    func hideActivity() {
        self.timer = nil
        // If you see random main.async calls, thank Contentful's API...
        DispatchQueue.main.async {
            guard self.reloadView.superview != nil else { return }
            self.reloadView.removeFromSuperview()
            self.reloadView.stopAnimating()
        }
    }
    
    func showReload() {
        hideActivity()
        reloadView.showReloadButton()
    }
}

// MARK: - Container Controller Helpers -

extension ViewController {
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
}
