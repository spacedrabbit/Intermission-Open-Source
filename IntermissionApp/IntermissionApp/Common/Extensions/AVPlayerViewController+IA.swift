//
//  AVPlayerViewController+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/15/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

/** Extension to approximate the moment an AVPlayerViewController is presented and dismissed.
 
 */
extension AVPlayerViewController {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .avPlayerWillAppear, object: nil, userInfo: nil)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: .avPlayerDidAppear, object: nil, userInfo: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var userInfo: [String : Any] = [:]
        if let player = self.player {
            userInfo[AVPlayerNotificationKey.player] = player
        }
        
        NotificationCenter.default.post(name: .avPlayerWillDismiss, object: nil, userInfo: userInfo)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .avPlayerDidDismiss, object: nil, userInfo: nil)
    }
    
}

// MARK: - AVPlayerNotificationKey -

struct AVPlayerNotificationKey {
    
    static let player = "com.ia.avPlayernNotificationKey.player"
    
}

// MARK: - Notification.Name -

extension Notification.Name {
    
    static let avPlayerWillDismiss = Notification.Name(rawValue: "com.ia.avPlayerViewController.willDimiss")
    
    static let avPlayerDidDismiss = Notification.Name(rawValue: "com.ia.avPlayerViewController.didDismiss")
    
    static let avPlayerDidAppear = Notification.Name(rawValue: "com.ia.avPlayerViewController.didAppear")
    
    static let avPlayerWillAppear = Notification.Name(rawValue: "com.ia.avPlayerViewController.willAppear")
    
}
