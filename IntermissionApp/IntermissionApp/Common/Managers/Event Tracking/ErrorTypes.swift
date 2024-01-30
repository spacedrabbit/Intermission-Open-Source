//
//  ErrorTracking.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation

// MARK: - Error Type Tracking -

// MARK: - Default Domain, Codes 0XX -
struct ErrorType: DomainDescriptable {
    static var domain: String { return "e_" }
    static var parent: DomainDescriptable.Type? { return nil }
    
    struct Default: DomainDescriptable {
        static var domain: String { return "default_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case unexpectedState,
            credentialManagerEmailFailed,
            credentialManagerPasswordFailed,
            credentialManagerSaveFailed,
            credentialManagerFacebookTokenFailed,
            credentialManagerClearSavedFailed
            
            static var parent: DomainDescriptable.Type? { return Default.self }
            
            var name: String {
                switch self {
                case .unexpectedState: return "unexpected_state"
                case .credentialManagerPasswordFailed: return "save_pass_fail"
                case .credentialManagerSaveFailed: return "save_creds_fail"
                case .credentialManagerEmailFailed: return "save_email_fail"
                case .credentialManagerFacebookTokenFailed: return "save_fb_token_fail"
                case .credentialManagerClearSavedFailed: return "clear_creds_fail"
                }
            }
            
            var errorCode: Int {
                switch self {
                case .unexpectedState: return 001
                case .credentialManagerPasswordFailed: return 002
                case .credentialManagerSaveFailed: return 003
                case .credentialManagerEmailFailed: return 004
                case .credentialManagerFacebookTokenFailed: return 004
                case .credentialManagerClearSavedFailed: return 005
                }
            }
        }
    }
    
}

// MARK: - Application State Errors, Codes 1XX -

extension ErrorType {
    
    struct App: DomainDescriptable {
        static var domain: String { return "app_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case requiredControllerMissing, audioInitializationFailed
            
            // Parent
            static var parent: DomainDescriptable.Type? { return App.self }
            
            // Name
            var name: String {
                switch self {
                case .requiredControllerMissing: return "req_vc_missing"
                case .audioInitializationFailed: return "audio_silent_fail"
                }
            }
        }
    }
    
}

// MARK: - Onboarding Specific Errors, Codes 2XX -

extension ErrorType {
    
    struct Onboarding: DomainDescriptable {
        static var domain: String { return "onboard_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case saveName
            
            // Parent
            static var parent: DomainDescriptable.Type? { return Onboarding.self }
            
            var name: String {
                switch self {
                case .saveName: return "save_name_fail"
                }
            }
            
            var displayName: String? {
                switch self {
                case .saveName: return "User Coordinator Did Not Guarantee Name Update Intent"
                }
            }
            
            var errorCode: Int {
                switch self {
                case .saveName: return 200
                }
            }
        }
    }
    
}

// MARK: - Contentful Errors, Codes 3XX -

extension ErrorType {
    
    struct Contentful: DomainDescriptable {
        static var domain: String { return "contentful_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case retrievalError
            
            static var parent: DomainDescriptable.Type? { return Contentful.self }
            
            var name: String{
                switch self {
                case .retrievalError: return "retrieval_error"
                }
            }
        }
    }
    
}

// MARK: - Database Errors, Codes 4XX -

extension ErrorType {
    
    struct Database: DomainDescriptable {
        static var domain: String { return "db_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case unknown, transferHistory
            
            static var parent: DomainDescriptable.Type? { return Database.self }
            
            var name: String {
                switch self {
                case .unknown: return "unknown_db_error"
                case .transferHistory: return "transfer_hist_fail"
                }
                
            }
        }
    }
    
}

// MARK: - Authentication Errors, Codes 5XX -

extension ErrorType {
    
    struct Auth: DomainDescriptable {
        static var domain: String { return "auth_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case authenticationFailed,
            loginEmailFailed,
            loginGuestFailed,
            loginFacebookFailed
            
            static var parent: DomainDescriptable.Type? { return Auth.self }
            
            var name: String {
                switch self {
                case .authenticationFailed: return "auth_fail"
                case .loginEmailFailed: return "login_email_fail"
                case .loginGuestFailed: return "login_guest_fail"
                case .loginFacebookFailed: return "login_fb_fail"
                }
            }
        }
    }
    
}

// MARK: - Registration Errors, Codes 6XX -

extension ErrorType {
    
    struct Register: DomainDescriptable {
        static var domain: String { return "register_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case userEmailRegistrationFailed,
            userFacebookRegistrationFailed,
            guestConvertToUserFailed
            
            static var parent: DomainDescriptable.Type? { return Register.self }
            
            var name: String {
                switch self {
                case .userEmailRegistrationFailed: return "email_reg_fail"
                case .userFacebookRegistrationFailed: return "fb_reg_fail"
                case .guestConvertToUserFailed: return "convert_user_fail"
                }
            }
        }
    }
    
}

// MARK: - Facebook Errors, Codes 7XX -

extension ErrorType {
    
    struct Facebook: DomainDescriptable {
        static var domain: String { return "fb_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case linkFacebookFailed, unlinkFacebookFailed
            
            static var parent: DomainDescriptable.Type? { return Facebook.self }
            var name: String {
                switch self {
                case .linkFacebookFailed: return "link_fb_fail"
                case .unlinkFacebookFailed: return "unlink_fb_fail"
                }
            }
        }
    }
    
}

// MARK: - Favoriting Errors, Codes 8XX -

extension ErrorType {
    
    struct Favorites: DomainDescriptable {
        static var domain: String { return "favs_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case addToFavoritesFailed,
            removeFromFavoritesFailed,
            favoritesRetrievalFailed,
            favoritesListenerFailed
            
            static var parent: DomainDescriptable.Type? { return Favorites.self }
            var name: String {
                switch self {
                case .addToFavoritesFailed: return "add_favs_fail"
                case .removeFromFavoritesFailed: return "remove_fav_fail"
                case .favoritesRetrievalFailed: return "favs_retrieval_fail"
                case .favoritesListenerFailed: return "favs_listener_fail"
                }
            }
        }
    }
    
}

// MARK: - Video Watch History Errors, Codes 9XX -

extension ErrorType {
    
    struct History: DomainDescriptable {
        static var domain: String { return "history_" }
        static var parent: DomainDescriptable.Type? { return ErrorType.self }
        
        enum Subtype: DomainTerminating {
            case addOrUpdateHistoryFailed, retrieveHistory
            
            static var parent: DomainDescriptable.Type? { return History.self }
            var name: String {
                switch self {
                case .addOrUpdateHistoryFailed: return "add_update_fail"
                case .retrieveHistory: return "retrieval_fail"
                }
            }
        }
    }
    
}

