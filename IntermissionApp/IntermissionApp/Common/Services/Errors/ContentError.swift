//
//  ContentError.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/19/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

/// Reference for Contentful.APIError. Prevents pod from leaking implementation out.
typealias ContentfulAPIError = Contentful.APIError

// TODO: look at "SDKError" from contentful to see if I want any specific messages logged
enum ContentError: ErrorDisplayable {
 
    case contentfulAPIError(ContentfulAPIError), unknown, noResults
    
    init(_ error: Error) {
        guard let contentError = error as? ContentfulAPIError else {
            self = .unknown
            return
        }
        
        self = .contentfulAPIError(contentError)
    }
    
    var displayError: DisplayableError {
        switch self {
        case .contentfulAPIError(let error):
            return DisplayableError(title: "We're sorry, something went wrong", message: error.message)
        case .noResults:
            return DisplayableError(title: "No results found", message: "We tried digging around, but we were still unable to find anything that matches what you were looking for. ")
        default: return DisplayableError()
        }
    }
}
