//
//  PublicIP.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 31/03/2023.
//

import Foundation

// Define a type alias for the completion handler to simplify syntax.
typealias CompletionHandler = (String?, Error?) -> Void

/**
 Fetches the public IP address from a given URL.

 - Parameters:
   - requestURL: The URL to fetch the IP address from. Defaults to "https://icanhazip.com/".
   - completion: A closure called when the request is completed. It returns either the IP address as a String or an Error.

 - Remarks:
   The function uses a URLSession data task to make a network request. It handles various error states such as network errors, no data, or inability to decode the response. The result is sanitized by removing whitespace and newline characters.
*/
func getPublicIPAddress(requestURL: String = "https://icanhazip.com/", completion: @escaping CompletionHandler) {
    
    // Ensure the URL is valid.
    guard let url = URL(string: requestURL) else {
        fatalError("Invalid URL")
    }
    
    // Create a data task to fetch data from the URL.
    URLSession.shared.dataTask(with: url) { (data, _, error) in
        // Handle network errors.
        if let error = error {
            completion(nil, CustomError.error(error))
            return
        }

        // Check if the data is not nil.
        guard let data = data else {
            completion(nil, CustomError.noData)
            return
        }

        // Attempt to decode the data into a string.
        guard let result = String(data: data, encoding: .utf8) else {
            completion(nil, CustomError.undecodeable)
            return
        }

        // Sanitize the string by removing whitespace and newlines.
        let ipAddress = String(result.filter { !" \n\t\r".contains($0) })
        completion(ipAddress, nil)
    }.resume() // Start the network request.
}

// Custom error types to encapsulate different error scenarios.
enum CustomError: LocalizedError {
    case noData
    case error(Error)
    case undecodeable

    // Provide a user-friendly error description.
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No data response."
        case .error(let err):
            return err.localizedDescription
        case .undecodeable:
            return "Data undecodeable."
        }
    }
}
