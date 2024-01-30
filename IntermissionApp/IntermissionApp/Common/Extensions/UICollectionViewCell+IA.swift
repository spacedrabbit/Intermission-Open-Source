//
//  UICollectionViewCell+IA.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/23/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
