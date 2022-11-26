//
//  APIManager.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

public enum ErrorType: Error {
    case noInternet
    case authRequired
    case badRequest
    case outdatedRequest
    case requestFailed
    case invalidResponse
    case noData
}

enum Result {
    case success(APIResponse)
    case failure(ErrorType)
}

struct APIManager {
    let manager = Manager<UserApi>()
    
    func login(_ params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.login) { result in
            completion(result)
        }
    }

    func signUp(_ params: [String: Any], completion: @escaping APICompletion) {
//        print(params)
        manager.request(.signup(params: params)) { result in
            completion(result)
        }
    }
}
