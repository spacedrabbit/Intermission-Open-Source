//
//  StartupManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import Firebase
import FacebookCore
import Contentful

final class StartupManager {
    
    static func configure(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        configureFirebase()
        configureFacebook(application: application, launchOptions: launchOptions)
        configureStyles()
        
        SessionManager.prepare()
        SearchManager.prepare()
    }
    
    private static func configureFirebase() {
        FirebaseApp.configure()
        let _ = Firestore.firestore()
    }
    
    private static func configureFacebook(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private static func configureStyles() {
        Font.registerFonts()
    }
    
    static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
}
