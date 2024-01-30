//
//  DomainBuilding.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

protocol DomainBuildable {
    func build() -> String
}

protocol DomainDescriptable {
    static var domain: String { get }
    static var parent: DomainDescriptable.Type? { get }
}

protocol DomainTerminating: DomainBuildable {
    static var parent: DomainDescriptable.Type? { get }
    var name: String { get }
    var displayName: String? { get }
    var errorCode: Int { get }
}

extension DomainTerminating {
    
    func build() -> String {
        var errorDomain = self.name
        
        var nextParent = Self.parent
        while nextParent != nil, let p = nextParent {
            errorDomain = p.domain + errorDomain
            nextParent = p.parent
        }
        
        return errorDomain
    }
    
    var displayName: String? {
        return nil
    }
    
    var errorCode: Int {
        return 0
    }
}
