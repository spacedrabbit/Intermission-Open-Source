//
//  ActivityPresentable.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/**
 Classes conforming to this should be able to display an activity indicator on them
 */
protocol ActivityPresentable {
    func showActivity()
    func hideActivity()
}
