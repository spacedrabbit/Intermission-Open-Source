//
//  File.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

protocol Validatable {
    
    var validator: Validator { get set }
    
    var validationText: String { get }
    
    var isValid: Bool { get }
    
}

extension Validatable {
    
    var isValid: Bool {
        return validator.validate(string: validationText) == nil
    }
    
}


struct Validator {
    
    let rules: [Rule]
    let identifier: String
    
    init(rules: [Rule], identifier: String) {
        self.rules = rules
        self.identifier = identifier
    }
    
    func validate(string: String) -> Rule? {
        return rules.first { !$0.isValid(string: string) }
    }
    
}



struct DisplayableError: Error, Equatable {
    // TODO: provide an actionable step if it's a default error
    var title: String = "An Error Occurred!"
    var message: String = "Well this is embarassing, I'm not entirely sure what went wrong!"
    var originalError: Error?
    
    private var _attributedTitle: NSAttributedString?
    private var _attributedMessage: NSAttributedString?
    
    private (set) var isIgnored: Bool = false
    
    var attributedTitle: NSAttributedString {
        set { _attributedTitle = newValue }
        get { return _attributedTitle ?? NSAttributedString(string: title) }
    }
    var attributedMessage: NSAttributedString {
        set { _attributedMessage = newValue }
        get { return _attributedMessage ?? NSAttributedString(string: message) }
    }
    
    init() {}
    
    init(title: String, message: String, ignore: Bool = false, error: Error? = nil) {
        self.title = title
        self.message = message
        self.isIgnored = ignore
        self.originalError = error
    }
    
    @discardableResult
    mutating func ignore() -> DisplayableError {
        isIgnored = true
        return self
    }
    
    static func ==(lhs: DisplayableError, rhs: DisplayableError) -> Bool {
        return (lhs.title == rhs.title && lhs.message == rhs.message)
            || (lhs.attributedTitle == rhs.attributedTitle && lhs.attributedMessage == rhs.attributedMessage)
    }
}
