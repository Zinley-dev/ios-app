//
//  APIResponse.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

/**
 A structure to represent the response from an API call.

 This struct encapsulates different parts of a typical HTTP response, including the body, headers, status code, and any error message. It's designed to provide a structured way to handle and process data received from API requests.

 - Properties:
   - body: A dictionary representing the body of the response. Typically contains the main content of the response.
   - header: A dictionary representing the response headers. Contains meta-information about the response.
   - statusCode: An integer representing the HTTP status code of the response. Useful for determining the result of the request (e.g., success, failure, etc.).
   - errorMessage: A string that contains an error message, if any error occurred during the API call.

 - Remarks:
   This structure can be extended or modified to fit the specific requirements of different API responses. For instance, you might want to include more detailed error information or additional fields present in the API response.
*/
struct APIResponse {
    // The body of the response, typically containing the main content.
    var body: [String: Any]?

    // Response headers, providing meta-information about the response.
    var header: [String: Any]?

    // The HTTP status code, indicating the result of the request.
    var statusCode: Int?

    // An error message, if an error occurred during the API call.
    var errorMessage: String?
}
