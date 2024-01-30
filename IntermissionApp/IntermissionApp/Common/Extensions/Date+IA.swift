//
//  IA+Date.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

public extension Date {
    
    /// A formatter ready to handle iso8601 dates: normalized string output to an offset of 0 from UTC.
    static func iso8601Formatter(timeZone: TimeZone? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        // The locale and timezone properties must be exactly as follows to have a true, time-zone agnostic (i.e. offset of 00:00 from UTC) ISO stamp.
        formatter.locale = Foundation.Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone ?? TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }
    
    var iso8601String: String {
        return Date.iso8601Formatter().string(from: self)
    }
    
    internal static func setupDateString(with retreat: Retreat) -> String {
        let dateFormatterStart = Date.iso8601Formatter()
        dateFormatterStart.dateFormat = "MMM dd"
        
        let dateFormatterEnd = Date.iso8601Formatter()
        dateFormatterEnd.dateFormat = "dd, YYYY"
        
        var date = dateFormatterStart.string(from: retreat.startDate)
        date += "-\(dateFormatterEnd.string(from: retreat.endDate))"
        return date
    }
    
    func setupDateString() -> String {
        let dateFormatter = Date.iso8601Formatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        
        return dateFormatter.string(from: self)
    }
    
    var isToday: Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        return calendar.isDateInToday(self)
    }
    
}
