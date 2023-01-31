//
//  NetworkManager.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation
import UIKit

typealias APICompletion = (Result) -> Void
typealias UploadInprogress = (Float) -> Void
typealias DataTaskResponse = (Data?, URLResponse?, Error?) -> Void

protocol RequestManager {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping APICompletion)
}
class RequestDelegate: NSObject, URLSessionTaskDelegate {
  var process: UploadInprogress
  override init() {
    self.process = { percent in
      print(percent)
    }
  }
  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100
    process(uploadProgress)
  }
}

class Manager<EndPoint: EndPointType>: RequestManager {
    private var task: URLSessionDataTaskProtocol?
    private let session: URLSessionProtocol
    private let requestDelegate: RequestDelegate
  
    init(session: URLSessionProtocol = URLSession.shared) {
      let configuration = URLSessionConfiguration.default
      configuration.waitsForConnectivity = true
      requestDelegate = RequestDelegate.init()
      self.session = URLSession(configuration: configuration, delegate: requestDelegate, delegateQueue: nil)
    }
  
  
  func upload(_ route: EndPoint, image: UIImage, completion: @escaping APICompletion) {
      if var request = buildRequest(from: route) {
        
        let uploadData = builđData(for: image, request: &request)
        
        
        task = session.uploadTask(with: request, from: uploadData, completionHandler: { data, response, error in
          if error != nil {
            completion(.failure(ErrorType.noInternet))
          }
          if let response = response as? HTTPURLResponse {
            let result = self.handleNetworkResponse(data, response)
            completion(result)
          }
        })
        self.task?.resume()
      }
    }
  
    func upload(_ route: EndPoint, video: Data, completion: @escaping APICompletion, inprogress: @escaping UploadInprogress) {
      if var request = buildRequest(from: route) {
          
          let uploadData = builđData(for: video, request: &request)
          requestDelegate.process = inprogress
          task = session.uploadTask(with: request, from: uploadData, completionHandler: { data, response, error in
            if error != nil {
              completion(.failure(ErrorType.noInternet))
            }
            if let response = response as? HTTPURLResponse {
              let result = self.handleNetworkResponse(data, response)
              completion(result)
            }
          })
          self.task?.resume()
      }
    }
    
    func request(_ route: EndPoint, completion: @escaping APICompletion) {
        if let request = buildRequest(from: route) {
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil {
                    completion(.failure(ErrorType.noInternet))
                }
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(data, response)
                    completion(result)
                }
            })
            self.task?.resume()
        }
    }
  
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
    
    fileprivate func builđData(for image: UIImage, for content: String, request: inout URLRequest) -> Data {
        let boundary = UUID().uuidString
      request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let filename = "image.png"
        var uploadData = Data()
        uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        uploadData.append(image.jpegData(compressionQuality: 0.5)!)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"content\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: text/plain\r\n\r\n".data(using: .utf8)!)
        uploadData.append(content.data(using: .utf8)!)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return uploadData
      }
    
    fileprivate func buildRequest(from route: EndPoint) -> URLRequest? {
        // Check API endpoint is valid
        guard let endpointUrl = URL(string: APIBuilder.baseURL + route.module + route.path) else {
            return nil
        }
        var request = URLRequest(url: endpointUrl,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 30.0)
        request.httpMethod = route.httpMethod.rawValue
        switch route.task {
          case .request:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if route.headers != nil {
              self.addAdditionalHeaders(route.headers, request: &request)
            }
          case .requestParameters(let parameters):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if route.headers != nil {
              self.addAdditionalHeaders(route.headers, request: &request)
            }
            self.configureParameters(parameters: parameters, request: &request)
          case .requestParametersAndHeaders(let parameters, let additionalHeaders):
            self.addAdditionalHeaders(additionalHeaders, request: &request)
            self.configureParameters(parameters: parameters, request: &request)
        }
        return request
    }
    fileprivate func configureParameters(parameters: [String: Any]?, request: inout URLRequest) {
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters ?? Data())
        request.httpBody = jsonData
    }
    fileprivate func addAdditionalHeaders(_ additionalHeaders: [String: String]?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    fileprivate func handleNetworkResponse(_ data: Data?, _ response: HTTPURLResponse) -> Result {
        switch response.statusCode {
        case 200...299: return .success(getAPIResponseFor(data, response))
        case 401...500: return .failure(ErrorType.authRequired(body: getAPIResponseFor(data, response).body))
        case 501...599: return .failure(ErrorType.badRequest)
        case 600: return .failure(ErrorType.outdatedRequest)
        default: return .failure(ErrorType.requestFailed(body: getAPIResponseFor(data, response).body))
        }
    }
    fileprivate func getAPIResponseFor(_ data: Data?, _ response: HTTPURLResponse) -> APIResponse {
        do {
            guard let responseData = data else {
                return getAPIResponseWithErrorMessage(errorMessage: ErrorMessage.kNoData)
            }
            guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                return getAPIResponseWithErrorMessage(errorMessage: ErrorMessage.kConversionFailed)
            }
            return APIResponse(body: json, header: nil, statusCode: response.statusCode, errorMessage: nil)
        } catch let error as NSError {
            return getAPIResponseWithErrorMessage(errorMessage: error.debugDescription)
        }
    }
    fileprivate func getAPIResponseWithErrorMessage(errorMessage: String) -> APIResponse {
        let apiResponse = APIResponse(body: nil, header: nil, statusCode: nil, errorMessage: errorMessage)
        return apiResponse
    }
    
}
