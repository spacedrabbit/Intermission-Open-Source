//
//  Transition.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/26/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class Transition: NSObject {
    
    public var isPresenting = true
    
    public func beginIgnoringInteractionEvents() {
        #if !APP_EXTENSION
        UIApplication.shared.beginIgnoringInteractionEvents()
        #endif
    }
    
    public func endIgnoringInteractionEvents() {
        #if !APP_EXTENSION
        UIApplication.shared.endIgnoringInteractionEvents()
        #endif
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate -

extension Transition: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning -

extension Transition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    // Default transition will be a simple cross fade
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController = transitionContext.viewController(forKey: .from),
            let toController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) ?? fromController.view,
            let toView = transitionContext.view(forKey: .to) ?? toController.view
        else { return }
        
        let container = transitionContext.containerView
        
        if isPresenting {
            fromView.alpha = 1.0
            toView.alpha = 0.0
            container.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseOut], animations: {
                toView.alpha = 1.0
            }) { didFinish in
                
                transitionContext.completeTransition(didFinish)
            }
        } else {
            toView.alpha = 1.0
            fromView.alpha = 1.0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseOut], animations: {
                fromView.alpha = 0.0
            }) { didFinish in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(didFinish)
            }
        }
    }
    
}

open class TransitionContext: NSObject {
    private let fromViewController: UIViewController
    private let toViewController: UIViewController
    private let viewControllers: [UITransitionContextViewControllerKey: UIViewController]
    private var views: [UITransitionContextViewKey: UIView]?
    public let containerView: UIView // part of UIViewControllerContextTransitioning
    
    public var completion: ((_ didComplete: Bool) -> ())?
    
    public init(from fromVC: UIViewController, to toVC: UIViewController, containerView: UIView) {
        self.fromViewController = fromVC
        self.toViewController = toVC
        self.viewControllers = [.from: fromVC, .to: toVC]
        self.containerView = containerView
        
        super.init()
        
        if let fromView = fromVC.view, let toView = toVC.view {
            self.views = [.from: fromView, .to: toView]
        }
    }
    
}

extension TransitionContext: UIViewControllerContextTransitioning {
    
    // MARK: - Properties
    
    @objc(isAnimated)
    public var isAnimated: Bool {
        return true
    }
    
    @objc(isInteractive)
    public var isInteractive: Bool {
        return false
    }
    
    public var transitionWasCancelled: Bool {
        return false
    }
    
    public var presentationStyle: UIModalPresentationStyle {
        return .custom
    }
    
    public var targetTransform: CGAffineTransform {
        return .identity
    }
    
    // MARK: - Used Methods
    
    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }
    
    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return views?[key]
    }
    
    public func completeTransition(_ didComplete: Bool) {
        if let completion = completion {
            completion(didComplete)
        }
    }
    
    // MARK: - Frame Methods
    
    public func initialFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
    
    public func finalFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
    
    // MARK: - Interactive Methods (NOT USED)
    
    public func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    
    public func finishInteractiveTransition() {}
    
    public func cancelInteractiveTransition() {}
    
    public func pauseInteractiveTransition() {}
}
