//
//  APIManager.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation
import UIKit

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
    let authManager = Manager<AuthApi>()
    let SBmanager = Manager<ChatApi>()
    let searchManager = Manager<SearchApi>()
    let mediaManager = Manager<MediaAPI>()
    let followManager = Manager<FollowApi>()
    let settingManager = Manager<SettingAPI>()
    let accountManager = Manager<AccountAPI>()
    let userManager = Manager<UserAPI>()
    let contactManager = Manager<ContactAPI>()
    let postManager = Manager<PostAPI>()
    
    func normalLogin(username: String, password: String, completion: @escaping APICompletion) {
        let params = ["username": username,"password": password]
        authManager.request(.login(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneLogin(phone: String, completion: @escaping APICompletion) {
        let params = ["phone": phone]
        authManager.request(.phonelogin(params: params)) { result in
            completion(result)
        }
    }
    
    func socialLogin(params: [String: String], completion: @escaping APICompletion) {
        authManager.request(.socialLogin(params: params)) { result in
            completion(result)
        }
    }
    
    func socialRegister(params: [String: String], completion: @escaping APICompletion) {
        authManager.request(.socialRegister(params: params)) { result in
            completion(result)
        }
    }
    
    func phoneVerify(phone: String, OTP: String, completion: @escaping APICompletion) {
        let params = ["phone": phone, "OTP": OTP]
        authManager.request(.phoneverify(params: params)) { result in
            completion(result)
        }
    }
    
    func register(params: [String: String], completion: @escaping APICompletion) {
        authManager.request(.register(params: params)) { result in
            completion(result)
        }
    }
    
    func roomIDRequest(channelUrl: String, completion: @escaping APICompletion) {
        
        let params = ["channel": channelUrl]
        SBmanager.request(.roomIDRequest(params: params)) { result in
            completion(result)
        }
        
        
    }
    
    func acceptSBInvitationRequest(user_id: String, channelUrl: String, completion: @escaping APICompletion) {
        
        let params = ["channel": channelUrl, "user_id": user_id]
        SBmanager.request(.acceptSBInvitationRequest(params: params)) { result in
            completion(result)
        }
        
        
    }
    
    
    func channelCheckForInviation(userIds: [String], channelUrl: String, completion: @escaping APICompletion) {
        
        let params = ["channel": channelUrl, "userIds": userIds] as [String : Any]
        SBmanager.request(.channelCheckForInviation(params: params)) { result in
            completion(result)
        }
        
        
    }
    
    func searchUsersForChat(keyword: String, completion: @escaping APICompletion) {
        
        let params = ["search": keyword]
        searchManager.request(.searchUsersForChat(params: params)) { result in
            completion(result)
        }
        
    }
  
  func uploadImage(image: UIImage, completion: @escaping APICompletion) {
      mediaManager.upload(.uploadImage, image: image) { result in
        completion(result)
      }
    }
  
    func uploadVideo(video: Data, completion: @escaping APICompletion, process: @escaping UploadInprogress) {
      mediaManager.upload(.uploadVideo, video: video) { result in
        completion(result)
      } inprogress: { percent in
        process(percent)
      }

    }
    
    func forgotPasswordByEmail(params: [String: String], completion: @escaping APICompletion) {
        authManager.request(.forgotPasswordByEmail(params: params)) { result in
            completion(result)
        }
    }
    
    func forgotPasswordByPhone(params: [String: String], completion: @escaping APICompletion) {
        authManager.request(.forgotPasswordByPhone(params: params)) { result in
            completion(result)
        }
    }
}

extension APIManager {
    
    func getSettings(completion: @escaping APICompletion) {
        settingManager.request(.getSettings){
            result in
            completion(result)
        }
    }
    
    func updateSettings(params: [String: Any], completion: @escaping APICompletion) {
        settingManager.request(.updateSettings(params: params)){
            result in
            completion(result)
        }
    }
    func getBlocks(page: Int, completion: @escaping APICompletion) {
        accountManager.request(.getBlocks(page: page)){
            result in
            completion(result)
        }
    }
    func insertBlocks(params: [String: Any], completion: @escaping APICompletion) {
        accountManager.request(.insertBlocks(params: params)){
            result in
            completion(result)
        }
    }
    func deleteBlocks(params: [String: Any], completion: @escaping APICompletion) {
        accountManager.request(.deleteBlocks(params: params)){
            result in
            completion(result)
        }
    }
    func getFollows(page: Int, completion: @escaping APICompletion) {
        followManager.request(.getFollows(page: page)){
            result in
            completion(result)
        }
    }
    func getFollowers(page: Int, completion: @escaping APICompletion) {
        followManager.request(.getFollowers(page: page)){
            result in
            completion(result)
        }
    }
    func insertFollows(params: [String: Any], completion: @escaping APICompletion) {
        followManager.request(.insertFollows(params: params)){
            result in
            completion(result)
        }
        print("call insertAPI")
    }
    func deleteFollows(params: [String: Any], completion: @escaping APICompletion) {
        followManager.request(.deleteFollows(params: params)){
            result in
            completion(result)
        }
    }
    func getme(completion: @escaping APICompletion) {
        userManager.request(.getme){
            result in
            completion(result)
        }
    }
    
    func updateme(params: [String: Any], completion: @escaping APICompletion) {
        userManager.request(.updateme(params: params)){
            result in
            completion(result)
        }
    }
    
    func changepassword(params: [String: Any], completion: @escaping APICompletion) {
        userManager.request(.changepassword(params: params)){
            result in
            completion(result)
        }
    }
    
    func uploadcover(image: UIImage, completion: @escaping APICompletion) {
        userManager.upload(.uploadcover, image: image) {
            result in
            completion(result)
        }
    }
    
    func uploadavatar(image: UIImage, completion: @escaping APICompletion) {
        userManager.upload(.uploadavatar, image: image){
            result in
            completion(result)
        }
    }
    func uploadContact(image: UIImage, content: String, completion: @escaping APICompletion) {
        // TODO: miss content
        contactManager.upload(.postContact, image: image){
            result in
            completion(result)
        }
        
    }
}


extension APIManager {
    
    func createPost(params: [String: Any], completion: @escaping APICompletion) {
        postManager.request(.create(params: params)) { result in
            completion(result)
        }
    }
    func getMyPost(page: Int, completion: @escaping APICompletion) {
      postManager.request(.getMyPost(page: page)) { result in
        completion(result)
      }
    }
    
}
