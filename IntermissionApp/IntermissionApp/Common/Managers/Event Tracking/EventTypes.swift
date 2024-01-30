//
//  Events.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

struct EventType {
    struct Session {
        static let signedUp = "signed_up"
        static let loggedIn = "logged_in"
        static let loggedOut = "logged_out"
        static let guestConvertedToUser = "converted_to_user"
    }
    
    struct Dashboard {
        static let tappedEmptyDashCTA = "tapped_empty_dash_cta"
        static let viewedLastWatched = "viewed_last_watched"
        static let viewedHistory = "viewed_history"
        static let viewedSomethingNew = "viewed_something_new"
        static let viewedFavorites = "viewed_favorites"
    }
    
    struct Video {
        static let watchedVideo = "watched_video"
        static let favoritedVideo = "favorited_video"
        static let unfavoritedVideo = "unfavorited_video"
        static let filteredByTag = "filtered_by_tag"
        static let sharedVideo = "shared_video"
        static let viewedMoreByTag = "viewed_more_by_tag"
    }
    
    struct Store {
        static let viewedRetreat = "viewed_retreat"
    }
    
    struct Profile {
        static let uploadedProfilePicture = "uploaded_profile_picture"
        static let removedProfilePicture = "removed_profile_picture"
        static let tappedStats = "tapped_stats"
        static let viewedJourney = "viewed_journey"
        static let viewedStats = "viewed_stats"
    }
    
    struct Settings {
        static let changedEmail = "changed_email"
        static let changedPassword = "changed_password"
        static let resetPassword = "reset_password"
        static let changedName = "changed_name"
        static let connectedToFacebook = "connected_to_facebook"
        static let disconnectedFromFacebook = "disconnected_from_facebook"
        static let contactedSupport = "contacted_support"
    }
    
    struct Facebook {
        static let connectedToFacebook = Settings.connectedToFacebook
        static let disconnectedFromFacebook = Settings.disconnectedFromFacebook
    }
    
    struct Onboarding {
        static let startedOnboarding = "started_onboarding"
        static let finishedOnboarding = "finished_onboarding"
        static let uploadedProfilePicture = Profile.uploadedProfilePicture
        static let skippedProfilePicture = "skipped_profile_photo"
    }
}
