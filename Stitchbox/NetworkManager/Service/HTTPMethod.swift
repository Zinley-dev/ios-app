//
//  HTTPMethod.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
}

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
