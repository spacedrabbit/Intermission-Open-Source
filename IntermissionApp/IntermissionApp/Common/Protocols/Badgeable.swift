//
//  Badgeable.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/17/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

enum BadgePosition{
    case left, right
}

protocol Badgeable {
    
    /// Shows the badge with a specific number, optional animation
    func showBadge(_ count : Int, animated: Bool)
    
    /// Hides the badge, optional animation
    func hideBadge(animated: Bool)
    
    /// Updates badge with new number, optional animation. This should also show the badge if it is hidden
    func updateBadge(_ count: Int, animated: Bool)
    
    /// If updating the badge to a count of 0 should hide the badge
    var badgeHidesWhenZero: Bool { get }
    
    /// Puts the badge on either to top right or top left of the element
    var badgePosition: BadgePosition { get set }
}
