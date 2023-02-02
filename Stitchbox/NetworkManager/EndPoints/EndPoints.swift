//
//  EndPoints.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation
import UIKit

protocol BaseURL {
    static var baseURL: String { get }
}

enum APIBuilder {
    struct APIBuilderConstants {
        static let ApiScheme = "https"
        static let ApiHost = "api.stitchbox.dev/v1"
    }
}

extension APIBuilder: BaseURL {
    static var baseURL: String {
        return "\(APIBuilder.APIBuilderConstants.ApiScheme)://\(APIBuilder.APIBuilderConstants.ApiHost)"
    }
}

public enum AuthApi {
    case login (params: [String:String])
    case phonelogin (params: [String:String])
    case phoneverify (params: [String:String])
    case register (params: [String:String])
    case socialLogin (params: [String:String])
    case socialRegister (params: [String:String])
    case forgotPasswordByEmail (params: [String:String])
    case forgotPasswordByPhone (params: [String:String])
}
extension AuthApi: EndPointType {
    var module: String {
        return "/auth"
    }
    
    var path: String {
      switch self {
        case .login:
          return "/login"
        case .phonelogin:
          return "/phone-login"
        case .phoneverify:
          return "/phone-verify"
        case .register:
          return "/register"
        case .socialLogin:
          return "/social-login"
        case .socialRegister:
          return "/social-register"
        case .forgotPasswordByEmail:
          return "/forgot-password"
        case .forgotPasswordByPhone:
          return "/forgot-password-by-phone"
      }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .phonelogin:
            return .post
        case .phoneverify:
            return .post
        case .register:
            return .post
        case .socialLogin:
            return .post
        case .socialRegister:
            return .post
        case .forgotPasswordByPhone:
            return .post
        case .forgotPasswordByEmail:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let params):
            return .requestParameters(parameters: params)
        case .phonelogin(let params):
            return .requestParameters(parameters: params)
        case .phoneverify(let params):
            return .requestParameters(parameters: params)
        case .register(let params):
            return .requestParameters(parameters: params)
        case .socialLogin(let params):
            return .requestParameters(parameters: params)
        case .socialRegister(let params):
            return .requestParameters(parameters: params)
        case .forgotPasswordByPhone(let params):
            return .requestParameters(parameters: params)
        case .forgotPasswordByEmail(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}

public enum ChatApi {
    case roomIDRequest (params: [String:String])
    case acceptSBInvitationRequest (params: [String:String])
    case channelCheckForInviation (params: [String:Any])
}

extension ChatApi: EndPointType {

    var module: String {
        return "/chat"
    }
    
    var path: String {
        switch self {
        case .roomIDRequest:
            return "/call"
        case .acceptSBInvitationRequest:
            return "/channel/invite/accept"
        case .channelCheckForInviation:
            return "/channel"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .roomIDRequest:
            return .post
        case .acceptSBInvitationRequest:
            return .post
        case .channelCheckForInviation:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .roomIDRequest(let params):
            return .requestParameters(parameters: params)
        case .acceptSBInvitationRequest(let params):
            return .requestParameters(parameters: params)
        case .channelCheckForInviation(let params):
            return .requestParameters(parameters: params)
        }
        
    }
    
    var headers: [String: String]? {
          if let userToken = _AppCoreData.userSession.value?.accessToken, userToken != "" {
            let headers = ["Authorization": userToken]
            return headers
          }
          return nil
    }
    
}


public enum SearchApi {
    case searchUsersForChat(params: [String:String])
   
}

extension SearchApi: EndPointType {

    var module: String {
        return "/user"
    }
    
    var path: String {
        switch self {
        case .searchUsersForChat(let params):
            return "/search?search=\(params["search"] ?? "")"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .searchUsersForChat:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .searchUsersForChat:
            return .request
        }
        
    }
    
    var headers: [String: String]? {
          if let userToken = _AppCoreData.userSession.value?.accessToken, userToken != "" {
            let headers = ["Authorization": userToken]
            return headers
          }
          return nil
    }
    
}

public enum SettingAPI {
    case getSettings
    case updateSettings (params: [String: Any])
}
extension SettingAPI: EndPointType {
    var module: String {
        return "/settings"
    }
    
    var path: String {
        switch self {
        case .getSettings:
            return "/"
        case .updateSettings:
            return "/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSettings:
            return .get
        case .updateSettings:
            return .patch
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getSettings:
            return .request
        case .updateSettings(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
    }
}

public enum MediaAPI {
  case uploadImage
  case uploadVideo
}
extension MediaAPI: EndPointType {
  var httpMethod: HTTPMethod {
    switch self {
      case .uploadVideo:
        return .post
      case .uploadImage:
        return .post
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .uploadImage:
        return .request
      case .uploadVideo:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value!.accessToken]
  }
  
  var module: String {
    return "/media"
  }
  var path: String {
    switch self {
      case .uploadImage:
        return "/upload-image"
      case .uploadVideo:
        return "/upload-video"
    }
  }
}
public enum AccountAPI {
    case getBlocks (page: Int, limit: Int = 10)
    case insertBlocks (params: [String:Any])
    case deleteBlocks (params: [String:Any])
}
extension AccountAPI: EndPointType {
    var module: String {
        return "/account"
    }
    
    var path: String {
      switch self {
        case .getBlocks(let page, let lim):
          return "/block?page=\(page)&limit=\(lim)"
        case .insertBlocks:
          return "/block"
        case .deleteBlocks:
          return "/block"
      }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBlocks:
            return .get
        case .insertBlocks:
            return .post
        case .deleteBlocks:
            return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getBlocks:
            return .request
        case .insertBlocks(let params):
            return .requestParameters(parameters: params)
        case .deleteBlocks(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}

public enum UserAPI {
    case getme
    case updateme (params: [String: Any])
    case changepassword (params: [String: Any])
    case uploadavatar
    case uploadcover
}
extension UserAPI: EndPointType {
    var module: String {
        return "/user"
    }
    
    var path: String {
        switch self {
        case .getme:
            return "/me"
        case .updateme:
            return "/me"
        case .changepassword:
            return "/change-password"
        case .uploadcover:
            return "/upload-cover"
        case .uploadavatar:
            return "/upload-avatar"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getme:
            return .get
        case .updateme:
            return .patch
        case .changepassword:
            return .post
        case .uploadcover:
            return .post
        case .uploadavatar:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getme:
            return .request
        case .updateme(let params):
            return .requestParameters(parameters: params)
        case .changepassword(params: let params):
            return .requestParameters(parameters: params)
        case .uploadavatar:
            return .request
        case .uploadcover:
            return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}

public enum ContactAPI {
    case postContact
}
extension ContactAPI: EndPointType {
    var module: String {
        return "/contact"
    }
    
    var path: String {
      switch self {
      case .postContact:
          return "/"
      }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .postContact:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .postContact:
            return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}

public enum PostAPI {
    case create(params: [String: Any])
    case getMyPost(page: Int)
}
extension PostAPI: EndPointType {
    var module: String {
        return "/post"
    }
    
    var path: String {
        switch self {
            case .create:
                return "/"
            case .getMyPost(let page):
                return "/me?page=\(page)&limit=10"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .create:
                return .post
            case .getMyPost:
              return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .create(let params):
                return .requestParameters(parameters: params)
            case .getMyPost:
                return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}

public enum FollowApi {
  case getFollows (page: Int, lim: Int = 10)
  case getFollowers (page: Int, lim: Int = 10)
  case insertFollows (params: [String:Any])
  case deleteFollows (params: [String:Any])
}
extension FollowApi: EndPointType {
  var module: String {
    return "/follow"
  }
  
  var path: String {
    switch self {
      case .getFollows(let page, let lim):
        return "?page=\(page)&limit=\(lim)"
      case .insertFollows:
        return "/"
      case .deleteFollows:
        return "/unfollow"
      case .getFollowers(let page, let lim):
        return "/followers?page=\(page)&limit=\(lim)"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getFollows:
        return .get
      case .insertFollows:
        return .post
      case .deleteFollows:
        return .delete
      case .getFollowers:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getFollows:
        return .request
      case .insertFollows(let params):
        return .requestParameters(parameters: params)
      case .deleteFollows(let params):
        return .requestParameters(parameters: params)
      case .getFollowers:
        return .request
    }
  }
  
  var headers: [String: String]? {
    return ["Authorization": _AppCoreData.userSession.value!.accessToken]
  }
}
