//
//  String+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import CoreText

// MARK - Regex Checking -

extension String {
    
    public var isEmailAddress: Bool {
        let emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    public var isPhoneNumber: Bool {
        let phoneNumberRegex = "^(?:\\([2-9]\\d{2}\\)\\ ?|[2-9]\\d{2}(?:\\-?|\\ ?))[2-9]\\d{2}[- ]?\\d{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES[c] %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: self)
    }
}


// MARK - Emojis -

/** Emoji-Related Helpers
 *  https://stackoverflow.com/a/39425959/3833368
 */

extension String {
    
    /// Converts self into an attributed string and uses CoreText to determine the number of glyphs.
    private var glyphCount: Int {
        let attributedString = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(attributedString)
        return CTLineGetGlyphCount(line)
    }
    
    /// Checks that there is only a single glyph in self, and that it is an emoji.
    public var isEmoji: Bool {
        return glyphCount == 1 && containsEmoji
    }
    
    /// Checks Self.unicodeScalars for an emoji
    public var containsEmoji: Bool {
        return unicodeScalars.contains { String($0).isEmoji }
    }
    
}

// MARK: - Date Helpers

extension String {
    
    /// Return a `Date` object if the current String is in the right format.
    public var iso8601StringDate: Date? {
        return Date.iso8601Formatter().date(from: self)
    }
    
}
