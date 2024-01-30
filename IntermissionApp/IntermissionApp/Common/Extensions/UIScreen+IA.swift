//
//  UIScreen+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

extension UIScreen {
    
    static let compactEquivalent: CGSize = CGSize(width: 320.0, height: 480.0)
    static let compactLongEquivalent: CGSize = CGSize(width: 320.0, height: 568.0)
    static let normalEquivalent: CGSize = CGSize(width: 375.0, height: 667.0)
    static let tallEquivalent: CGSize = CGSize(width: 414.0, height: 736.0)
    static let extraTallEquivalent: CGSize = CGSize(width: 375.0, height: 812.0)
    static let extraTallExtendedEquivalent: CGSize = CGSize(width: 414.0, height: 896.0)
    
    /// true if is an iPhone variant with a "notch", iPhoneX/XS/XR. Includes simulator.
    static var hasNotch: Bool {
        return DeviceManager.isExtraTallDisplay
            || (DeviceManager.isSimulator && UIScreen.main.bounds.size == extraTallEquivalent)
            || (DeviceManager.isSimulator && UIScreen.main.bounds.size == extraTallExtendedEquivalent)
    }
    
    /// true if a iPhone+ variant or iPhoneX/XS/XR. Included simulator
    static var isLargeScreen: Bool {
        return DeviceManager.isTallDisplay
            || DeviceManager.isExtraTallDisplay
            || (DeviceManager.isSimulator && UIScreen.main.bounds.size == tallEquivalent)
            || hasNotch
    }
    
}
