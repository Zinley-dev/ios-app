//
//  EndPointType.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

/**
 Defines the protocol for an API endpoint.

 This protocol encapsulates the necessary components to define an endpoint for a network request. It's used to structure and standardize the way endpoints are defined throughout an application's networking layer.

 - Properties:
   - path: A string representing the path component of the URL.
   - module: A string representing the module or base part of the URL.
   - httpMethod: The HTTP method (GET, POST, etc.) to be used for the request.
   - task: The type of HTTP task (e.g., request, requestParameters) to be performed.
   - headers: A dictionary of HTTP headers to be included in the request.

 - Remarks:
   Adopting this protocol in a struct or class allows for defining all the necessary details for an API endpoint in a structured way. This enhances readability, maintainability, and scalability of the network layer. Implementations can vary based on the specific needs of different API endpoints.
*/
protocol EndPointType {
    // The path component of the endpoint URL.
    var path: String { get }

    // The module or base part of the endpoint URL.
    var module: String { get }

    // The HTTP method to be used for the request.
    var httpMethod: HTTPMethod { get }

    // The type of HTTP task to be performed.
    var task: HTTPTask { get }

    // The HTTP headers to be included in the request.
    var headers: [String: String]? { get }
}

