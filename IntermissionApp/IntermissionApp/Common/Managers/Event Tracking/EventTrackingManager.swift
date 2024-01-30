//
//  EventTrackingManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Firebase

typealias Track = EventTrackingManager
final class EventTrackingManager {

    private init() {}
    
    // MARK: - Configure -
    
    /// Configures user-based properties for sending analytic events. Always configure with either a User or GuestUser before sending any analytics
    static func configure(with user: User) {
        Track.logAsRegisteredUser()
        if user.isPro {
            Track.logAsProMember()
        } else {
            Track.logAsFreeMember()
        }
    }
    
    /// Configures user-based properties for sending analytic events. Always configure with either a User or GuestUser before sending any analytics
    static func configure(with guest: GuestUser) {
        Track.logAsGuestUser()
        Track.logAsFreeMember()
    }
    
    // MARK: - Tracking Events -
    
    static func track(event: Event) {
        Analytics.logEvent(event.type, parameters: event.properties)
    }
    
    static func track(eventName: String) {
        let event = Event(type: eventName, properties: [:])
        Track.track(event: event)
    }
    
    static func track(eventName: String, user: User) {
        Track.configure(with: user)
        Track.track(eventName: eventName)
    }
    
    static func track(eventName: String, guest: GuestUser) {
        Track.configure(with: guest)
        Track.track(eventName: eventName)
    }
    
    static func track(event: Event, user: User) {
        Track.configure(with: user)
        Analytics.logEvent(event.name, parameters: event.properties)
    }
    
    static func track(event: Event, guest: GuestUser) {
        Track.configure(with: guest)
        Analytics.logEvent(event.name, parameters: event.properties)
    }
    
    // MARK: - Tracking Errors -
    
    static func track(domain: DomainTerminating) {
        Analytics.logEvent(domain.build(), parameters: [:])
    }
    
    static func track(error: Error?, domain: DomainTerminating = ErrorType.Default.Subtype.unexpectedState) {
        Analytics.logEvent(domain.build(), parameters: Track.generateTrackingProperties(for: error))
    }
    
    static func track(displayableError: DisplayableError, domain: DomainTerminating = ErrorType.Default.Subtype.unexpectedState) {
        Analytics.logEvent(domain.build(), parameters: generateTrackingProperties(for: displayableError))
    }
    
    // MARK: - Private Helpers -
    
    /// Call before any other tracking if the current user is a registered User
    private static func logAsRegisteredUser() {
        Analytics.setUserProperty(RegistrationStatus.registered, forName: RegistrationStatus.key)
    }
    
    /// Call before any other tracking if the current user is a GuestUser
    private static func logAsGuestUser() {
        Analytics.setUserProperty(RegistrationStatus.guest, forName: RegistrationStatus.key)
    }
    
    /// Call before any other tracking if the current user is a Pro memeber
    private static func logAsProMember() {
        Analytics.setUserProperty(MembershipStatus.pro, forName: MembershipStatus.key)
    }
    
    /// Call before any other tracking if the current user is a Free memeber
    private static func logAsFreeMember() {
        Analytics.setUserProperty(MembershipStatus.free, forName: MembershipStatus.key)
    }
    
    /// Generates properties for tracking by inspecting a DisplayableError's properties
    private static func generateTrackingProperties(for error: DisplayableError) -> [String : String] {
        var properties: [String : String] = [:]
        
        // TODO: There is a 100char limit to this tracking...
//        properties[ErrorTrackingProperty.user_facing_title] = error.title
//        properties[ErrorTrackingProperty.user_facing_description] = error.message
//        properties[ErrorTrackingProperty.localized_description] = error.localizedDescription
        if let originalError = error.originalError {
            properties[ErrorTrackingProperty.originating_error] = originalError.localizedDescription
        }
        
        // TODO: There is a 100char limit to this tracking...
        if let nsError = error.originalError as NSError? {
            properties[ErrorTrackingProperty.nserror_code] = "\(nsError.code)"
            properties[ErrorTrackingProperty.nserror_domain] = "\(nsError.domain)"
//            properties[ErrorTrackingProperty.nserror_user_info] = nsError.userInfo.map { "[\($0.key) : \($0.value)]" }.joined(separator: ", ")
        }
        properties[ErrorTrackingProperty.ignorable] = error.isIgnored.description
        
        return properties
    }
    
    /// Generates properties for tracking by unwrapping an Error? and treating it as an NSError
    private static func generateTrackingProperties(for error: Error?) -> [String : String] {
        var properties: [String : String] = [:]
        if let e = error {
            properties[ErrorTrackingProperty.originating_error] = e.localizedDescription
            
            // TODO: There is a 100char limit to this tracking...
//            let nsError = e as NSError
//            properties[ErrorTrackingProperty.nserror_code] = "\(nsError.code)"
//            properties[ErrorTrackingProperty.nserror_domain] = "\(nsError.domain)"
//            properties[ErrorTrackingProperty.nserror_user_info] = nsError.userInfo.map { "[\($0.key) : \($0.value)]" }.joined(separator: ", ")
        }
        
        return properties
    }
}

// MARK: - Tracking Constants -

private struct RegistrationStatus {
    static let key = "registration_status"
    
    static let registered = "registered"
    static let guest = "guest"
}

private struct MembershipStatus {
    static let key = "membership_level"
    
    static let pro = "pro"
    static let free = "free"
}

private struct ErrorTrackingProperty {
    static let otherAPIError = "other_api_error"
    
    static let localized_description = "localized_description"
    static let user_facing_title = "user_facing_title"
    static let user_facing_description = "user_facing_description"
    static let originating_error = "original_error"
    static let ignorable = "was_silent"
    static let nserror_code = "ns_error_code"
    static let nserror_domain = "ns_error_domain"
    static let nserror_user_info = "ns_error_user_info"
    static let subtype = "subtype"
}

// MARK: - Event -

/// Simple struct to encapsulate data needed for tracking an event
struct Event: Trackable {
    let type: String
    let properties: [String : String]
    
    var name: String { return type }
}

// MARK: - Trackable Protocol -

protocol Trackable {
    
    var name: String { get }
    
}

