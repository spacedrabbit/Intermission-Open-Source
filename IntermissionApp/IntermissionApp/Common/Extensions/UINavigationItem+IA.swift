//
//  UINavigationItem+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/**
 Notification that fires whenever a navigation item's buttons are changed.
 
 */
extension Notification.Name {
    static let didChangeNavigationButtons = Notification.Name("com.ia.notification.name.didChangeNavigationButtons")
}

/**
 The key in the `didChangeNavigationButtons` notification's `userInfo` dictionary. The
 value is the `UINavigationItem` instance.
 
 */
struct NavigationItemKeys {
    static var item = "com.ia.navigationItem.item"
}

/**
 Adds buttons to `UINavigationItem` to be displayed by `NavigationController` whenever
 a view controller is being displayed with the navigation bar set to hidden.
 
 */
extension UINavigationItem {
    
    private struct Keys {
        // buttons
        static var leftNavigationButtons = "com.ia.navigationItem.leftNavigationButtons"
        static var rightNavigationButtons = "com.ia.navigationItem.rightNavigationButtons"
        
        // activity
        static var savedRightBarButtonItems = "com.ia.navigationItem.savedRightBarButtonItems"
        static var savedLeftBarButtonItems = "com.ia.navigationItem.savedLeftBarButtonItems"
        static var isRightBarButtonItemsShowingActivity = "com.ia.navigationItem.isRightBarButtonItemsShowingActivity"
        static var isLeftBarButtonItemsShowingActivity = "com.ia.navigationItem.isLeftBarButtonItemsShowingActivity"
    }
    
    // MARK: - Navigation Buttons
    
    public var leftNavigationButton: UIButton? {
        set {
            if let leftButton = newValue {
                leftNavigationButtons = [leftButton]
            } else {
                leftNavigationButtons = []
            }
        }
        get {
            return leftNavigationButtons.first
        }
    }
    
    public var rightNavigationButton: UIButton? {
        set {
            if let rightButton = newValue {
                rightNavigationButtons = [rightButton]
            } else {
                rightNavigationButtons = []
            }
        }
        get {
            return rightNavigationButtons.first
        }
    }
    
    public var leftNavigationButtons: [UIButton] {
        set {
            objc_setAssociatedObject(self, &Keys.leftNavigationButtons, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            NotificationCenter.default.post(name: .didChangeNavigationButtons, object: nil, userInfo: [NavigationItemKeys.item: self])
        }
        get {
            if let buttons = objc_getAssociatedObject(self, &Keys.leftNavigationButtons) as? [UIButton] {
                return buttons
            }
            return []
        }
    }
    
    public var rightNavigationButtons: [UIButton] {
        set {
            objc_setAssociatedObject(self, &Keys.rightNavigationButtons, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            NotificationCenter.default.post(name: .didChangeNavigationButtons, object: nil, userInfo: [NavigationItemKeys.item: self])
        }
        get {
            if let buttons = objc_getAssociatedObject(self, &Keys.rightNavigationButtons) as? [UIButton] {
                return buttons
            }
            return []
        }
    }
}
