//
//  AnimatedTextField.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - AnimatedTextField -

struct AnimatedTextFieldStyle {
    let inactivePlaceholderStyle: Style
    let activePlaceholderStyle: Style
    let textFieldStyle: Style
    let inactiveUnderlineColor: UIColor
    let activeUnderlineColor: UIColor
    
    static var loginStyle: AnimatedTextFieldStyle {
        let inactivePlaceholderStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBoldItalic), size: 18.0)
            $0.color = UIColor.white
            $0.alignment = .left
        }
        
        let activePlaceholderStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .italic), size: 12.0)
            $0.color = UIColor.white
            $0.alignment = .left
        }
        
        let textFieldStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBoldItalic), size: 18.0)
            $0.color = UIColor.white
            $0.alignment = .left
        }
        
        let inactiveUnderline = UIColor.white
        let activeUnderline = UIColor.paleLavendar
        
        return AnimatedTextFieldStyle(inactivePlaceholderStyle: inactivePlaceholderStyle, activePlaceholderStyle: activePlaceholderStyle, textFieldStyle: textFieldStyle, inactiveUnderlineColor: inactiveUnderline, activeUnderlineColor: activeUnderline)
    }
    
    static var onboardingStyle: AnimatedTextFieldStyle {
        let inactivePlaceholderStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBoldItalic), size: 18.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
        }
        
        let activePlaceholderStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .regular), size: 12.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
        }
        
        let textFieldStyle: Style = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBoldItalic), size: 18.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
        }
        
        let inactiveUnderline = UIColor.lightTextColor
        let activeUnderline = UIColor.textColor
        
        return AnimatedTextFieldStyle(inactivePlaceholderStyle: inactivePlaceholderStyle, activePlaceholderStyle: activePlaceholderStyle, textFieldStyle: textFieldStyle, inactiveUnderlineColor: inactiveUnderline, activeUnderlineColor: activeUnderline)
    }
}

class AnimatedTextField: UIView {
    weak var animatedTextFieldDelegate: AnimatedTextFieldDelegate?
    
    var animatedTextStyle: AnimatedTextFieldStyle = .loginStyle {
        didSet {
            self.setNeedsDisplay()
            self.updateStyles()
        }
    }
    
    private var placeholder: String = ""

    private var labelEmptyConstraint: NSLayoutConstraint?
    private var labelFilledConstraint: NSLayoutConstraint?
    private var animatedUnderlineTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Helper Enums
    
    private enum SlideDirection {
        case up, down
    }
    
    private enum Underlined {
        case yes, no
    }
    
    let textField: TextField = {
        let textField = TextField()
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words

        return textField
    }()
    
    private let placeholderLabel =  UILabel()
    private let animatedUnderline = UIView()
    
    // MARK: - Drawing -
    
    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 1.0
        
        let startPoint = CGPoint(x: 8.0, y: rect.height - lineWidth)
        let endPoint = CGPoint(x: rect.width - 8.0, y: rect.height - lineWidth)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(animatedTextStyle.inactiveUnderlineColor.cgColor)
        context?.move(to: startPoint)
        context?.addLine(to: endPoint)
        
        context?.strokePath()
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        self.addSubview(placeholderLabel)
        self.addSubview(textField)
        self.addSubview(animatedUnderline)
        updateStyles()
    
        textField.delegate = self
        
        self.configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(placeholder: String) {
        self.placeholder = placeholder
        self.placeholderLabel.styledText = self.placeholder

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func setText(_ text: String?) {
        textField.styledText = text
        slideLabel(direction: .up, animated: false)
    }
    
    private func updateStyles() {
        animatedUnderline.backgroundColor = animatedTextStyle.activeUnderlineColor
        placeholderLabel.style = animatedTextStyle.inactivePlaceholderStyle
        textField.style = animatedTextStyle.textFieldStyle
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Setup
    
    private func configureConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        animatedUnderline.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: maybe get rid of this
        self.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        // label left/right
        placeholderLabel.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor, constant: 2.0).isActive = true
        //    placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0).isActive = true
        
        // label empty text state
        labelEmptyConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: self.textField.centerYAnchor, constant: -4.0)
        labelEmptyConstraint?.isActive = true
        
        // label non-empty text state
        labelFilledConstraint = placeholderLabel.bottomAnchor.constraint(equalTo: self.textField.topAnchor, constant: 0.0)
        labelFilledConstraint?.isActive = false
        
        // textfield
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4.0).isActive = true
        
        // animated line
        animatedUnderline.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        animatedUnderline.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        animatedUnderline.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        self.animatedUnderlineTrailingConstraint = animatedUnderline.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0)
        self.animatedUnderlineTrailingConstraint?.isActive = true
    }
    
    // MARK: - Helpers
    
    private func slideLabel(direction: SlideDirection, animated: Bool = true) {
        
        switch direction {
        case .up:
            self.labelFilledConstraint?.isActive = true
            self.labelEmptyConstraint?.isActive = false
            self.placeholderLabel.style = animatedTextStyle.activePlaceholderStyle
            
        case .down:
            self.labelFilledConstraint?.isActive = false
            self.labelEmptyConstraint?.isActive = true
            self.placeholderLabel.style = animatedTextStyle.inactivePlaceholderStyle
        }
        
        self.setNeedsUpdateConstraints()
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            })
        } else {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Line Animations
    
    private func animateUnderline(_ underlined: Underlined) {
        switch underlined {
        case .yes:
            guard let animatedUnderlineTrailing = animatedUnderlineTrailingConstraint else { return }
            
            self.removeConstraint(animatedUnderlineTrailing)
            self.animatedUnderlineTrailingConstraint = animatedUnderline.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0)
            self.animatedUnderlineTrailingConstraint?.isActive = true
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
            
        case .no:
            guard let animatedUnderlineTrailing = animatedUnderlineTrailingConstraint else { return }
            
            self.removeConstraint(animatedUnderlineTrailing)
            self.animatedUnderlineTrailingConstraint = animatedUnderline.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0)
            self.animatedUnderlineTrailingConstraint?.isActive = true
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.175, delay: 0.0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
}


// MARK: - TextFieldDelegate -

extension AnimatedTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        slideLabel(direction: .up)
        animateUnderline(.yes)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        animateUnderline(.no)
        guard !textField.isEmpty else {
            slideLabel(direction: .down)
            return
        }
        
        slideLabel(direction: .up)
        self.animatedTextFieldDelegate?.animatedTextFieldDidEndEditing(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.defaultTextAttributes = animatedTextStyle.textFieldStyle.attributes
        
        return self.animatedTextFieldDelegate?.animatedTextField(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return self.animatedTextFieldDelegate?.animatedTextFieldShouldReturn(self) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animatedTextFieldDelegate?.animatedTextFieldDidEndEditing(self)
    }

}

// MARK: - AnimatedTextFieldDelegate -

protocol AnimatedTextFieldDelegate: class {
    func animatedTextField(_ textField: AnimatedTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func animatedTextFieldShouldReturn(_ textField: AnimatedTextField) -> Bool
    func animatedTextFieldDidEndEditing(_ textField: AnimatedTextField)
}
