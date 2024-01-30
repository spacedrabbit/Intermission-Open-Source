//
//  Dictionary+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// For JSON dictionaries
extension Dictionary where Key == String, Value == Any {
 
    func stringValue(_ key: Key) -> String? {
        return self[key] as? String
    }
    
    /// Assumes value was created using Date.iso8601String
    func dateValue(_ key: Key) -> Date? {
        guard let dateString = self.stringValue(key) else { return nil }
        return dateString.iso8601StringDate
    }
    
    func urlValue(_ key: Key) -> URL? {
        guard let urlString = self.stringValue(key) else { return nil }
        return URL(string: urlString)
    }
    
    func intValue(_ key: Key) -> Int? {
        if let intVal = self[key] as? Int {
            return intVal
        } else if let stringIntVal = self.stringValue(key) {
            return Int(stringIntVal)
        }
        
        return nil
    }
    
    func doubleValue(_ key: Key) -> Double? {
        if let doubleVal = self[key] as? Double {
            return doubleVal
        } else if let stringDoubleVal = self.stringValue(key) {
            return Double(stringDoubleVal)
        }
        
        return nil
    }
    
    func boolValue(_ key: Key) -> Bool? {
        if let boolVal = self[key] as? Bool { return boolVal }
        else if let boolStringVal = self.stringValue(key)?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            if boolStringVal == "true" { return true }
            else if boolStringVal == "false" { return false }
            else { return nil }
        } else if let boolIntVal = self.intValue(key) {
            if boolIntVal == 0 { return false }
            else if boolIntVal == 1 { return true }
            else { return nil }
        }
        return nil
    }
    
    func arrayValue<T: Hashable>(_ key: Key) -> [T]? {
        guard let arrayValue = self[key] as? [T] else { return nil }
        return arrayValue
    }
    
    func dictValue<K: Hashable, V>(_ key: Key) -> [K:V]? {
        guard let dictValue = self[key] as? [K:V] else { return nil }
        return dictValue
    }
    
    func anyValue<T>(_ key: Key, as: T.Type) -> T? {
        guard let anyValue = self[key] as? T else { return nil }
        return anyValue
    }
}
