//
//  SlideFromTopTransition.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/26/19.
//  Originally by Created by Charles Scalesse on 1/10/17.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class SlideFromTopTransition: Transition {
    private let topMargin: CGFloat?
    
    private let dimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    // MARK: - Constructors
    
    public init(topMargin: CGFloat? = nil) {
        self.topMargin = topMargin
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning Methods
    
    override public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController = transitionContext.viewController(forKey: .from),
            let toController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) ?? fromController.view,
            let toView = transitionContext.view(forKey: .to) ?? toController.view
            else { return }
        
        self.beginIgnoringInteractionEvents()
        
        let containerView = transitionContext.containerView
        
        if self.isPresenting {
            dimmerView.alpha = 0.0
            dimmerView.frame = containerView.bounds
            containerView.addSubview(dimmerView)
            
            toView.frame = CGRect(x: (containerView.frame.size.width - toView.frame.size.width) / 2.0, y: -toView.frame.size.height, width: toView.frame.size.width, height: toView.frame.size.height)
            containerView.addSubview(toView)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.dimmerView.alpha = 1.0
                if let topMargin = self.topMargin {
                    toView.frame = CGRect(x: toView.frame.origin.x, y: topMargin, width: toView.frame.size.width, height: toView.frame.size.height)
                } else {
                    toView.center = CGPoint(x: containerView.frame.size.width / 2.0, y: containerView.frame.size.height / 2.0)
                }
            }) { didFinsh in
                self.endIgnoringInteractionEvents()
                transitionContext.completeTransition(didFinsh)
            }
        } else {
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.dimmerView.alpha = 0.0
                fromView.frame = CGRect(x: (containerView.frame.size.width - fromView.frame.size.width) / 2.0, y: -fromView.frame.size.height, width: fromView.frame.size.width, height: fromView.frame.size.height)
            }) { didFinsh in
                fromView.removeFromSuperview()
                self.dimmerView.removeFromSuperview()
                self.endIgnoringInteractionEvents()
                transitionContext.completeTransition(didFinsh)
            }
        }
        
    }
    
    override public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return 0.55
        } else {
            return 0.2
        }
    }
    
}
