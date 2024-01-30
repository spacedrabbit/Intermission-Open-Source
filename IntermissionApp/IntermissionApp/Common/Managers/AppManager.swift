//
//  AppManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import SwiftRichString

final class AppManager {
    
    private static let appName = "Intermission App"
    
    private static var appVersionSring: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    private static var appBundleVersionString: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    static var appVersionSupportEmailString: String {
        guard
            let appVersion = appVersionSring,
            let bundleVersion = appBundleVersionString,
            !appVersion.isEmpty, !bundleVersion.isEmpty
            else { return "" }
        
        return "v.\(appVersion) (\(bundleVersion))"
    }
    
    static var appVersionDisplayString: NSAttributedString? {
        guard
            let appVersion = appVersionSring,
            let bundleVersion = appBundleVersionString,
            !appVersion.isEmpty, !bundleVersion.isEmpty
        else { return nil }
        
        return "\(appName) v.\(appVersion) (Build \(bundleVersion))".set(style: Style {
            $0.color = UIColor.lightTextColor
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 12.0)
            $0.alignment = .center
        })
    }
    
}
