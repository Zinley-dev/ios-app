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
        static let ApiHost = "api.stitchbox.live/v1"
//        static let ApiScheme = "http"
//        static let ApiHost = "localhost:9090/v1"
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
    case emailverify (params: [String:String])
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
        case .emailverify:
          return "/email-verify"
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
        case .emailverify:
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
        case .emailverify(let params):
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
  case savePost (params: [String: Any])
  case unsavePost (params: [String: Any])
  case getSavedPost (page: Int)
    case deleteMe
    case undoDelete
    case getUserInfo(userId: String)
    case updateme (params: [String: Any])
    case updateChallengeCard (params: [String: Any])
    case updatePhone (params: [String: Any])
    case verifyPhone (params: [String: Any])
    case updateEmail (params: [String: Any])
    case verifyEmail (params: [String: Any])
    case changepassword (params: [String: Any])
    case updatepassword (params: [String: Any])
    case uploadavatar
    case uploadcover
    case riotUpdate(params: [String: Any])
    case riotLatestUpdate
    case usernameExist(params: [String: Any])
    case phoneExist(params: [String: Any])
    case emailExist(params: [String: Any])
    case addGameChallengeCard(params: [String: Any])
    case updateGameChallengeCard(params: [String: Any])
    case updateFavoriteContent(params: [String: Any] )
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
        case .savePost:
          return "/me/saved-post"
        case .unsavePost:
          return "/me/saved-post"
          case .getSavedPost(let page):
          return "/me/saved-post?page=\(page)"
        case .getUserInfo(let userId):
            return "/\(userId)"
          case .deleteMe:
            return "/"
        case .undoDelete:
            return "/undo"
        case .updateme:
            return "/me"
          case .updateChallengeCard:
            return "/me/challenge-card"
          case .updateFavoriteContent:
            return "/me/favorite-content"
        case .updateEmail:
          return "/email"
          case .riotUpdate:
            return "/riot-update"
          case .riotLatestUpdate:
            return "/riot-latest-update"
        case .updatePhone:
          return "/phone"
        case .verifyPhone:
          return "/phone-update-verify"
        case .verifyEmail:
          return "/email-update-verify"
        case .changepassword:
            return "/change-password"
        case .updatepassword:
            return "/update-password"
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
          case .updateGameChallengeCard:
            return "/challenge-card"
          case .deleteGameChallengeCard:
            return "/challenge-card"
          case .updateFavoriteContent:
            return "/me/favorite-content"
            
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getme:
            return .get
          case .savePost:
            return .post
          case .unsavePost:
            return .delete
          case .getSavedPost:
            return .get
          case .getUserInfo:
            return .get
          case .deleteMe:
            return .delete
            case .undoDelete:
                return .post
        case .updateme:
            return .patch
          case .updateChallengeCard:
            return .patch
          case .updateFavoriteContent:
            return .patch
          case .updatePhone:
            return .patch
          case .updateEmail:
            return .patch
          case .riotUpdate:
            return .patch
          case .riotLatestUpdate:
            return .patch
          case .verifyEmail:
            return .patch
          case .verifyPhone:
            return .patch
        case .changepassword:
            return .post
          case .updatepassword:
            return .put
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
          case .updateGameChallengeCard:
            return .put
          case .deleteGameChallengeCard:
            return .delete
          case .updateFavoriteContent:
            return .patch
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getme:
            return .request
          case .savePost(let params):
            return .requestParameters(parameters: params)
          case .unsavePost(let params):
            return .requestParameters(parameters: params)
          case .getSavedPost:
            return .request
          case .deleteMe:
            return .request
            case .undoDelete:
                return .request
          case .getUserInfo:
            return .request
        case .updateme(let params):
            return .requestParameters(parameters: params)
          case .updateChallengeCard(let params):
            return .requestParameters(parameters: params)
          case .updateFavoriteContent(let params):
            return .requestParameters(parameters: params)
        case .updatePhone(let params):
            return .requestParameters(parameters: params)
          case .riotUpdate(let params):
            return .requestParameters(parameters: params)
          case .riotLatestUpdate:
            return .request
        case .updateEmail(let params):
            return .requestParameters(parameters: params)
        case .verifyEmail(let params):
            return .requestParameters(parameters: params)
        case .verifyPhone(let params):
            return .requestParameters(parameters: params)
        case .changepassword(params: let params):
            return .requestParameters(parameters: params)
          case .updatepassword(params: let params):
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
          case .updateFavoriteContent(let params):
            return .requestParameters(parameters: params)
          case .updateGameChallengeCard(let params):
            return .requestParameters(parameters: params)
          case .deleteGameChallengeCard(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
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
    case getPost(pid: String)
    case countSavedPost (pid: String)
    case checkSavedPost (pid: String)
    case getRecommend
    case getUserFeed(limit: Int)
    case getHighTrending
    case getPostTrending(page: Int)
    case getTagTrending(page: Int)
    case create(params: [String: Any])
    case update(params: [String: Any])
    case getMyPost(page: Int)
    case getHashtagPost(tag: String, page: Int)
    case getUserPost(user: String, page: Int)
    case lastSetting
    case deleteMyPost(pid: String)
    case stats(pid: String)
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
          case .countSavedPost (let pid):
            return "/count-saved/\(pid)"
          case .checkSavedPost (let pid):
            return "/count-saved/\(pid)/check"
          case .getMyPost(let page):
              return "/me?page=\(page)&limit=10"
          case .getHashtagPost(let tag, let page):
              return "/hashtag/\(tag)?page=\(page)&limit=10"
          case .lastSetting:
            return "/last-setting"
          case .getRecommend:
            return "/"
          case .getPost(let pid):
            return "/\(pid)"
          case .getUserFeed(let limit):
            return "/feed?limit=\(limit)"
          case .getHighTrending:
            return "/high-trending"
          case .getPostTrending(let page):
            return "/trending?page=\(page)&limit=10"
          case .getTagTrending(let page):
            return "/trending/hashtag?page=\(page)&limit=10"
            case .getUserPost(let user, let page):
                return "/author/\(user)?page=\(page)&limit=10"
          case .deleteMyPost(let pid):
            return "/\(pid)"
          case .stats(let pid):
            return "/stats/\(pid)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .create:
                return .post
            case .update:
                return .put
            case .getMyPost:
              return .get
            case .getHashtagPost:
                return .get
          case .lastSetting:
              return .get
          case .getRecommend:
            return .get
          case .getUserFeed:
            return .get
          case .getHighTrending:
            return .get
          case .getPost:
            return .get
            case .getUserPost:
                return .get
          case .deleteMyPost:
            return .delete
          case .stats:
            return .get
          case .getPostTrending:
            return .get
          case .getTagTrending:
            return .get
          case .countSavedPost:
            return .get
          case .checkSavedPost:
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
            case .getHashtagPost:
                return .request
          case .lastSetting:
              return .request
          case .getRecommend:
            return .request
          case .getUserFeed:
            return .request
          case .getHighTrending:
            return .request
          case .getPost:
            return .request
            case .getUserPost:
                return .request
          case .deleteMyPost:
            return .request
          case .stats:
            return .request
          case .getPostTrending:
            return .request
          case .getTagTrending:
            return .request
          case .countSavedPost:
            return .request
          case .checkSavedPost:
            return .request
        }
    }
    
    var headers: [String: String]? {
        if _AppCoreData.userSession.value != nil {
            return ["Authorization": _AppCoreData.userSession.value!.accessToken]
        } else {
            return ["Authorization": "null"]
        }
    }
}

public enum FollowApi {
  case getFollows (userId: String, page: Int, lim: Int = 10)
  case getFollowers (userId: String, page: Int, lim: Int = 10)
  case searchFollower (params: [String:Any], page: Int, lim: Int = 10)
  case searchFollowing (params: [String:Any], page: Int, lim: Int = 10)
  case insertFollows (params: [String:Any])
  case deleteFollows (params: [String:Any])
  case deleteFollower (params: [String:Any])
  case isFollower (userId: String)
  case isFollowing (userId: String)
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
      case .deleteFollower:
        return "/cancel-follow"
      case .getFollowers(let userId, let page, let lim):
        return "/followers/\(userId)?page=\(page)&limit=\(lim)"
      case .searchFollower(let params, let page, let lim):
        return "/followers/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
      case .searchFollowing(let params, let page, let lim):
        return "/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
        case .isFollower(let userId):
            return "/isfollowed/\(userId)"
        case .isFollowing(let userId):
            return "/isfollowing/\(userId)"
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
      case .deleteFollower:
        return .delete
      case .getFollowers:
        return .get
        case .searchFollower:
            return .get
        case .searchFollowing:
            return .get
        case .isFollower:
            return .get
        case .isFollowing:
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
      case .deleteFollower(let params):
        return .requestParameters(parameters: params)
      case .getFollowers:
        return .request
      case .searchFollower:
          return .request
      case .searchFollowing:
          return .request
        case .isFollower:
            return .request
        case .isFollowing:
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
    case searchFistBumpee (params: [String:Any], page: Int, lim: Int = 10)
    case searchFistBumper (params: [String:Any], page: Int, lim: Int = 10)
    case getFistBumperCount(userID: String)
    case getFistBumpeeCount(userID: String)
    case isFistBumper(userID: String)
    case isFistBumpee(userID: String)
    case addFistBump(userID: String)
    case deleteFistBump(userID: String)
    case getInsight(userID: String)
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
        case .searchFistBumpee(let params, let page, let lim):
          return "/fistbumpee/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
        case .searchFistBumper(let params, let page, let lim):
          return "/fistbumper/search/\(params["userid"] ?? "")?search=\(params["query"] ?? "")&page=\(page)&limit=\(lim)"
        case .isFistBumper(userID: let userID):
            return "/isfistbumper/\(userID)"
        case .isFistBumpee(userID: let userID):
            return "/isfistbumpee/\(userID)"
        case .addFistBump(userID: let userID):
            return "/\(userID)"
        case .deleteFistBump(userID: let userID):
            return "/\(userID)"
        case .getInsight(userID: let userID):
            return "/\(userID)/insight"
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
        case .searchFistBumpee:
          return .get
        case .searchFistBumper:
          return .get
        case .isFistBumper:
            return .get
        case .isFistBumpee:
            return .get
        case .addFistBump:
            return .post
        case .deleteFistBump:
            return .delete
        case .getInsight:
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
        case .searchFistBumpee:
            return .request
        case .searchFistBumper:
            return .request
        case .isFistBumper(userID: _):
            return .request
        case .isFistBumpee(userID: _):
            return .request
        case .addFistBump(userID: _):
            return .request
        case .deleteFistBump(userID: _):
            return .request
          case .getInsight:
            return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}
public enum CommentApi {
  case getComment(postId: String, page: Int, limit: Int)
  case getInitComment(postId: String, page: Int, limit: Int)
  case getCommentDetail(cid: String)
  case count(postId: String)
  case create(params: [String: Any])
  case update(params: [String: Any])
  case delete(commentId: String)
  case like(commentId: String)
  case islike(commentId: String)
  case countLike(commentId: String)
  case unlike(commentId: String)
  case getReply(parentId: String, page: Int, limit: Int)
  case getPin(postId: String)
  case getTitle(postId: String)
  case pin(commentId: String)
  case unpin(commentId: String)
}
extension CommentApi: EndPointType {
  var path: String {
    switch self {
      case .getComment(let postId, let page, let limit):
        return "/\(postId)?page=\(page)&limit=\(limit)"
      case .getInitComment(let postId, let page, let limit):
        return "/\(postId)/init?page=\(page)&limit=\(limit)"
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
      case .countLike(let commentId):
        return "/\(commentId)/like"
      case .islike(let commentId):
        return "/\(commentId)/is-like"
      case .unlike(let commentId):
        return "/\(commentId)/like"
      case .getReply(let parentId, let page, let limit):
        return "/\(parentId)/reply?page=\(page)&limit=\(limit)"
        case .getPin(let postId):
        return "/\(postId)/pined"
      case .getTitle(let postId):
        return "/\(postId)/title"
      case .pin(let commentId):
        return "/\(commentId)/pin"
      case .unpin(let commentId):
        return "/\(commentId)/unpin"
      case .getCommentDetail(let cid):
        return "/\(cid)/detail"
    }
  }
  
  var module: String {
    return "/comment"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getComment:
        return .get
      case .getInitComment:
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
        case .countLike:
            return .get
      case .islike:
        return .get
      case .unlike:
        return .delete
      case .getReply:
        return .get
        case .getPin:
            return .get
      case .getTitle:
        return .get
      case .pin:
        return .post
      case .unpin:
        return .post
      case .getCommentDetail:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getComment:
        return .request
      case .getInitComment:
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
        case .countLike:
            return .request
      case .islike:
        return .request
      case .unlike:
        return .request
    case .getReply:
        return .request
        case .getPin:
            return .request
      case .getTitle:
        return .request
    case .pin:
        return .request
    case .unpin:
        return .request
      case .getCommentDetail:
        return .request
}
  }
  
  var headers: [String: String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
  
}


public enum GameAPI {
  case getGames(page: Int = 1, limit: Int = 20)
}
extension GameAPI: EndPointType {
  var path: String {
    switch self {
      case .getGames(let page, let limit):
        return "?page=\(page)&limit=\(limit)"
    }
  }
  
  var module: String {
    switch self {
      case .getGames:
        return "/games"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getGames:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getGames:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}

public enum SearchFeedAPI {
  case searchUser(query: String, page: Int = 1, limit: Int = 10)
  case searchHashtag(query: String, page: Int = 1, limit: Int = 10)
  case searchPost(query: String, page: Int = 1, limit: Int = 10)
  case getAutoComplete(query: String)
  case getRecent
  case deleteRecent(id: String)
  case postRecent(params: [String: Any])
}
extension SearchFeedAPI: EndPointType {
  var module: String {
    return "/search"
  }
  
  var path: String {
    switch self {
      case .searchUser(let query, let page, let limit):
        return "/users?query=\(query)&page=\(page)&limit=\(limit)"
      case .searchHashtag(query: let query, page: let page, limit: let limit):
        return "/hashtags?query=\(query)&page=\(page)&limit=\(limit)"
      case .searchPost(query: let query, page: let page, limit: let limit):
        return "/posts?query=\(query)&page=\(page)&limit=\(limit)"
      case .getAutoComplete(query: let query):
        return "/autocomplete?query=\(query)"
      case .getRecent:
        return "/result"
        case .deleteRecent(let id):
            return "/result/\(id)"
      case .postRecent:
        return "/result"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .searchUser:
        return .get
      case .searchHashtag:
        return .get
      case .searchPost:
        return .get
      case .getAutoComplete:
        return .get
      case .getRecent:
        return .get
        case .deleteRecent:
            return .delete
      case .postRecent:
        return .post
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .searchUser:
        return .request
      case .searchHashtag:
        return .request
      case .searchPost:
        return .request
      case .getAutoComplete:
        return .request
      case .getRecent:
        return .request
        case .deleteRecent:
            return .request
      case .postRecent(let params):
        return .requestParameters(parameters: params)
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
}



public enum NotiApi {
    case getNotis(page: Int = 1, limit: Int = 20)
    case read(notiId: String)
  case badge
  case resetBadge
}
extension NotiApi: EndPointType {
    var path: String {
        switch self {
            case .getNotis(let page, let limit):
                return "?page=\(page)&limit=\(limit)"
            case .read(let notiId):
              return "/\(notiId)"
          case .badge:
            return "/badge"
          case .resetBadge:
            return "/reset-badge"
        }
    }
    
    var module: String {
      return "/notification"
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .getNotis:
                return .get
          case .read:
            return .get
          case .badge:
            return .get
          case .resetBadge:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .getNotis:
                return .request
          case .read:
            return .request
          case .badge:
            return .request
          case .resetBadge:
            return .request
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
                "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
    }
    
}


public enum LoginActivityApi {
    case getAll(page: Int = 1, limit: Int = 20)
}
extension LoginActivityApi: EndPointType {
    var path: String {
        switch self {
            case .getAll(let page, let limit):
                return "?page=\(page)&limit=\(limit)"
        }
    }
    
    var module: String {
        switch self {
            case .getAll:
                return "/login-activity"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .getAll:
                return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .getAll:
                return .request
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
                "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
    }
    
}


public enum AccountActivityApi {
    case getAll(page: Int = 1, limit: Int = 20)
}
extension AccountActivityApi: EndPointType {
    var path: String {
        switch self {
            case .getAll(let page, let limit):
                return "?page=\(page)&limit=\(limit)"
        }
    }
    
    var module: String {
        switch self {
            case .getAll:
                return "/activity"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .getAll:
                return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .getAll:
                return .request
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
                "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
    }
    
}

public enum ReportApi {
  case create(params: [String: Any])
}
extension ReportApi: EndPointType {
  var path: String {
    switch self {
      case .create:
        return ""
    }
  }
  
  var module: String {
    return "/report"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .create:
        return .post
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .create(let params):
        return .requestParameters(parameters: params)
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}


public enum ViewApi {
    case create(postId: String, watchTime: Double)
}
extension ViewApi: EndPointType {
    var path: String {
        switch self {
            case .create(let postId, _):
                return "/\(postId)"
        }
    }
    
    var module: String {
        return "/view"
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .create:
                return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .create(_, let watchTime):
                return .requestParameters(parameters: ["watchTime": watchTime])
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
                "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
    }
    
}



public enum RiotApi {
  case searchUserRiot(region: String, username: String)
  case userInGame
  case stats(region: String, name: String, queue: String)
  case detect(match: String)
  case history
}
extension RiotApi: EndPointType {
  var path: String {
    switch self {
      case .searchUserRiot(let region, let username):
        return "/userinfo/\(region)/\(username)"
      case .userInGame:
        return "/spectator"
      case .stats(let region, let name, let queue):
        return "/stats/\(region)/\(name)?queue=\(queue)"
      case .history:
        return "/history"
      case .detect(let match):
        return "/detect/\(match)"
    }
  }
  
  var module: String {
    return "/riot"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .searchUserRiot:
        return .get
      case .userInGame:
        return .get
      case .stats:
        return .get
      case .history:
        return .get
      case .detect:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .searchUserRiot:
        return .request
      case .userInGame:
        return .request
      case .stats:
        return .request
      case .history:
        return .request
      case .detect:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}

public enum SupportedGameApi {
  case getSupportedGame
}
extension SupportedGameApi: EndPointType {
  var path: String {
    switch self {
      case .getSupportedGame:
        return "/"
    }
  }
  
  var module: String {
    return "/supported-games"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getSupportedGame:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getSupportedGame:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}

public enum SupportedRegionApi {
  case getSupportedRegion
}
extension SupportedRegionApi: EndPointType {
  var path: String {
    switch self {
      case .getSupportedRegion:
        return "/"
    }
  }
  
  var module: String {
    return "/supported-regions"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getSupportedRegion:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getSupportedRegion:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}


public enum GptHistoryApi {
  case createConversation(params: [String: Any])
  case updateConversation(params: [String: Any])
  case getConversation(gameId: String)
  case clearConversation(gameId: String)
}
extension GptHistoryApi: EndPointType {
  var path: String {
    switch self {
      case .createConversation:
        return "/history"
      case .updateConversation:
        return "/history"
      case .getConversation(let gameId):
        return "/history/\(gameId)"
      case .clearConversation(let gameId):
        return "/history/\(gameId)"
    }
  }
  
  var module: String {
    return "/gpt"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getConversation:
        return .get
      case .createConversation:
        return .post
      case .updateConversation:
        return .patch
      case .clearConversation:
        return .delete
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getConversation:
        return .request
      case .createConversation(let params):
        return .requestParameters(parameters: params)
      case .updateConversation(let params):
        return .requestParameters(parameters: params)
      case .clearConversation:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}


public enum GamePatchApi {
  case getGamePatch(gameId: String)
}
extension GamePatchApi: EndPointType {
  var path: String {
    switch self {
      case .getGamePatch(let gameId):
        return "/\(gameId)"
    }
  }
  
  var module: String {
    return "/game-patch"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getGamePatch:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getGamePatch:
        return .request
    }
  }
  
  var headers: [String : String]? {
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? ""]
  }
  
}

public enum UsedTokenApi {
  case getUsedToken
  case updateUsedToken(body: [String: Any])
}
extension UsedTokenApi: EndPointType {
  var path: String {
    switch self {
      case .getUsedToken:
        return "/"
      case .updateUsedToken:
        return "/"
    }
  }
  
  var module: String {
    return "/used-token"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getUsedToken:
        return .get
      case .updateUsedToken:
        return .post
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getUsedToken:
        return .request
      case .updateUsedToken(let params):
        return .requestParameters(parameters: params)
    }
  }
  
  var headers: [String : String]? {
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }

    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-Client-Timezone": "\(secondsFromGMT)"]
  }
  
}

public enum PromotionApi {
  case getPromotion
  case applyPromotion(id: String)
}
extension PromotionApi: EndPointType {
  var path: String {
    switch self {
      case .getPromotion:
        return "/"
      case .applyPromotion(let id):
        return "/\(id)/apply"
    }
  }
  
  var module: String {
    return "/promotion"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .getPromotion:
        return .get
      case .applyPromotion:
        return .post
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .getPromotion:
        return .request
      case .applyPromotion:
        return .request
    }
  }
  
  var headers: [String : String]? {
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-Client-Timezone": "\(secondsFromGMT)"]
  }
  
}

public enum OpenLinkLogApi {
  case openLink(body: [String: Any])
}
extension OpenLinkLogApi: EndPointType {
  var path: String {
    switch self {
      case .openLink:
        return "/"
    }
  }

  var module: String {
    return "/open-link"
  }

  var httpMethod: HTTPMethod {
    switch self {
      case .openLink:
        return .post

    }
  }

  var task: HTTPTask {
    switch self {
      case .openLink(let body):
        return .requestParameters(parameters: body)

    }
  }

  var headers: [String : String]? {
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }

    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-Client-Timezone": "\(secondsFromGMT)"]
  }

}



public enum PostStitchApi {
  case stitch(body: [String: Any])
  case unstitch(body: [String: Any])
  case accept(body: [String: Any])
  case denied(body: [String: Any])
  case getByRoot(rootId: String, page: Int)
  case countStitchWaitList(rootId: String)
  case getMyStitch(page: Int)
  case getMyNonStitchPost(page: Int)
  case getMyWaitlist(page: Int)
  case getStitchTo(pid: String)
}
extension PostStitchApi: EndPointType {
  var path: String {
    switch self {
      case .stitch:
        return "/"
      case .getByRoot(let rootId, let page):
        return "/\(rootId)?page=\(page)"
      case .countStitchWaitList(let rootId):
        return "/\(rootId)/count-wait-list"
      case .unstitch:
        return "/un-stitch"
      case .accept:
        return "/approve"
      case .denied:
        return "/denied"
      case .getMyStitch(let page):
        return "/my-stitch?page=\(page)"
      case .getMyNonStitchPost(let page):
        return "/my-non-stitch?page=\(page)"
      case .getMyWaitlist(let page):
        return "/my-wait-list?page=\(page)"
      case .getStitchTo(let pid):
        return "/stitch-to/\(pid)"
    }
  }
  
  var module: String {
    return "/post-stitch"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .stitch:
        return .post
      case .getByRoot:
        return .get
      case .countStitchWaitList:
        return .get
      case .unstitch:
        return .post
      case .accept:
        return .post
      case .denied:
        return .post
      case .getMyStitch:
        return .get
      case .getMyNonStitchPost:
        return .get
      case .getMyWaitlist:
        return .get
      case .getStitchTo:
        return .get
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .stitch(let body):
        return .requestParameters(parameters: body)
      case .getByRoot:
        return .request
      case .countStitchWaitList:
        return .request
      case .unstitch(let body):
        return .requestParameters(parameters: body)
      case .accept(let body):
        return .requestParameters(parameters: body)
      case .denied(body: let body):
        return .requestParameters(parameters: body)
      case .getMyStitch:
        return .request
      case .getMyNonStitchPost:
        return .request
      case .getMyWaitlist:
        return .request
      case .getStitchTo:
        return .request
    }
  }
  
  var headers: [String : String]? {
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-Client-Timezone": "\(secondsFromGMT)"]
  }
  
}

public enum ShareApi {
  case createShare(body: [String: Any])
  case getByRoot(rootId: String)
  case countByRoot(rootId: String)
}
extension ShareApi: EndPointType {
  var path: String {
    switch self {
      case .createShare:
        return "/"
      case .getByRoot(let rootId):
        return "/\(rootId)"
      case .countByRoot(let rootId):
        return "/\(rootId)/count"
    }
  }
  
  var module: String {
    return "/post-share"
  }
  
  var httpMethod: HTTPMethod {
    switch self {
      case .createShare:
        return .post
      case .getByRoot:
        return .get
      case .countByRoot:
        return .get
        
    }
  }
  
  var task: HTTPTask {
    switch self {
      case .createShare(let body):
        return .requestParameters(parameters: body)
      case .getByRoot:
        return .request
      case .countByRoot:
        return .request
    }
  }
  
  var headers: [String : String]? {
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
    return ["Authorization": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-User-Token": _AppCoreData.userSession.value?.accessToken ?? "",
            "X-Client-Timezone": "\(secondsFromGMT)"]
  }
  
}


