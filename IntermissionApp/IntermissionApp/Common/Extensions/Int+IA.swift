//
//  Int+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

enum TimeFormat {
    case abreviated, full
}

extension Int {

    /// Simple formatting assumes time < 1hr
    func minuteString(format: TimeFormat = .abreviated) -> String {
        guard self > 0 else { return "" }

        var minutes = Int((Double(self) / 60.0).rounded(.down))
        let seconds = self % 60
        
        switch format {
        case .abreviated:
            if minutes == 0 && seconds > 0 { return "< 1 MIN" }
            if seconds > 35 { minutes += 1 }
            return "\(minutes) MIN"
        case .full:
            if minutes == 0 { return String(format: "%02i SEC", seconds) }
            return String(format: "%i:%02i", minutes, seconds)
        }
    }
    
}

extension TimeInterval {
    
    func minuteString(format: TimeFormat = .abreviated) -> String {
        return Int(self).minuteString(format: format)
    }
    
}
