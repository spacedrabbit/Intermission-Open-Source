//
//  TouchdownPanGestureRecognizer.swift
//  IntermissionApp
//
//  Created by Charles Scalesse on 12/8/17.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass // `UIGestureRecognizerSubclass` is not included in the blanket `UIKit` import for some reason

/**
 The out-of-the-box `UIPanGestureRecognizer` has a few quirks that are not always desirable:
 
 1. The state is not changed to `.began` until a drag begins. This means that if the user touches
 down on a view and then immediately touches up without dragging, the state is never changed to
 `.began` and the gesture recognizer selector is never executed. This is a problem in cases when
 you want to do something immediately on touch down and before a drag begins.
 
 2. The same is true for the `.ended` event. If the user touches down without dragging, the state is
 never changed to `.began`. If the user lifts the finger without ever performing a drag, the state
 is never changed to `.ended` because, technically, the gesture never began.
 
 `TouchDownPanGestureRecognizer` works just like a `UIPanGestureRecognizer` except that it ALWAYS changes
 it's state to `.began` on touch down, and ALWAYS changes it's state to `.ended` on touch up, regardless of
 if the user dragged.
 
 */
open class TouchDownPanGestureRecognizer: UIPanGestureRecognizer {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.state != .began else { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
}
