//
//  Calendar+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/30/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

public extension Calendar {
    
    /// Returns true if `distant` is the day before `recent`. Returns `nil` if it could not be determined from dates provided
    func isDate(_ distant: Date, theDayBefore recent: Date) -> Bool? {
        if let priorDateSameTime = date(byAdding: .day, value: -1, to: recent) {
            let priorDateStart = startOfDay(for: priorDateSameTime)
            
            let interval = dateInterval(of: .day, for: priorDateStart)
            return interval?.contains(distant)
        }
        return nil
    }

}
