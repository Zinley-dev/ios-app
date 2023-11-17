//
//  HTTPMethod.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

/**
 Enumerates the HTTP methods commonly used in network requests.

 This enumeration represents the various types of HTTP methods that can be used in network requests. Each case corresponds to a type of request method, represented as a string.

 - Cases:
   - get: Represents an HTTP GET request.
   - post: Represents an HTTP POST request.
   - put: Represents an HTTP PUT request.
   - delete: Represents an HTTP DELETE request.
   - patch: Represents an HTTP PATCH request.

 - Remarks:
   The raw value of each case is the corresponding HTTP method in uppercase (e.g., "GET", "POST"). This makes it convenient to use with URLRequest or similar network request frameworks.
*/
public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
}

/**
 Provides centralized storage for common error messages.

 This struct contains static constants that represent commonly encountered error messages in network operations. Centralizing error messages helps in maintaining consistency and ease of updates.

 - Properties:
   - Various static let constants representing different error messages.

 - Remarks:
   Each constant is a string describing a typical error scenario, such as invalid URL, conversion failures, or authentication errors. This approach helps to avoid repeating string literals throughout the code and eases localization or changes in the error messaging.
*/
struct ErrorMessage {
    static let kInvalidURL = "Invalid URL"
    static let kInvalidHeaderValue = "Header value is not string"
    static let kNoData = "No Data available"
    static let kConversionFailed = "Conversion Failed"
    static let kInvalidJSON = "Invalid JSON"
    static let kInvalidResponse = "Invalid Response"
    static let kAuthenticationError = "You need to be authenticated first."
    static let kBadRequest = "Bad request"
    static let kOutdatedRequest = "The url you requested is outdated."
    static let kRequestFailed = "Network request failed."
}

