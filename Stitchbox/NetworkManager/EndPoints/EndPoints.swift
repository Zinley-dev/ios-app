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
    case turnOn2fa(params: [String: Any])
    case turnOff2fa(params: [String: Any])
    case verify2fa(params: [String: Any])
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
          case .turnOn2fa:
            return "/two-factor/on"
          case .turnOff2fa:
            return "/two-factor/off"
          case .verify2fa:
            return "/two-factor/verify"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSettings:
            return .get
        case .updateSettings:
            return .patch
          case .turnOn2fa:
            return .patch
          case .turnOff2fa:
            return .patch
          case .verify2fa:
            return .patch
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getSettings:
            return .request
        case .updateSettings(let params):
            return .requestParameters(parameters: params)
          case .turnOn2fa(let params):
            return .requestParameters(parameters: params)
          case .turnOff2fa(let params):
            return .requestParameters(parameters: params)
          case .verify2fa(let params):
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
    case updateChallengeCard (params: [String: Any])
    case updatePhone (params: [String: Any])
    case verifyPhone (params: [String: Any])
    case updateEmail (params: [String: Any])
    case verifyEmail (params: [String: Any])
    case changepassword (params: [String: Any])
    case uploadavatar
    case uploadcover
    case usernameExist(params: [String: Any])
    case phoneExist(params: [String: Any])
    case emailExist(params: [String: Any])
    case addGameChallengeCard(params: [String: Any])
    case deleteGameChallengeCard(params: [String: Any])
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
          case .updateChallengeCard:
            return "/me/challenge-card"
        case .updateEmail:
          return "/email"
        case .updatePhone:
          return "/phone"
        case .verifyPhone:
          return "/phone-update-verify"
        case .verifyEmail:
          return "/email-update-verify"
        case .changepassword:
            return "/change-password"
        case .uploadcover:
            return "/upload-cover"
        case .uploadavatar:
            return "/upload-avatar"
        case .usernameExist:
          return "/username-exists"
        case .phoneExist:
          return "/phone-exists"
        case .emailExist:
          return "/email-exists"
          case .addGameChallengeCard:
            return "/challenge-card"
          case .deleteGameChallengeCard:
            return "/challenge-card"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getme:
            return .get
        case .updateme:
            return .patch
          case .updateChallengeCard:
            return .patch
          case .updatePhone:
            return .patch
          case .updateEmail:
            return .patch
          case .verifyEmail:
            return .patch
          case .verifyPhone:
            return .patch
        case .changepassword:
            return .post
        case .uploadcover:
            return .post
        case .uploadavatar:
            return .post
          case .usernameExist:
            return .post
          case .phoneExist:
            return .post
          case .emailExist:
            return .post
          case .addGameChallengeCard:
            return .post
          case .deleteGameChallengeCard:
            return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getme:
            return .request
        case .updateme(let params):
            return .requestParameters(parameters: params)
          case .updateChallengeCard(let params):
            return .requestParameters(parameters: params)
        case .updatePhone(let params):
            return .requestParameters(parameters: params)
        case .updateEmail(let params):
            return .requestParameters(parameters: params)
        case .verifyEmail(let params):
            return .requestParameters(parameters: params)
        case .verifyPhone(let params):
            return .requestParameters(parameters: params)
        case .changepassword(params: let params):
            return .requestParameters(parameters: params)
        case .uploadavatar:
            return .request
        case .uploadcover:
            return .request
          case .usernameExist(let params):
            return .requestParameters(parameters: params)
          case .phoneExist(let params):
            return .requestParameters(parameters: params)
          case .emailExist(let params):
            return .requestParameters(parameters: params)
          case .addGameChallengeCard(let params):
            return .requestParameters(parameters: params)
          case .deleteGameChallengeCard(let params):
            return .requestParameters(parameters: params)
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
    case update(params: [String: Any])
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
            case .update(let params):
                return "/\(params["id"] ?? "")"
            case .getMyPost(let page):
                return "/me?page=\(page)&limit=10"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .create:
                return .post
            case .update:
                return .post
            case .getMyPost:
              return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .create(let params):
                return .requestParameters(parameters: params)
            case .update(let params):
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
  case getFollows (userId: String, page: Int, lim: Int = 10)
  case getFollowers (userId: String, page: Int, lim: Int = 10)
  case searchFollower (params: [String:Any], page: Int, lim: Int = 10)
  case searchFollowing (params: [String:Any], page: Int, lim: Int = 10)
  case insertFollows (params: [String:Any])
  case deleteFollows (params: [String:Any])
}
extension FollowApi: EndPointType {
  var module: String {
    return "/follow"
  }
  
  var path: String {
    switch self {
      case .getFollows(let userId, let page, let lim):
        return "/\(userId)?page=\(page)&limit=\(lim)"
      case .insertFollows:
        return "/"
      case .deleteFollows:
        return "/unfollow"
      case .getFollowers(let userId, let page, let lim):
        return "/followers/\(userId)?page=\(page)&limit=\(lim)"
      case .searchFollower(let params, let page, let lim):
        return "/followers/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
      case .searchFollowing(let params, let page, let lim):
        return "/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
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
        case .searchFollower:
            return .get
        case .searchFollowing:
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
      case .searchFollower:
          return .request
      case .searchFollowing:
          return .request
    }
  }
  
  var headers: [String: String]? {
    return ["Authorization": _AppCoreData.userSession.value!.accessToken]
  }
}

public enum LikePostApi {
    case count (postId: String)
  case isLike (params: [String: Any])
  case like (params: [String: Any])
  case unlike (params: [String: Any])
}
extension LikePostApi: EndPointType {
  var module: String {
    return "/likepost"
  }
  
  var path: String {
    switch self {
      case .isLike(let params):
        return "/\(params["id"] ?? "")"
      case .like(let params):
        return "/\(params["id"] ?? "")"
      case .unlike(let params):
        return "/\(params["id"] ?? "")"
      case .count(let postId):
        return "/\(postId)/count"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .count:
        return .get
      case .isLike:
        return .get
      case .like:
        return .post
      case .unlike:
        return .delete
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .count:
        return .request
      case .isLike:
        return .request
      case .like:
        return .request
      case .unlike:
        return .request
    }
  }
  
  var headers: [String: String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
}
public enum FistBumpAPI {
    case getFistBumpee(userID: String, page: Int, limit: Int)
    case getFistBumper(userID: String, page: Int, limit: Int)
    case getFistBumperCount(userID: String)
    case getFistBumpeeCount(userID: String)
    case isFistBumper(userID: String)
    case isFistBumpee(userID: String)
    case addFistBump(userID: String)
    case deleteFistBump(userID: String)
    case getStat(userID: String)
}
extension FistBumpAPI: EndPointType {
    var module: String {
        return "/fistbump"
    }
    
    var path: String {
        switch self {
            
        case .getFistBumper(userID: let userID, page: let page, limit: let limit):
            return "/fistbumper/\(userID)?limit=\(limit)&page=\(page)"
        case .getFistBumpee(userID: let userID, page: let page, limit: let limit):
            return "/fistbumpee/\(userID)?limit=\(limit)&page=\(page)"
        case .getFistBumperCount(userID: let userID):
            return "/fistbumper/count/\(userID)"
        case .getFistBumpeeCount(userID: let userID):
            return "/fistbumpee/count/\(userID)"
        case .isFistBumper(userID: let userID):
            return "/isfistbumper/\(userID)"
        case .isFistBumpee(userID: let userID):
            return "/isfistbumpee/\(userID)"
        case .addFistBump(userID: let userID):
            return "/\(userID)"
        case .deleteFistBump(userID: let userID):
            return "/\(userID)"
        case .getStat(userID: let userID):
            return "/\(userID)/stat"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getFistBumpee:
            return .get
        case .getFistBumper:
            return .get
        case .getFistBumperCount:
            return .get
        case .getFistBumpeeCount:
            return .get
        case .isFistBumper:
            return .get
        case .isFistBumpee:
            return .get
        case .addFistBump:
            return .post
        case .deleteFistBump:
            return .delete
        case .getStat:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getFistBumpee(userID: _, page: _, limit: _):
            return .request
        case .getFistBumper(userID: _, page: _, limit: _):
            return .request
        case .getFistBumperCount(userID: _):
            return .request
        case .getFistBumpeeCount(userID: _):
            return .request
        case .isFistBumper(userID: _):
            return .request
        case .isFistBumpee(userID: _):
            return .request
        case .addFistBump(userID: _):
            return .request
        case .deleteFistBump(userID: _):
            return .request
          case .getStat:
            return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}
public enum CommentApi {
  case getComment(postId: String, page: Int, limit: Int)
  case count(postId: String)
  case create(params: [String: Any])
  case update(params: [String: Any])
  case delete(commentId: String)
  case like(commentId: String)
  case islike(commentId: String)
  case unlike(commentId: String)
  case countLike(commentId: String)
}
extension CommentApi: EndPointType {
  var path: String {
    switch self {
      case .getComment(let postId, let page, let limit):
        return "/\(postId)?page=\(page)&limit=\(limit)"
      case .count(let postId):
        return "/\(postId)/count"
      case .create:
        return "/"
      case .update(let params):
        return "/\(params["id"] ?? "")"
      case .delete(let commentId):
        return "/\(commentId)"
      case .like(let commentId):
        return "/\(commentId)/like"
      case .islike(let commentId):
        return "/\(commentId)/like"
      case .unlike(let commentId):
        return "/\(commentId)/like"
      case .countLike(let commentId):
        return "/\(commentId)/likes"
    }
  }
  
  var module: String {
    return "/comment"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getComment:
        return .get
      case .count:
        return .get
      case .create:
        return .post
      case .update:
        return .patch
      case .delete:
        return .delete
      case .like:
        return .post
      case .islike:
        return .get
      case .unlike:
        return .delete
      case .countLike:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getComment:
        return .request
      case .count:
        return .request
      case .create(let params):
        return .requestParameters(parameters: params)
      case .update(let params):
        return .requestParameters(parameters: params)
      case .delete:
        return .request
      case .like:
        return .request
      case .islike:
        return .request
      case .unlike:
        return .request
      case .countLike:
        return .request
    }
  }
  
  var headers: [String: String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
  
}
