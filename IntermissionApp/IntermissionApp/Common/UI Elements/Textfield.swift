//
//  Textfield.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class TextField: UITextField, Validatable {
    
    var validator: Validator = Validator(rules: [], identifier: "Invalid")
    
    var validationText: String { return self.iaText }
    
}
