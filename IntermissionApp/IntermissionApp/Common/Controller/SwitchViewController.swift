//
//  SwitchViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/26/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class SwitchViewController: ViewController {
    public private(set) var selectedViewController: UIViewController?
    private var viewControllers: [String : UIViewController] = [:]
    private let containerView = UIView()
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(containerView)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        containerView.frame = self.view.bounds
        selectedViewController?.view.frame = containerView.bounds
    }
    
    override func reload() {
        viewControllers.forEach { (key, vc) in
            if let viewController = vc as? ViewController {
                viewController.reload()
            }
        }
    }
    
    // MARK: - View Controller Management -
    
    func add(viewController: UIViewController, as identifier: String) {
        // Return immediately if we're trying to add the same instance of the VC again
        if viewControllers.values.contains(where: { $0 === viewController }) && self.viewController(for: identifier) === viewController { return }
        remove(viewControllerWithId: identifier)
        
        viewControllers[identifier] = viewController
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func remove(viewControllerWithId identifier: String) {
        guard let viewController = self.viewController(for: identifier) else { return }
        
        if selectedViewController === viewController {
            viewController.view.removeFromSuperview()
            selectedViewController = nil
        }
        
        viewController.willMove(toParent: nil)
        viewControllers.removeValue(forKey: identifier)
        viewController.removeFromParent()
    }
    
    func viewController(for identifier: String) -> UIViewController? {
        return viewControllers[identifier]
    }
    
    func switchTo(identifier: String, with transition: Transition? = Transition(), completion: ((Bool) -> ())? = nil) {
        // sanity
        guard let viewController = viewControllers[identifier] else { return }
        switchTo(viewController: viewController, with: transition, completion: completion)
    }
    
    open func switchTo(viewController: UIViewController, with transition: Transition? = Transition(), completion: ((Bool) -> ())? = nil) {
        guard viewControllers.values.contains(viewController), selectedViewController !== viewController else { return }
        
        // position
        viewController.view.frame = containerView.bounds
        
        if let transition = transition, let selectedViewController = selectedViewController {
            // switch controller transitions are always "presenting"
            transition.isPresenting = true
            
            // create the transition context
            let context = TransitionContext(from: selectedViewController, to: viewController, containerView: containerView)
            context.completion = {[weak self] (didComplete: Bool) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.selectedViewController?.view.removeFromSuperview()
                strongSelf.selectedViewController = viewController
                
                (transition as UIViewControllerAnimatedTransitioning).animationEnded?(didComplete)
                
                completion?(didComplete)
            }
            
            // switch with the transition animation
            (transition as UIViewControllerAnimatedTransitioning).animateTransition(using: context)
        } else {
            // switch without a transition animation
            selectedViewController?.view.removeFromSuperview()
            containerView.addSubview(viewController.view)
            selectedViewController = viewController
        }
    }
}
