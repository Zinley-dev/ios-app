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
    
    func normalLogin(username: String, password: String, completion: @escaping APICompletion) {
        manager.request(.login(username: username, password: password)) { result in
            completion(result)
        }
    }
    
    func phoneLogin(phone: String, countryCode: String, via: String, completion: @escaping APICompletion) {
        manager.request(.phonelogin(phone: phone, countryCode: countryCode, via: via)) { result in
            completion(result)
        }
    }
    
    func phoneVerify(phone: String, countryCode: String, code: String, completion: @escaping APICompletion) {
        manager.request(.phoneverify(phone: phone, countryCode: countryCode, code: code)) { result in
            completion(result)
        }
    }
    
}

