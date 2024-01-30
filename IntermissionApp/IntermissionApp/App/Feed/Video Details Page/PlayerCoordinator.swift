//
//  PlayerCoordinator.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/8/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

// MARK: - PlayerCoordinator -

// TODO: This could use some functionality extensions to help guard against error states
/** Class used to manange observing state, via delegation, related to presenting/dismissing a AVPlayerViewController
 
 */
final class PlayerCoordinator {
    let playerViewController = AVPlayerViewController()
    let player: AVPlayer
    private(set) var url: URL?
    
    weak var delegate: PlayerCoordinatorDelegate?
    
    private var periodicObserverClosure: ((CMTime) -> Void)?
    private(set) var currentTime: Double = 0.0
    private(set) var progress: Double = 0.0
    private var observerToken: Any?
    
    // MARK: - Initializers -
    
    init(videoURL url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
        self.playerViewController.player = self.player
        
        // Register Notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerViewControllerWillDismiss(notification:)), name: .avPlayerWillDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerViewControllerDidDismiss(notification:)), name: .avPlayerDidDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerViewControllerWillAppear(notification:)), name: .avPlayerWillAppear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerViewControllerDidAppear(notification:)), name: .avPlayerDidAppear, object: nil)
    }
    
    deinit {
        periodicObserverClosure = nil
        NotificationCenter.default.removeObserver(self, name: .avPlayerWillDismiss, object: nil)
        NotificationCenter.default.removeObserver(self, name: .avPlayerDidDismiss, object: nil)
        NotificationCenter.default.removeObserver(self, name: .avPlayerWillAppear, object: nil)
        NotificationCenter.default.removeObserver(self, name: .avPlayerDidAppear, object: nil)
    }
    
    // MARK: - Actions
    
    func prepare() {
        if periodicObserverClosure != nil {
            periodicObserverClosure = nil
        }
        
        self.periodicObserverClosure = { [weak self] (time: CMTime) in
            self?.currentTime = time.seconds
            
            guard let item = self?.player.currentItem else { return }
            self?.progress = time.seconds / item.duration.seconds
        }
        
    }
    
    func presentVideo(in viewController: UIViewController, skipSeconds: Int? = nil) {
        guard url != nil else { return }
        prepare()
        
        viewController.present(playerViewController, animated: true) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch (let e) {
                // Log our error, but contine to play the video
                print("Error occured when trying to force audio on video playback: \(e)")
                Track.track(error: e, domain: ErrorType.App.Subtype.audioInitializationFailed)
            }
            
            if let seekSeconds = skipSeconds {
                let time = CMTime(seconds: Double(seekSeconds), preferredTimescale: 1)
                self.player.seek(to: time, completionHandler: { (complete) in
                    if complete {
                        self.player.play()
                    }
                })
            } else {
                self.player.play()
            }
        }
        
        guard let observerClosure = periodicObserverClosure else { return }
        self.observerToken = player.addPeriodicTimeObserver(forInterval:  CMTime(seconds: 1.0, preferredTimescale: .init(1.0)), queue: DispatchQueue.global(qos: .background), using: observerClosure)
    }
    
    // MARK: - Helpers
    
    ///  Removes the previously set periodicTimeObserver, if it exists.
    ///
    /// - Parameter synchronously: Optionally performs the action synchronously on the same queue that the observer was created in
    /// - Note: Performing this task synchronously ensures that any inflight blocks finish executing before removal
    private func removePeriodicTimeObserver(synchronously: Bool = false) {
        if let observer = self.observerToken {
            if synchronously {
                DispatchQueue.global(qos: .background).sync {
                    player.removeTimeObserver(observer)
                    self.observerToken = nil
                }
            } else {
                player.removeTimeObserver(observer)
                self.observerToken = nil
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc
    private func handlePlayerViewControllerWillDismiss(notification: Notification) {
        delegate?.playerCoordinator(self, willDismiss: playerViewController)
    }
    
    @objc
    private func handlePlayerViewControllerDidDismiss(notification: Notification) {
        delegate?.playerCoordinatorWasDismissed(self)
        removePeriodicTimeObserver()
        periodicObserverClosure = nil
    }
    
    @objc
    private func handlePlayerViewControllerWillAppear(notification: Notification) {
        delegate?.playerCoordinator(self, willAppear: playerViewController)
    }
    
    @objc
    private func handlePlayerViewControllerDidAppear(notification: Notification) {
        delegate?.playerCoordinator(self, didAppear: playerViewController)
    }
}

protocol PlayerCoordinatorDelegate: class {
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, willAppear playerController: AVPlayerViewController)
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, didAppear playerController: AVPlayerViewController)
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, willDismiss playerController: AVPlayerViewController)
    
    func playerCoordinatorWasDismissed(_ playerCoordinator: PlayerCoordinator)
    
}
