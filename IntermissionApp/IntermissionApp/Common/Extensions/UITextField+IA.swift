//
//  UITextField+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

extension UITextField {
    
    /// Returns `true` if the text field's text is either empty or nil
    var isEmpty: Bool {
        guard let text = self.text else { return true }
        return text.isEmpty
    }
    
    /// Returns either `text` if the value is non-nil, or an empty string.
    var iaText: String {
        return self.text ?? ""
    }
    
}
