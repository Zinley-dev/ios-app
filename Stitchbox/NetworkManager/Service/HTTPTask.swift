//
//  HTTPTask.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

public enum HTTPTask {
    case request
    case requestParameters(parameters: [String: Any]?)
    case requestParametersAndHeaders(bodyParameters: [String: Any]?, additionHeaders: [String: String]?)
}

protocol URLSessionProtocol: AnyObject {
    typealias DataTaskResponse = (Data?, URLResponse?, Error?) -> Void
    func customDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol
    func customUploadTask(with request: URLRequest, from data: Data, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol
    func customInvalidateAndCancel()
    var delegate: URLSessionDelegate? { get set }
}

class CustomURLSession: URLSessionProtocol {
    static let shared = CustomURLSession()
        
    private let urlSession: URLSession
    weak var delegate: URLSessionDelegate?
        
    private init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    static func session(with configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) -> CustomURLSession {
        return CustomURLSession(urlSession: URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue))
    }
    
    func customDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol {
        let task = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            completionHandler(data, response, error)
        }
        return task as URLSessionDataTaskProtocol
    }
    
    func customUploadTask(with request: URLRequest, from data: Data, completionHandler: @escaping DataTaskResponse) -> URLSessionDataTaskProtocol {
        let task = urlSession.uploadTask(with: request, from: data) { [weak self] (data, response, error) in
            completionHandler(data, response, error)
        }
        return task as URLSessionDataTaskProtocol
    }
    
    func customInvalidateAndCancel() {
        urlSession.invalidateAndCancel()
    }
    
    deinit {
        customInvalidateAndCancel()
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

