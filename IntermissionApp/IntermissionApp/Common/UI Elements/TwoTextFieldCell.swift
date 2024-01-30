//
//  TwoTextFieldCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/26/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// TODO: replace the two cells in the onboarding name capture
class TwoTextFieldCell: TableViewCell {
    weak var delegate: TextFieldCellDelegate?
    
}

protocol TwoTextFieldCellDelegate: class {
    
    func twoTextFieldCellDidEndEditing(_ textFieldCell: TwoTextFieldCell)
    
    func twoTextFieldCellShouldReturn(_ textFieldCell: TwoTextFieldCell) -> Bool
    
    func twoTextFieldCell(_ textFieldCell: TwoTextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}
