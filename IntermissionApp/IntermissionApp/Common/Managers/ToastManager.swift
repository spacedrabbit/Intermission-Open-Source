//
//  ToastManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/14/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString
import SnapKit

class ToastManager: NSObject {
    static private let shared = ToastManager()
    
    private let animationDuration: TimeInterval = 0.2
    private var queue = [ToastEvent]()
    private var activeEvent: ToastEvent?
    private var startTime: Date?
    private let containerView = UIView()
    
    fileprivate let panRecognizer = TouchDownPanGestureRecognizer()
    fileprivate let singleTapRecognizer = UITapGestureRecognizer()
    
    private var containerTopConstraint: Constraint?
    private var containerBottomConstraint: Constraint?
    
    fileprivate var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    public struct Defaults {
        static let style: ToastStyle = .accent
        static let position: ToastPosition = .top
        static let duration: TimeInterval = 2.5
        static let view: UIView = UIApplication.shared.keyWindow ?? UIView()
    }
    
    private override init() {
        super.init()
        
        panRecognizer.addTarget(self, action: #selector(handleDrag(_:)))
        panRecognizer.delegate = self
        containerView.addGestureRecognizer(panRecognizer)
        
        singleTapRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        
        panRecognizer.require(toFail: singleTapRecognizer)
    }
    
    // - MARK: - Presentation -

    static func show(title: String, highlightedTitle: String?, accessory: ToastAccessory, position: ToastPosition = Defaults.position) {
        let toastView = ToastView(style: .accent)
        toastView.configure(with: title, highlightedText: highlightedTitle, leftAccessory: accessory)
        let toastEvent = ToastEvent(toastView: toastView,
                                    duration: 2.5,
                                    position: position,
                                    superview: Defaults.view,
                                    tapAction: nil)
        shared.show(event: toastEvent)
    }
    
    
    // MARK: - Show / Hide -
    
    /**
     Hides the currently active toast, if any.
     
     */
    static func hideActive() {
        shared.hideToast()
    }
    
    private func show(event: ToastEvent) {
        guard activeEvent == nil else {
            queue.append(event)
            return
        }
        
        // Only show one at a time
        activeEvent = event
        
        // Remove constraints from container, and remove any old toasts
        containerView.snp.removeConstraints()
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // put the new toast view in the container and add the container to the correct superview
        let toast = event.toast
        let superview = event.superview
        
        if event.tapAction != nil {
            containerView.addGestureRecognizer(singleTapRecognizer)
        }
        
        containerView.backgroundColor = .clear
        containerView.addSubview(toast)
        superview.addSubview(containerView)
        
        // Constraint Setup for toast
        toast.snp.makeConstraints { (make) in
            make.centerX.equalTo(event.superview)
            make.width.equalTo(event.superview)
            make.top.bottom.equalToSuperview()
        }
        
        // we need to initially position the constraints to later animate properly
        if event.position == .top {
            containerView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.bottom.equalTo(superview.snp.top)
            }
            
        } else {
            containerView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.top.equalTo(superview.snp.bottom)
            }
        }
        superview.setNeedsLayout()
        superview.layoutIfNeeded()
        
        if event.position == .top {
            containerView.snp.updateConstraints { (make) in
                make.bottom.equalTo(superview.snp.top).offset(toast.h + superview.safeAreaInsets.top)
            }
            containerView.setNeedsLayout()
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut], animations: {
                superview.layoutIfNeeded()
            }) { (_) in
                self.startTimer(duration: event.duration)
            }
            
        } else {
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(superview.snp.bottom).offset(-toast.h - superview.safeAreaInsets.bottom)
            }
            containerView.setNeedsLayout()
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState, .allowAnimatedContent], animations: {
                superview.layoutIfNeeded()
            }) { (_) in
                self.startTimer(duration: event.duration)
            }
        }
    }
    
    private func showNext() {
        guard activeEvent == nil, !queue.isEmpty else { return }
        show(event: queue.removeFirst())
    }
    
    
    private func hideToast() {
        guard let event = activeEvent else { return }
        let superview = event.superview
        
        // kill the timer if it's still active
        timer = nil
        
        // adjust the animation duration based on the position of the container
        
        if event.position == .top {
            containerView.snp.updateConstraints { (make) in
                make.bottom.equalTo(superview.snp.top).offset(0.0)
            }
            containerView.setNeedsLayout()
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut], animations: {
                superview.layoutIfNeeded()
                
            }) { (complete) in
                guard complete else { return }
                self.startTime = nil
                self.activeEvent = nil
                self.showNext()
            }
            
        } else {
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(superview.snp.bottom).offset(0.0)
            }
            superview.setNeedsLayout()
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState, .allowAnimatedContent], animations: {
                superview.layoutIfNeeded()
                
            }) { (complete) in
                guard complete else { return }
                self.startTime = nil
                self.activeEvent = nil
                self.showNext()
            }
        }
        
    }
    
    
    // MARK: - Timer Methods -
    
    private func startTimer(duration: TimeInterval) {
        // set the start time
        startTime = Date()
        
        // start the timer
        restartTimer(duration: duration)
    }
    
    private func restartTimer(duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] (timer: Timer) in
            self?.hideToast()
        })
    }
    
    
    // MARK: - Actions -
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let activeEvent = activeEvent, let tapAction = activeEvent.tapAction else { return }
        
        // run tap action if provided
        tapAction()
    }
    
    @objc
    private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        guard
            let container = recognizer.view,
            let activeEvent = activeEvent,
            let startTime = startTime
        else { return }
        
        
        switch recognizer.state {
        case .began:
            // user touched down on the container so stop the timer
            timer = nil
            
        case .changed:
            let translation = recognizer.translation(in: container.superview)
            if activeEvent.position == .top {
                container.center = CGPoint(x: container.center.x, y: min(container.h / 2.0 + activeEvent.superview.safeAreaInsets.top, container.center.y + translation.y))
            } else {
                container.center = CGPoint(x: container.center.x, y: max(activeEvent.superview.h - activeEvent.superview.safeAreaInsets.bottom - (container.frame.size.height / 2.0), container.center.y + translation.y))
            }
            recognizer.setTranslation(.zero, in: container.superview)
            
        case .ended, .cancelled:
            // user touched up on the container
            let remainingDuration = activeEvent.duration - Date().timeIntervalSince(startTime)
            
            if remainingDuration <= 0.0 {
                // the duration is up, dismiss
                hideToast()
            } else if activeEvent.position == .top && containerView.frame.origin.y < 0.0 {
                // the toast position is top and the user swiped the view up, dismiss
                hideToast()
            } else if activeEvent.position == .bottom && containerView.frame.origin.y > (activeEvent.superview.frame.size.height - container.frame.size.height) {
                // the toast position is bottom and the user swiped the view down, dismiss
                hideToast()
            } else {
                // retart the timer for the duration
                restartTimer(duration: remainingDuration)
            }
        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Methods

extension ToastManager: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panRecognizer {
            return true
        }  else if gestureRecognizer === singleTapRecognizer {
            guard (activeEvent?.toast.action) != nil else { return false }
            return true
        }
        return false
    }
}



/// Where the toast is anchored from
enum ToastPosition {
    case top, bottom
}

// MARK: - ToastEvent -

/// Simple class to encapsulate all the info necessary for displaying a Toast
private class ToastEvent {
    fileprivate let toast: ToastView
    fileprivate let tapAction: EmptyCompletion?
    fileprivate let duration: TimeInterval
    fileprivate let position: ToastPosition
    fileprivate let superview: UIView
    
    init(toastView: ToastView, duration: TimeInterval, position: ToastPosition, superview: UIView, tapAction: EmptyCompletion?) {
        self.toast = toastView
        self.duration = duration
        self.position = position
        self.superview = superview
        self.tapAction = tapAction
    }
}
