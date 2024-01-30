//
//  Rule.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - Rule -

/**
 Rule is a generic protocol to encapsulate the validation logic for a text field's Validator object.
 */
protocol Rule {
    
    /// The identifier of the rule. This is not user facing
    var identifier: String { get }
    
    /// The function to determine if the string is valid
    func isValid(string: String) -> Bool
    
    /// The error to show for a particular string with an identifier
    func error(for string: String, identifier: String) -> DisplayableError
    
}

/// CompositeRules combine multiple other rules ahead of time. Assumes individual rules
protocol CompositeRule: Rule {
    var rules: [Rule] { get }
}

/// AdHocRules are like CompositeRules in that they define a combination of other rules.
/// AdHocRules are different in that that you define them at the moment you need them because
/// it does not assume the Rules being added have all of their error messages defined. You can also
/// add new rules to an already existing AdHocRule as your conditions change.
protocol AdHocRule: Rule {
    var rules: [Rule] { get set }
    func addRule(_ rule: Rule)
}

// MARK: - Rules -

// MARK: - Min Length

/** Sets a minimum length for a textfield
 */
struct MinLengthRule: Rule {
    private let minLength: Int
    private let title: String?
    private let message: String?
    private let isOptional: Bool
    
    var identifier: String { return "MinLengthRule" }
    
    init(minLength: Int, optional: Bool = false, title: String? = nil, message: String? = nil) {
        self.minLength = minLength
        self.title = title
        self.message = message
        self.isOptional = optional
    }
    
    func isValid(string: String) -> Bool {
        return string.count >= minLength
    }
    
    func error(for string: String, identifier: String) -> DisplayableError {
        if string.isEmpty && !isOptional {
            let title = self.title ?? "You missed \(identifier)"
            let message = self.message ?? "Sometimes we skip things when we get excited, too! Please go back to \(identifier) and add something in."
            
            return DisplayableError(title: title, message: message)
        } else if string.count < minLength {
            let title = self.title ?? "\(identifier) is too short!"
            let message = self.message ?? "As much as we love cute, tiny words, we need \(identifier) to be at least \(minLength) characters long."
            
            return DisplayableError(title: title, message: message)
        }
        
        return DisplayableError()
    }
}

/** Sets a maximum length for a textfield
 */
struct MaxLengthRule: Rule {
    private let maxLength: Int
    private let title: String?
    private let message: String?
    private let isOptional: Bool
    
    var identifier: String { return "MaxLengthRule" }
    
    init(maxLength: Int, optional: Bool = false, title: String? = nil, message: String? = nil) {
        self.maxLength = maxLength
        self.title = title
        self.message = message
        self.isOptional = optional
    }
    
    func isValid(string: String) -> Bool {
        return string.count <= maxLength
    }
    
    func error(for string: String, identifier: String) -> DisplayableError {
        if string.isEmpty && !isOptional {
            let title = self.title ?? "You missed \(identifier)"
            let message = self.message ?? "Sometimes I miss things when I get too excited! Go back to \(identifier) and add something in."
            
            return DisplayableError(title: title, message: message)
        } else if string.count > maxLength {
            let title = self.title ?? "\(identifier) is too long!"
            let message = self.message ?? "You've put some effort into coming up with \(identifier), but our robots have told us to keep that under \(maxLength) characters long.\n\n🤖"
            
            return DisplayableError(title: title, message: message)
        }
        
        return DisplayableError()
    }
}

/**
 `EmailRule` requires that a string be an email address.
 */
struct EmailRule: Rule {
    private let title: String?
    private let message: String?
    private let isOptional: Bool
    
    var identifier: String { return "EmailRule" }
    
    init(optional: Bool = false, title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
        self.isOptional = optional
    }
    
    func isValid(string: String) -> Bool {
        return !string.isEmpty && string.isEmailAddress
    }
    
    func error(for string: String, identifier: String) -> DisplayableError {
        if string.isEmpty {
            let title = self.title ?? "You missed \(identifier)"
            let message = self.message ?? "Sometimes I miss things when I get too excited! Go back to \(identifier) and add something in."
            
            return DisplayableError(title: title, message: message)
        } else if !string.isEmailAddress {
            let title = self.title ?? "That email address..."
            let message = self.message ?? "I've seen a lot of emails in my time, and I don't think I've seen one quite like yours. Could you double check it for me?"
            
            return DisplayableError(title: title, message: message)
        }
        
        return DisplayableError()
    }
}

// MARK: - Composite Rules -

/** Composite rules are intented to combine any number of other rules so long as you have their individual
 rules set up to display the correct error messages. These aren't ad-hoc rules because you must define the individual
 rules yourself, ahead of time.
 */
struct MinMaxRule: CompositeRule {
    var identifier: String { return "MinMaxRule" }
    
    private let minLength: Int
    private let maxLength: Int
    private let isOptional: Bool
    
    var rules: [Rule] {
        return [MinLengthRule(minLength: minLength),
                MaxLengthRule(maxLength: maxLength)]
    }
    
    init(min: Int, max: Int, optional: Bool = false) {
        self.minLength = min
        self.maxLength = max
        self.isOptional = false
    }
    
    func isValid(string: String) -> Bool {
        for rule in rules {
            if !rule.isValid(string: string) { return false }
        }
        return true
    }
    
    func error(for string: String, identifier: String) -> DisplayableError {
        for rule in rules {
            if !rule.isValid(string: string) {
                return rule.error(for: string, identifier: identifier)
            }
        }
        
        return DisplayableError()
    }
    
}
