//
//  TextFieldCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - TextFieldCell -

class TextFieldCell: TableViewCell {
    weak var delegate: TextFieldCellDelegate?
    var preventsWhitespaceCharacters: Bool = false
    
    private let animatedTextField = AnimatedTextField()
    private var checkmarkVisible: Bool = false
    
    var shouldDisplayCheckmark: Bool = true {
        didSet {
            checkmarkImageView.isHidden = !shouldDisplayCheckmark
        }
    }
    
    // TODO: I don't like the hierarchy being used for this textfield, but need to leave it for now.
    /// Use this for accessing the underlying textfield in AnimatedTextField.
    var textField: TextField {
        return animatedTextField.textField
    }
    
    private let checkmarkImageView: ImageView = {
        let imageView = ImageView(image: Icon.Checkmark.light.image)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.bottomSeparator.isHidden = true
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        
        animatedTextField.animatedTextFieldDelegate = self
        
        self.contentView.addSubview(animatedTextField)
        self.contentView.addSubview(checkmarkImageView)
        
        animatedTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40.0)
            make.centerWithinMargins.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-30.0)
            make.centerYWithinMargins.equalToSuperview().offset(10.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(placeholder: String, text: String? = nil, validator: Validator, textFieldStyle: AnimatedTextFieldStyle? = nil) {
        
        animatedTextField.configure(placeholder: placeholder)
        textField.validator = validator
        
        if let style = textFieldStyle {
            animatedTextField.animatedTextStyle = style
        }
        
        if let t = text {
            animatedTextField.setText(t)
        }
    }
    
    // MARK: - Checkmark Animations -
    
    private func showCheckMark() {
        guard !checkmarkVisible else { return }
        let currentCenter = checkmarkImageView.center
        
        UIView.animateKeyframes(withDuration: 0.35, delay: 0.0, options: [.beginFromCurrentState, .calculationModeCubicPaced], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.checkmarkImageView.center = currentCenter.applying(CGAffineTransform(translationX: 0.0, y: 7.0))
                self.checkmarkImageView.alpha = 0.75
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.checkmarkImageView.center = currentCenter.applying(.identity)
                self.checkmarkImageView.alpha = 1.0
            })
            
        }) { (complete) in
            if complete { self.checkmarkVisible = true }
        }
    }
    
    private func hideCheckMark() {
        guard checkmarkVisible else { return }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            self.checkmarkImageView.alpha = 0.0
        }) { (complete) in
            if complete { self.checkmarkVisible = false }
        }
    }
}

// MARK: - AnimatedTextFieldDelegate -

extension TextFieldCell: AnimatedTextFieldDelegate {
    
    func animatedTextField(_ textField: AnimatedTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if checkmarkVisible { hideCheckMark() }
        
        var cleanString = string
        if preventsWhitespaceCharacters {
            if string.count > 1 && string.contains(" ") {
                cleanString = string.replacingOccurrences(of: " ", with: "")
            } else if string.count == 1 && string.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil {
                return false
            }
        }

        return delegate?.textFieldCell(self, shouldChangeCharactersIn: range, replacementString: cleanString) ?? true
    }
    
    func animatedTextFieldShouldReturn(_ textField: AnimatedTextField) -> Bool {
        return delegate?.textFieldCellShouldReturn(self) ?? true
    }
    
    func animatedTextFieldDidEndEditing(_ textField: AnimatedTextField) {
        if textField.textField.isValid { showCheckMark() }
        delegate?.textFieldCellDidEndEditing(self)
    }
    
}

// MARK: - TextFieldCellDelegate Protocol -

protocol TextFieldCellDelegate: class {
    
    func textFieldCellDidEndEditing(_ textFieldCell: TextFieldCell)
    
    func textFieldCellShouldReturn(_ textFieldCell: TextFieldCell) -> Bool
    
    func textFieldCell(_ textFieldCell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}
