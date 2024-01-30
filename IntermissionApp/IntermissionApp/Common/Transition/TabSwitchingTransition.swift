//
//  TabSwitchingTransition.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/** Simple sliding transition intended to be used in a tabbed interface
 
 */
class TabSwitchingTransition: Transition {
    private let direction: Direction
    private let from: UIViewController
    private let to: UIViewController
    private let inbetween: [UIViewController]
    
    enum Direction {
        case leftToRight
        case rightToLeft
    }
    
    init(from: UIViewController, to: UIViewController, intermediary: [UIViewController], direction: Direction) {
        self.from = from
        self.to = to
        self.inbetween = intermediary
        self.direction = direction
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            toVC === to, fromVC === from
            else { return }
        
        let container = transitionContext.containerView
        
        switch direction {
        case .leftToRight:
            toView.transform = CGAffineTransform(translationX: container.w, y: 0.0)
            
            container.addSubview(fromView)
            container.addSubview(toView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.beginFromCurrentState,.curveEaseOut], animations: {
                
                fromView.transform = CGAffineTransform(translationX: -container.w, y: 0.0)
                toView.transform = .identity
                
            }) { (complete) in
                guard complete else { return }
                
                fromView.transform = .identity
                fromView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            }
            
        case .rightToLeft:
            
            toView.transform = CGAffineTransform(translationX: -container.w, y: 0.0)
            
            container.addSubview(fromView)
            container.addSubview(toView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.beginFromCurrentState,.curveEaseOut], animations: {
                
                fromView.transform = CGAffineTransform(translationX: container.w, y: 0.0)
                toView.transform = .identity
                
            }) { (complete) in
                guard complete else { return }
                
                fromView.transform = .identity
                fromView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            }
            
        }
    }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
}
