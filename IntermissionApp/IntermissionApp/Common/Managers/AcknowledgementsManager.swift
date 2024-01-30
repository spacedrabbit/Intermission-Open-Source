//
//  AcknowledgementsManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

/// Simple class to read in a bundled json file to provide info to display in Settings
class AcknowledgementsManager {
    static let shared = AcknowledgementsManager()
    private let filepath = Bundle.main.path(forResource: "acknowledgements", ofType: "json")
    
    var acknowledgements: Acknowledgements? {
        guard let data = getJsonData(), let acknowledgements = parseAcknowledgements(data) else { return nil }
        return acknowledgements
    }
    
    private init() {}
    
    private func getJsonData() -> Data? {
        guard let path = filepath else { return nil }
        do {
            let fileUrl = URL(fileURLWithPath: path)
            return try Data(contentsOf: fileUrl, options: .mappedIfSafe)
        } catch (let e) {
            print("Error encountered retrieving JSON data: \(e)")
            Track.track(error: e)
            
            return nil
        }
    }
    
    private func parseAcknowledgements(_ data: Data) -> Acknowledgements? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Acknowledgements.self, from: data)
        } catch (let e) {
            print("Error encountered parsing JSON data: \(e)")
            Track.track(error: e)
            
            return nil
        }
    }
}
