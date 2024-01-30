//
//  Strings.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - Facebook -

struct FacebookStrings {
    struct Error {
        static let authCancelledTitle = "Not a facebook person?"
        static let authCancelledBody = "That's alright, feel free to log in with your email or just browse as our guest!"
        static let declinedEmailPermissionTitle = "Oh, we needed that"
        static let declinedEmailPermissionBody = "Providing your email allows us to send you order updates, log you in and other. We never give that information away to anyone, promise."
        static let declinedProfilePermissionTitle = "Let's get to know each other"
        static let declinedProfilePermissionBody = "We were interested in just the basics about you to be able to welcome you by name every time you stopped in. We get it though, privacy is important. If you change your mind come sign up again, otherwise feel free to browse as our guest, friend!"
        static let missingUserIdTitle = "Ah, a mystery!"
        static let missingUserIdBody = "There doesn't seem to be an ID for your Facebook account. We're confused why that is also. Maybe try again or sign up with your email?"
    }
}
