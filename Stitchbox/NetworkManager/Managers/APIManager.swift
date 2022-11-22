//
//  APIManager.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

public enum ErrorType: Error {
    case noInternet
    case authRequired(body: [String: Any]?)
    case badRequest
    case outdatedRequest
    case requestFailed(body: [String: Any]?)
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
        let params = ["username": username,"password": password]
        manager.request(.login(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneLogin(phone: String, countryCode: String, completion: @escaping APICompletion) {
        let params = ["phone": phone, "countryCode": countryCode, "via": "sms"]
        print(params)
        manager.request(.phonelogin(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneVerify(phone: String, countryCode: String, code: String, completion: @escaping APICompletion) {
        let params = ["phone": phone, "countryCode": countryCode, "code": code]
        manager.request(.phoneverify(params: params)) { result in
            completion(result)
        }
    }
    
}

