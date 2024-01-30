//
//  UITableViewCell+IA.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
