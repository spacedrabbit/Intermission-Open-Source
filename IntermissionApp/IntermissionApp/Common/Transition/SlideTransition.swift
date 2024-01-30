//
//  SlideTransition.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let direction: SlideDirection
    
    enum SlideDirection {
        case fromRight, fromLeft
    }
    
    init(direction: SlideDirection) {
        self.direction = direction
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromView = transitionContext.view(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let container = transitionContext.containerView
        guard let fromSnapshot = fromView.snapshotView(afterScreenUpdates: false) else {
            transitionContext.completeTransition(true)
            return
        }
        
        container.addSubview(fromSnapshot)
        fromSnapshot.frame = container.bounds
        
        container.addSubview(toView)
        var finalFromViewOrigin: CGPoint = .zero
        if direction == .fromRight {
            toView.frame.origin = CGPoint(x: container.w, y: 0.0)
            finalFromViewOrigin = CGPoint(x: -container.w, y: 0.0)
        } else {
            toView.frame.origin = CGPoint(x: -container.w, y: 0.0)
            finalFromViewOrigin = CGPoint(x: container.w, y: 0.0)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [.beginFromCurrentState], animations: {
            fromSnapshot.frame.origin = finalFromViewOrigin
            toView.frame.origin = .zero
        }) { (complete) in
            fromSnapshot.removeFromSuperview()
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
}
