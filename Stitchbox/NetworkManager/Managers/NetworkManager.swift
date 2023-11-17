//
//  NetworkManager.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation
import UIKit

// Define type aliases for different completion handlers.
typealias APICompletion = (Result) -> Void
typealias UploadInprogress = (Float) -> Void
typealias DataTaskResponse = (Data?, URLResponse?, Error?) -> Void

// Protocol defining the requirements for a request manager.
protocol RequestManager {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping APICompletion)
}

// Delegate class to handle URLSessionTask events, particularly for tracking upload progress.
class RequestDelegate: NSObject, URLSessionTaskDelegate {
    var process: UploadInprogress?

    // This method is called periodically during the data upload, allowing progress tracking.
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100
        process?(uploadProgress)
    }
}

// Generic class to manage network requests for a given endpoint type.
class Manager<EndPoint: EndPointType>: RequestManager {
    deinit {
        print("Manager is being deinitialized")
    }

    private var task: URLSessionDataTaskProtocol?
    private let session: URLSessionProtocol
    private let requestDelegate: RequestDelegate

    // Initialize with a custom or shared URLSession.
    init(session: URLSessionProtocol = URLSession.shared) {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        requestDelegate = RequestDelegate()
        requestDelegate.process = { percent in
            print(percent)
        }
        self.session = URLSession(configuration: configuration, delegate: requestDelegate, delegateQueue: nil)
    }

    // Several methods to upload different types of content (images, videos, etc.) using multipart/form-data.
    // Each method prepares the request and handles the response accordingly.

    // Upload a single image.
    func upload(_ route: EndPoint, image: UIImage, completion: @escaping APICompletion) {
        if var request = buildRequest(from: route) {
            let uploadData = builđData(for: image, request: &request)
            
            task = session.uploadTask(with: request, from: uploadData, completionHandler: { [weak self] data, response, error in
                guard let self = self else { return }
                if error != nil {
                    completion(.failure(ErrorType.noInternet))
                    return
                }
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(data, response)
                    completion(result)
                }
            })
            
            task?.resume()
        } else {
            completion(.failure(ErrorType.badRequest))
        }
    }


    // Upload multiple images with additional content.
    func upload(_ route: EndPoint, images: [UIImage], content: String, completion: @escaping APICompletion) {
        if var request = buildRequest(from: route) {
            let uploadData = buildData(for: images, for: content, request: &request)
            
            task = session.uploadTask(with: request, from: uploadData, completionHandler: { [weak self] data, response, error in
                guard let self = self else { return }
                if error != nil {
                    completion(.failure(ErrorType.noInternet))
                    return
                }
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(data, response)
                    completion(result)
                }
            })
            
            task?.resume()
        } else {
            completion(.failure(ErrorType.badRequest))
        }
    }


    // Upload a video with progress tracking.
    func upload(_ route: EndPoint, video: Data, completion: @escaping APICompletion, inprogress: @escaping UploadInprogress) {
        if var request = buildRequest(from: route) {
            let uploadData = builđData(for: video, request: &request)
            requestDelegate.process = inprogress
            
            task = session.uploadTask(with: request, from: uploadData, completionHandler: { [weak self] data, response, error in
                guard let self = self else { return }
                if error != nil {
                    completion(.failure(ErrorType.noInternet))
                    return
                }
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(data, response)
                    completion(result)
                }
            })
            
            task?.resume()
        } else {
            completion(.failure(ErrorType.badRequest))
        }
    }



    // Standard request method.
    func request(_ route: EndPoint, completion: @escaping APICompletion) {
        guard let request = buildRequest(from: route) else {
            completion(.failure(ErrorType.badRequest))
            return
        }

        self.task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(ErrorType.badRequest))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ErrorType.invalidResponse))
                return
            }
            
            let result = self.handleNetworkResponse(data, response)
            completion(result)
        })

        task?.resume()
    }


    // Helper methods to build and configure requests, handle network responses, etc.

    // Build multipart/form-data for image upload.
    fileprivate func builđData(for image: UIImage, request: inout URLRequest) -> Data {
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let filename = "image.png"
        var uploadData = Data()
        uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        uploadData.append(image.jpegData(compressionQuality: 0.5)!)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return uploadData
    }


    // Build multipart/form-data for video upload.
    fileprivate func builđData(for video: Data, request: inout URLRequest) -> Data {
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let filename = "video.mp4"
        var uploadData = Data()
        uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        uploadData.append(video)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return uploadData
    }


    // Build multipart/form-data for multiple images and additional content.
    fileprivate func buildData(for images: [UIImage], for content: String, request: inout URLRequest) -> Data {
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var uploadData = Data()

        // Append images to the upload data.
        for image in images {
            let filename = UUID().uuidString + ".png"
            uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"file[]\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            uploadData.append(image.jpegData(compressionQuality: 0.5)!)
        }

        // Append additional content to the upload data.
        uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"content\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: text/plain\r\n\r\n".data(using: .utf8)!)
        uploadData.append(content.data(using: .utf8)!)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return uploadData
    }


    // Build a URLRequest based on the provided endpoint.
    fileprivate func buildRequest(from route: EndPoint) -> URLRequest? {
        guard let url = URL(string: APIBuilder.baseURL + route.path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = route.httpMethod.rawValue

        switch route.task {
        case .request:
            // No additional configuration required.
            break
        case .requestParameters(let parameters):
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        case .requestParametersAndHeaders(let parameters, let headers):
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
            if let headers = headers {
                for (headerField, headerValue) in headers {
                    request.setValue(headerValue, forHTTPHeaderField: headerField)
                }
            }
        }

        // Add any additional headers that are always required.
        // For example, authentication tokens, content-type etc.
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.setValue("Bearer <token>", forHTTPHeaderField: "Authorization")

        return request
    }


    // Configure parameters for a URLRequest.
    fileprivate func configureParameters(parameters: [String: Any]?, request: inout URLRequest) {
        guard let parameters = parameters else { return }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error in JSON serialization of parameters")
        }
    }


    // Add additional headers to a URLRequest.
    fileprivate func addAdditionalHeaders(_ additionalHeaders: [String: String]?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }


    // Handle the network response and categorize it into success or failure.
    fileprivate func handleNetworkResponse(_ data: Data?, _ response: HTTPURLResponse) -> Result {
        switch response.statusCode {
        case 200...299: return .success(getAPIResponseFor(data, response))
        case 401...500: return .failure(ErrorType.authRequired(body: getAPIResponseFor(data, response).body))
        case 501...599: return .failure(ErrorType.badRequest)
        case 600: return .failure(ErrorType.outdatedRequest)
        default: return .failure(ErrorType.requestFailed(body: getAPIResponseFor(data, response).body))
        }
    }

    // Create an APIResponse object from Data and HTTPURLResponse.
    fileprivate func getAPIResponseFor(_ data: Data?, _ response: HTTPURLResponse) -> APIResponse {
        do {
            guard let responseData = data else {
                return APIResponse(body: nil, header: response.allHeaderFields as? [String: Any], statusCode: response.statusCode, errorMessage: ErrorMessage.kNoData)
            }
            let json = try JSONSerialization.jsonObject(with: responseData, options: [])
            return APIResponse(body: json as? [String: Any], header: response.allHeaderFields as? [String: Any], statusCode: response.statusCode, errorMessage: nil)
        } catch {
            return APIResponse(body: nil, header: response.allHeaderFields as? [String: Any], statusCode: response.statusCode, errorMessage: error.localizedDescription)
        }
    }


    // Create an APIResponse object with an error message.
    fileprivate func getAPIResponseWithErrorMessage(errorMessage: String) -> APIResponse {
        return APIResponse(body: nil, header: nil, statusCode: nil, errorMessage: errorMessage)
    }

    
}

