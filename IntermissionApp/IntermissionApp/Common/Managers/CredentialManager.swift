//
//  CredentialManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import KeychainAccess

class CredentialManager {
    private let keychain: Keychain
    
    private struct Keys {
        static let app = "com.ia.keys.app-identifier"
        static let email = "com.ia.keys.email"
        static let password = "com.ia.keys.password"
        static let facebook = "com.ia.keys.facebook-session"
    }
    
    public static let shared = CredentialManager()
    
    private init() {
        keychain = Keychain(service: Keys.app)
    }
    
    static func set(email: String) {
        do {
            try CredentialManager.shared.keychain
                .label("IA - Email")
                .comment("Intermission Sessions Email")
                .accessibility(.whenUnlocked)
                .set(email, key: Keys.email)
            
            print("Updated email saved to keychain")
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerEmailFailed)
            print("Error encountered saving Email/Password: \(error.localizedDescription)")
        }
    }
    
    static func set(password: String) {
        do {
            try CredentialManager.shared.keychain
                .label("IA - Pass")
                .comment("Intermission Session Pass")
                .accessibility(.whenUnlocked)
                .set(password, key: Keys.password)
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerPasswordFailed)
            print("Error encountered saving Email/Password: \(error.localizedDescription)")
        }
    }

    static func set(email: String, password: String, completion: ((IAResult<Bool, CredentialError>) -> Void)? = nil) {
        do {
            try CredentialManager.shared.keychain
                .label("IA - Email")
                .comment("Intermission Sessions Email")
                .accessibility(.whenUnlocked)
                .set(email, key: Keys.email)
            
            try CredentialManager.shared.keychain
                .label("IA - Pass")
                .comment("Intermission Session Pass")
                .accessibility(.whenUnlocked)
                .set(password, key: Keys.password)
            
            completion?(.success(true))
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerSaveFailed)
            completion?(.failure(.couldNotSaveCredentials))
        }
    }
    
    static func clearEmailProviderCredentials(completion: ((IAResult<Bool, CredentialError>) -> Void)? = nil) {
        do {
            try CredentialManager.shared.keychain.remove(Keys.email)
            try CredentialManager.shared.keychain.remove(Keys.password)
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerClearSavedFailed)
            print("Error encountered clearing EMAIL credentials: \(error.localizedDescription)")
            completion?(.failure(.couldNotClearCredentials))
        }
    }
    
    static func clearFacebookCredential(completion: ((IAResult<Bool, CredentialError>) -> Void)? = nil) {
        do {
            try CredentialManager.shared.keychain.remove(Keys.facebook)
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerClearSavedFailed)
            print("Error encountered clearing FACEBOOK credentials: \(error.localizedDescription)")
            completion?(.failure(.couldNotClearCredentials))
        }
    }
    
    static func clearCredentials(completion: ((IAResult<Bool, CredentialError>) -> Void)? = nil) {
        do {
            try CredentialManager.shared.keychain.removeAll()
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerClearSavedFailed)
            print("Error encountered clearing credentials: \(error.localizedDescription)")
            completion?(.failure(.couldNotClearCredentials))
        }
    }
    
    static func set(session: FacebookSession, completion: ((IAResult<Bool, CredentialError>) -> Void)? = nil) {
        do {
            try CredentialManager.shared.keychain
                .label("IA - Facebook Session")
                .comment("Intermission Session Facebook Token")
                .accessibility(.whenUnlocked)
                .set(session.token, key: Keys.facebook)
            
            completion?(.success(true))
        } catch (let error) {
            Track.track(error: error, domain: ErrorType.Default.Subtype.credentialManagerSaveFailed)
            print("Error encountered saving facebook session token: \(error.localizedDescription)")
            completion?(.failure(.couldNotSaveFacebookSession))
        }
    }
    
    static var email: String? {
        do { return try CredentialManager.shared.keychain.getString(Keys.email) }
        catch { print("Error ecountered retrieving email: \(error.localizedDescription)") }
        return nil
    }
    
    static var password: String? {
        do { return try CredentialManager.shared.keychain.getString(Keys.password) }
        catch { print("Error ecountered retrieving password: \(error.localizedDescription)") }
        return nil
    }
    
    static var facebookSessionToken: String? {
        do { return try CredentialManager.shared.keychain.getString(Keys.facebook) }
        catch { print("Error encountered retrieving Facebook password: \(error.localizedDescription)")}
        return nil
    }
    
}

extension Notification.Name {
    static let userCredentialsAvailable = Notification.Name("com.credentials.ia.user-credentials-available")
    static let facebookTokenAvailable = Notification.Name("com.credentials.ia.facebook-token-available")
}

struct CredentialsNotificationKey {
    static let email: String = "com.credentials.ia.email"
    static let password: String = "com.credentials.ia.password"
    static let facebookToken: String = "com.credentials.ia.facebook-token"
}
