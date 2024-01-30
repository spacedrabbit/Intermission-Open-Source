//
//  TabBarController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/25/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 0.85, 1.0]
        bounceAnimation.duration = TimeInterval(0.20)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    // Button Animation: https://blog.kulman.sk/animating-tab-bar-buttons/
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard
            let itemIndex = tabBar.items?.index(of: item),
            tabBar.subviews.count > itemIndex + 1,
            let selectedItemView = tabBar
                                    .subviews[itemIndex + 1]
                                    .subviews
                                    .compactMap ({ $0 as? UIImageView }).first
        else { return }
        
        selectedItemView.layer.add(bounceAnimation, forKey: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tabBar.isTranslucent = false
    }
    
}

extension TabBarController: UITabBarControllerDelegate {
    
}

// Fix for http://www.openradar.me/36924354
// Answer from https://gist.github.com/calt/7ea29a65b440c2aa8a1a
extension UITabBar {
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        
        if #available(iOS 12.0, *) {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = window.safeAreaInsets.bottom + 40.0
            return sizeThatFits
        } else {
            return super.sizeThatFits(size)
        }
    }
    
}
