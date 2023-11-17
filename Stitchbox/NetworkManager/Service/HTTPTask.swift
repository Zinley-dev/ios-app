//
//  HTTPTask.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

/**
 Represents the type of HTTP task to be performed.

 - Cases:
   - request: A simple request without any parameters.
   - requestParameters(parameters:): A request with parameters.
   - requestParametersAndHeaders(bodyParameters:, additionHeaders:): A request with both body parameters and additional headers.

 - Remarks:
   This enumeration is used to specify the type of HTTP request that needs to be made. It can be expanded to include other types of HTTP tasks, such as multipart uploads, if needed.
*/
public enum HTTPTask {
    // A basic request without parameters.
    case request

    // A request with URL parameters.
    case requestParameters(parameters: [String: Any]?)

    // A request with both body parameters and additional headers.
    case requestParametersAndHeaders(bodyParameters: [String: Any]?, additionHeaders: [String: String]?)
}

/**
 A protocol defining the URLSession data task requirements.

 This protocol is used to abstract URLSession's data and upload tasks. It allows for better testability by enabling the mocking of network calls.

 - Method:
   - dataTask(with:completionHandler:): Creates a data task with the given URLRequest.
   - uploadTask(with:from:completionHandler:): Creates an upload task with the given URLRequest and data.
*/
protocol URLSessionProtocol {
    // Typealias for the completion handler to clarify the closure's signature.
    typealias DataTaskResponse = (Data?, URLResponse?, Error?) -> Void

    // Abstracts a data task for a given URLRequest.
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol

    // Abstracts an upload task for a given URLRequest and data.
    func uploadTask(with request: URLRequest, from data: Data, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol
}

/**
 Extension to conform URLSession to the URLSessionProtocol.

 This extension allows URLSession to be used wherever URLSessionProtocol is required, enhancing flexibility and testability.

 - Remark:
   The methods return URLSessionDataTaskProtocol to maintain conformity with the protocol. This is useful for testing and dependency injection.
*/
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }

    func uploadTask(with request: URLRequest, from data: Data, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol {
        return uploadTask(with: request, from: data, completionHandler: completionHandler) as URLSessionDataTask
    }
}

/**
 A protocol for URLSessionDataTask.

 This protocol is used to abstract URLSessionDataTask, primarily to facilitate testing by allowing mocks or stubs to replace actual data tasks.

 - Method:
   - resume(): Starts the task.
*/
protocol URLSessionDataTaskProtocol {
    // Abstracts the resume function to start the task.
    func resume()
}

/**
 Extension to conform URLSessionDataTask to URLSessionDataTaskProtocol.

 By conforming to URLSessionDataTaskProtocol, URLSessionDataTask can be used interchangeably with any URLSessionDataTaskProtocol implementation, which is particularly useful in testing scenarios.
*/
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
