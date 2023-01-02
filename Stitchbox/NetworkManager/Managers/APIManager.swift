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
        print("params \(params)")
        manager.request(.login(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneLogin(phone: String, completion: @escaping APICompletion) {
        let params = ["phone": phone]
        print(params)
        manager.request(.phonelogin(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneVerify(phone: String, OTP: String, completion: @escaping APICompletion) {
        let params = ["phone": phone, "OTP": OTP]
        manager.request(.phoneverify(params: params)) { result in
            completion(result)
        }
    }
    
    func resetpassword(params: [String: String], completion: @escaping APICompletion) {
        manager.request(.resetpassword(params: params)){
            result in
            completion(result)
        }
    }
}

struct SettingAPIManager{
    let manager = Manager<SettingAPI>()
    
    func getSettings(completion: @escaping APICompletion) {
        manager.request(.getSettings){
            result in
            completion(result)
        }
    }
    
    func updateSettings(params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.updateSettings(params: params)){
            result in
            completion(result)
        }
    }

    
}
struct UserInfoAPIManager{
    let manager = Manager<UserInfoAPI>()
    
    func getme(completion: @escaping APICompletion) {
        manager.request(.getme){
            result in
            completion(result)
        }
    }
    
    func updateme(params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.updateme(params: params)){
            result in
            completion(result)
        }
    }
    
    func changepassword(params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.changepassword(params: params)){
            result in
            completion(result)
        }
    }
    
    func uploadcover(params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.uploadcover(params: params)){
            result in
            completion(result)
        }
    }
    
    func uploadavatar(params: [String: Any], completion: @escaping APICompletion) {
        manager.request(.uploadavatar(params: params)){
            result in
            completion(result)
        }
    }
    
}
