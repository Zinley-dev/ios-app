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
    
    static let shared = APIManager()
    private init() {}
    
    
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
    let commentManager = Manager<CommentApi>()
    let likePostManager = Manager<LikePostApi>()
    let gamesManager = Manager<GameAPI>()
    let searchFeedManager = Manager<SearchFeedAPI>()
    let notiManager = Manager<NotiApi>()
    let loginActManager = Manager<LoginActivityApi>()
    let accountActManager = Manager<AccountActivityApi>()
    let reportManager = Manager<ReportApi>()
    let viewManager = Manager<ViewApi>()
    let gptHistoryManager = Manager<GptHistoryApi>()
    let openLinkManager = Manager<OpenLinkLogApi>()
    let postStitchManager = Manager<PostStitchApi>()
    let shareManager = Manager<ShareApi>()
    let userContactManager = Manager<UserContactApi>()
    let categoryManager = Manager<CategoryApi>()
    
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
  
  func emailVerify(email: String, OTP: String, completion: @escaping APICompletion) {
    let params = ["email": email, "otp": OTP]
    authManager.request(.emailverify(params: params)) { result in
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
    func turnOn2fa(method: String, completion: @escaping APICompletion) {
      settingManager.request(.turnOn2fa(params: ["deviceType": method])) { result in
        completion(result)
      }
    }
    func turnOff2fa(method: String, completion: @escaping APICompletion) {
      settingManager.request(.turnOff2fa(params: ["deviceType": method])) { result in
        completion(result)
      }
    }
    func verify2fa(otp: String, method: String, completion: @escaping APICompletion) {
      settingManager.request(.verify2fa(params: ["deviceType": method, "otp": otp])) { result in
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
  
  
    func getFollows(userId: String? = nil, page: Int, completion: @escaping APICompletion) {
      if let id = userId {
        followManager.request(.getFollows(userId: id, page: page)){
          result in
          completion(result)
        }
      } else if let id = _AppCoreData.userDataSource.value?.userID {
        followManager.request(.getFollows(userId: id, page: page)){
          result in
          completion(result)
        }
      } else {
        completion(.failure(.invalidResponse))
      }
    }
    func getFollowers(userId: String? = nil, page: Int, completion: @escaping APICompletion) {
      if let id = userId {
        followManager.request(.getFollowers(userId: id, page: page)){
          result in
          completion(result)
        }
      } else if let id = _AppCoreData.userDataSource.value?.userID {
          followManager.request(.getFollowers(userId: id, page: page)){
            result in
            completion(result)
          }
      } else {
          completion(.failure(.invalidResponse))
      }
    }
  
  
    func insertFollows(params: [String: Any], completion: @escaping APICompletion) {
        followManager.request(.insertFollows(params: params)){
            result in
            completion(result)
        }
        print("call insertAPI")
    }
    func unFollow(params: [String: Any], completion: @escaping APICompletion) {
        followManager.request(.deleteFollows(params: params)){
            result in
            completion(result)
        }
    }
    func isFollower(uid: String, completion: @escaping APICompletion) {
        followManager.request(.isFollower(userId: uid)){
            result in
            completion(result)
        }
    }
    func isFollowing(uid: String, completion: @escaping APICompletion) {
        followManager.request(.isFollowing(userId: uid)){
            result in
            completion(result)
        }
    }
  
  func deleteFollower(params: [String: Any], completion: @escaping APICompletion) {
    followManager.request(.deleteFollower(params: params)){
      result in
      completion(result)
    }
  }
    
    func searchFollows(query: String, userid: String, page: Int, completion: @escaping APICompletion) {
        let params = ["query": query, "userid": userid]
        followManager.request(.searchFollower(params: params, page: page)) { result in
            completion(result)
        }
    }
    
    func searchFollowing(query: String, userid: String, page: Int, completion: @escaping APICompletion) {
        let params = ["query": query, "userid": userid]
        followManager.request(.searchFollowing(params: params, page: page)) { result in
            completion(result)
        }
    }
    
    func getme(completion: @escaping APICompletion) {
        userManager.request(.getme){
            result in
            completion(result)
        }
    }
  func deleteMe(completion: @escaping APICompletion) {
    userManager.request(.deleteMe){
      result in
      completion(result)
    }
  }
    func undoDeleteMe(completion: @escaping APICompletion) {
        userManager.request(.undoDelete){
            result in
            completion(result)
        }
    }
  
  func getUserInfo(userId: String, completion: @escaping APICompletion) {
    userManager.request(.getUserInfo(userId: userId)){
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
  
  func updateChallengeCard(params: [String: Any], completion: @escaping APICompletion) {
    userManager.request(.updateChallengeCard(params: params)){
      result in
      completion(result)
    }
  }
    
    func updateFavoriteContent(contents: [String], completion: @escaping APICompletion) {
        let params = ["contents": contents];
        userManager.request(.updateFavoriteContent(params: params)){
          result in
          completion(result)
        }
      }
  
    func updatePhone(phone: String, completion: @escaping APICompletion) {
      userManager.request(.updatePhone(params: ["phone": phone])){
          result in
          completion(result)
        }
      }
    func updateEmail(email: String, completion: @escaping APICompletion) {
      userManager.request(.updateEmail(params: ["email": email])){
        result in
        completion(result)
      }
    }
    func verifyUpdatePhone(params: [String: Any], completion: @escaping APICompletion) {
      userManager.request(.verifyPhone(params: params)){
        result in
        completion(result)
      }
    }
    func verifyUpdateEmail(params: [String: Any], completion: @escaping APICompletion) {
        print(params)
      userManager.request(.verifyEmail(params: params)){
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
  
  func updatePassword(params: [String: Any], completion: @escaping APICompletion) {
    userManager.request(.updatepassword(params: params)){
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
    func uploadContact(images: [UIImage], content: String, completion: @escaping APICompletion) {
        // TODO: miss content
        contactManager.upload(.postContact, images: images, content: content){
            result in
            completion(result)
        }
        
    }
    func checkUsernameExist(username: String, completion: @escaping APICompletion) {
      userManager.request(.usernameExist(params: ["username": username])) { result in
        completion(result)
      }
    }
  func checkPhoneExist(phone: String, completion: @escaping APICompletion) {
    userManager.request(.phoneExist(params: ["phone": phone])) { result in
      completion(result)
    }
  }
  func checkEmailExist(email: String, completion: @escaping APICompletion) {
    userManager.request(.emailExist(params: ["email": email])) { result in
      completion(result)
    }
  }
  func addGameForCard(params: [String: Any], completion: @escaping APICompletion) {
    userManager.request(.addGameChallengeCard(params: params)) { result in
      completion(result)
    }
  }
  func updateGameForCard(params: [String: Any], completion: @escaping APICompletion) {
    userManager.request(.updateGameChallengeCard(params: params)) { result in
      completion(result)
    }
  }
  func deleteGameForCard(gameId: String, completion: @escaping APICompletion) {
    userManager.request(.deleteGameChallengeCard(params: ["gameId": gameId])) { result in
      completion(result)
    }
  }
}


extension APIManager {
  func getPostStats(postId: String, completion: @escaping APICompletion) {
    postManager.request(.stats(pid: postId)) { result in
      completion(result)
    }
  }
  func getPostDetail(postId: String, completion: @escaping APICompletion) {
    postManager.request(.getPost(pid: postId)) { result in
      completion(result)
    }
  }
  func getRecommend(completion: @escaping APICompletion) {
    postManager.request(.getRecommend) { result in
      completion(result)
    }
  }
  func getUserFeed(limit: Int = 5, completion: @escaping APICompletion) {
    postManager.request(.getUserFeed(limit: limit)) { result in
      completion(result)
    }
  }
  func getHighTrending(completion: @escaping APICompletion) {
    postManager.request(.getHighTrending) { result in
      completion(result)
    }
  }
  
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
    func updatePost(params: [String: Any], completion: @escaping APICompletion) {
      postManager.request(.update(params: params)) { result in
        completion(result)
      }
    }
    func getLastSettingPost(completion: @escaping APICompletion) {
      postManager.request(.lastSetting) { result in
        completion(result)
      }
    }
    func getHashtagPost(tag: String, page: Int, completion: @escaping APICompletion) {
        postManager.request(.getHashtagPost(tag: tag, page: page)) { result in
            completion(result)
        }
    }
    func getUserPost(userId: String, page: Int, completion: @escaping APICompletion) {
        postManager.request(.getUserPost(user: userId, page: page)) { result in
            completion(result)
        }
    }
    func deleteMyPost(pid: String, completion: @escaping APICompletion) {
      postManager.request(.deleteMyPost(pid: pid)) { result in
        completion(result)
      }
    }
}


extension APIManager {
    func countLikedPost(id: String, completion: @escaping APICompletion) {
        likePostManager.request(.count(postId: id)) { result in
            completion(result)
        }
    }
  func hasLikedPost(id: String, completion: @escaping APICompletion) {
    likePostManager.request(.isLike(params: ["id": id])) { result in
      completion(result)
    }
  }
  func likePost(id: String, completion: @escaping APICompletion) {
    likePostManager.request(.like(params: ["id": id])) { result in
      completion(result)
    }
  }
  func unlikePost(id: String, completion: @escaping APICompletion) {
    likePostManager.request(.unlike(params: ["id": id])) { result in
      completion(result)
    }
  }
  
}

extension APIManager {
  func getCommentDetail(commentId: String, completion: @escaping APICompletion) {
    commentManager.request(.getCommentDetail(cid: commentId)) { result in
      completion(result)
    }
  }
  func getComment(postId: String, page: Int = 1, completion: @escaping APICompletion) {
    commentManager.request(.getComment(postId: postId, page: page, limit: 5)) { result in
      completion(result)
    }
  }
  func getInitComment(postId: String, page: Int = 1, completion: @escaping APICompletion) {
    commentManager.request(.getInitComment(postId: postId, page: page, limit: 5)) { result in
      completion(result)
    }
  }
  func createComment(params: [String: Any], completion: @escaping APICompletion) {
    commentManager.request(.create(params: params)) { result in
      completion(result)
    }
  }
  func updateComment(params: [String: Any], completion: @escaping APICompletion) {
    commentManager.request(.update(params: params)) { result in
      completion(result)
    }
  }
  func deleteComment(commentId: String, completion: @escaping APICompletion) {
    commentManager.request(.delete(commentId: commentId)) { result in
      completion(result)
    }
  }
  func likeComment(comment commentId: String, completion: @escaping APICompletion) {
    commentManager.request(.like(commentId: commentId)) { result in
      completion(result)
    }
  }
  func islike(comment commentId: String, completion: @escaping APICompletion) {
    commentManager.request(.islike(commentId: commentId)) { result in
      completion(result)
    }
  }
    func countLike(comment commentId: String, completion: @escaping APICompletion) {
        commentManager.request(.countLike(commentId: commentId)) { result in
            completion(result)
        }
    }
  func unlike(comment commentId: String, completion: @escaping APICompletion) {
    commentManager.request(.unlike(commentId: commentId)) { result in
      completion(result)
    }
  }
  func countComment(post postId: String, completion: @escaping APICompletion) {
    commentManager.request(.count(postId: postId)) { result in
      completion(result)
    }
  }
    func getReply(for commentId: String, page: Int = 1, completion: @escaping APICompletion) {
        commentManager.request(.getReply(parentId: commentId, page: page, limit: 10)) { result in
            completion(result)
        }
    }
  func getTitleComment(postId: String, completion: @escaping APICompletion) {
    commentManager.request(.getTitle(postId: postId)) { result in
      completion(result)
    }
  }
    func getPinComment(postId: String, completion: @escaping APICompletion) {
        commentManager.request(.getPin(postId: postId)) { result in
            completion(result)
        }
    }
    func pinComment(commentId: String, completion: @escaping APICompletion) {
        commentManager.request(.pin(commentId: commentId)) { result in
            completion(result)
        }
    }
    func unpinComment(commentId: String, completion: @escaping APICompletion) {
        commentManager.request(.unpin(commentId: commentId)) { result in
            completion(result)
        }
    }
    
}

extension APIManager {
  func getGames(page: Int = 1, limit: Int = 20, completion: @escaping APICompletion) {
    gamesManager.request(.getGames(page: page, limit: limit)) {
      result in
      completion(result)
    }
  }
}

extension APIManager {
  func searchUser(query: String, page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
    searchFeedManager.request(.searchUser(query: query, page: page, limit: limit)) { result in
      completion(result)
    }
  }
  func searchPost(query: String, page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
    searchFeedManager.request(.searchPost(query: query, page: page, limit: limit)) { result in
      completion(result)
    }
  }
  func searchHashtag(query: String, page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
    searchFeedManager.request(.searchHashtag(query: query, page: page, limit: limit)) { result in
      completion(result)
    }
  }
  func getAutoComplete(query: String, completion: @escaping APICompletion) {
    searchFeedManager.request(.getAutoComplete(query: query)) { result in
      completion(result)
    }
  }
  func getRecent(completion: @escaping APICompletion) {
    searchFeedManager.request(.getRecent) { result in
      completion(result)
    }
  }
    func addRecent(query: String, type: String, completion: @escaping APICompletion) {
        searchFeedManager.request(.postRecent(params: ["query": query, "type": type])) { result in
      completion(result)
    }
  }
    func deleteRecent(id: String, completion: @escaping APICompletion) {
        searchFeedManager.request(.deleteRecent(id: id)) { result in
            completion(result)
        }
    }
}

extension APIManager {
    func getNotifications(page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
        notiManager.request(.getNotis(page: page, limit: limit)) { result in
            completion(result)
        }
    }
  func readNotification(noti: String, completion: @escaping APICompletion) {
    notiManager.request(.read(notiId: noti)) { result in
      completion(result)
    }
  }
  func getBadge(completion: @escaping APICompletion) {
    notiManager.request(.badge) { result in
      completion(result)
    }
  }
  func resetBadge(completion: @escaping APICompletion) {
    notiManager.request(.resetBadge) { result in
      completion(result)
    }
  }
}

extension APIManager {
    func getLoginActivity(page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
        loginActManager.request(.getAll(page: page, limit: limit)) { result in
            completion(result)
        }
    }
    func getAccountActivity(page: Int = 1, limit: Int = 10, completion: @escaping APICompletion) {
        accountActManager.request(.getAll(page: page, limit: limit)) { result in
            completion(result)
        }
    }
}
extension APIManager {
  func report(type: String, reason: String, note: String, reportId: String, completion: @escaping APICompletion) {
    var params = ["type": type, "reason": reason, "note": note]
      switch type {
          case "USER":
              params["reportUserId"] = reportId
              break;
          case "POST":
              params["postId"] = reportId
              break;
          case "COMMENT":
              params["commentId"] = reportId
              break;
          default:
              break;
      }
    reportManager.request(.create(params: params)) { result in
      completion(result)
    }
  }
}

extension APIManager {

    func createView(post: String, watchTime: Double, completion: @escaping APICompletion) {
        viewManager.request(.create(postId: post, watchTime: watchTime)) { result in
            completion(result)
        }
    }
    
}


extension APIManager {
    
  func getGptConversation(gameId: String, completion: @escaping APICompletion) {
    gptHistoryManager.request(.getConversation(gameId: gameId)) { result in
      completion(result)
    }
  }
  func createGptConversation(params: [String: Any], completion: @escaping APICompletion) {
    gptHistoryManager.request(.createConversation(params: params)) { result in
      completion(result)
    }
  }
  func updateGptConversation(params: [String: Any], completion: @escaping APICompletion) {
    gptHistoryManager.request(.updateConversation(params: params)) { result in
      completion(result)
    }
  }
  func clearGptConversation(gameId: String, completion: @escaping APICompletion) {
    gptHistoryManager.request(.clearConversation(gameId: gameId)) { result in
      completion(result)
    }
  }
    
}

extension APIManager {
    
    func openLink(postId: String, link: String, completion: @escaping APICompletion) {
        openLinkManager.request(.openLink(body: ["postId": postId, "link": link])) { result in
          completion(result)
        }
    }
    
  
  func stitch(rootId: String, memberId: String, completion: @escaping APICompletion) {
    let params = ["rootId": rootId, "member": memberId]
    postStitchManager.request(.stitch(body: params)) { result in
      completion(result)
    }
  }
  func getStitchWaitList(rootId: String, page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getStitchWaitList(rootId: rootId, page: page)) { result in
      completion(result)
    }
  }
  func countStitchWaitList(rootId: String, completion: @escaping APICompletion) {
    postStitchManager.request(.countStitchWaitList(rootId: rootId)) { result in
      completion(result)
    }
  }
  func isStitchedByMe(rootId: String, completion: @escaping APICompletion) {
    postStitchManager.request(.isStitchByMe(rootId: rootId)) { result in
      completion(result)
    }
  }
  func getStitchPost(rootId: String, page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getByRoot(rootId: rootId, page: page)) { result in
      completion(result)
    }
  }
  func getMyStitch(page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getMyStitch(page: page)) { result in
      completion(result)
    }
  }
  func getMyNonStitchPost(page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getMyNonStitchPost(page: page)) { result in
      completion(result)
    }
  }
  func getMyWaitlist(page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getMyWaitlist(page: page)) { result in
      completion(result)
    }
  }
  func getMyPostHasStitched(page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getMyPostsHasStitched(page: page)) { result in
      completion(result)
    }
  }
  
  func unstitch(rootId: String, memberId: String, completion: @escaping APICompletion) {
    let params = ["rootId": rootId, "member": memberId]
    postStitchManager.request(.unstitch(body: params)) { result in
      completion(result)
    }
  }
  
  func acceptStitch(rootId: String, memberId: String, completion: @escaping APICompletion) {
    let params = ["rootId": rootId, "member": memberId]
    postStitchManager.request(.accept(body: params)) { result in
      completion(result)
    }
  }
  func deniedStitch(rootId: String, memberId: String, completion: @escaping APICompletion) {
    let params = ["rootId": rootId, "member": memberId]
    postStitchManager.request(.denied(body: params)) { result in
      completion(result)
    }
  }
  
  func createShare(postId: String, userId: String, completion: @escaping APICompletion) {
    let params = ["postId": postId, "userId": userId]
    shareManager.request(.createShare(body: params)) { result in
      completion(result)
    }
  }
  
  func getShare(postId: String, completion: @escaping APICompletion) {
    shareManager.request(.getByRoot(rootId: postId)) { result in
      completion(result)
    }
  }
  
  func countShare(postId: String, completion: @escaping APICompletion) {
    shareManager.request(.countByRoot(rootId: postId)) { result in
      completion(result)
    }
  }
  
  func savePost(postId: String, completion: @escaping APICompletion) {
    let params = ["postId": postId]
    userManager.request(.savePost(params: params)) { result in
      completion(result)
    }
  }
  
  func unsavePost(postId: String, completion: @escaping APICompletion) {
    let params = ["postId": postId]
    userManager.request(.unsavePost(params: params)) { result in
      completion(result)
    }
  }
  
  func getSavedPost(page: Int, completion: @escaping APICompletion) {
    userManager.request(.getSavedPost(page: page)) { result in
      completion(result)
    }
  }
  
  func getPostTrending(page: Int = 1, completion: @escaping APICompletion) {
    postManager.request(.getPostTrending(page: page)) { result in
      completion(result)
    }
  }
  
  func getPostTrendingTag(page: Int = 1, completion: @escaping APICompletion) {
    postManager.request(.getTagTrending(page: page)) { result in
      completion(result)
    }
  }
  
  func getStitchTo(pid: String, completion: @escaping APICompletion) {
    postStitchManager.request(.getStitchTo(pid: pid)) { result in
      completion(result)
    }
  }
  
  func checkSavedPost(pid: String, completion: @escaping APICompletion) {
    postManager.request(.checkSavedPost(pid: pid)) { result in
      completion(result)
    }
  }
  
  func countSavedPost(pid: String, completion: @escaping APICompletion) {
    postManager.request(.countSavedPost(pid: pid)) { result in
      completion(result)
    }
  }
  func getMyPostInWaitList(page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getMyPostInWaitlist(page: page)) { result in
      completion(result)
    }
  }
  func suggestUser(page: Int, completion: @escaping APICompletion) {
    userManager.request(.suggestUser(page: page)) { result in
      completion(result)
    }
  }
  func countPostStitch(pid: String, completion: @escaping APICompletion) {
    postStitchManager.request(.countRootStitch(rootId: pid)) { result in
      completion(result)
    }
  }
  func countMyStitch(completion: @escaping APICompletion) {
    postStitchManager.request(.countMyStitch) { result in
      completion(result)
    }
  }
  func countStitchByUser(userId: String, completion: @escaping APICompletion) {
    postStitchManager.request(.countStitchBy(userId: userId)) { result in
      completion(result)
    }
  }
  func getSuggestStitch(rootId: String, page: Int, completion: @escaping APICompletion) {
    postStitchManager.request(.getSuggestStitch(rootId: rootId, page: page)) { result in
      completion(result)
    }
  }
  func createUserContact(contact: [String: Any], completion: @escaping APICompletion) {
    userContactManager.request(.create(body: contact)) { result in
      completion(result)
    }
  }
  func createUserContactBulk(contacts: [String: Any], completion: @escaping APICompletion) {
    userContactManager.request(.createBulk(body: contacts)) { result in
      completion(result)
    }
  }
  func getStitchInsightOverview(userID: String = _AppCoreData.userDataSource.value?.userID ?? "", completion: @escaping APICompletion) {
    postStitchManager.request(.getStitchInsight(uid: userID)) {
      result in
      completion(result)
    }
  }
  func getReactionPost(postId: String, completion: @escaping APICompletion) {
    postManager.request(.reaction(pid: postId)) { resut in
      completion(resut)
    }
  }
  func getModeration(page: Int, completion: @escaping APICompletion) {
    postManager.request(.moderation(page: page)) { resut in
      completion(resut)
    }
  }
  func getCategory(page: Int, limit: Int, completion: @escaping APICompletion) {
    categoryManager.request(.getAll(page: page, limit: limit)) { resut in
      completion(resut)
    }
  }
  func setCategory(cateIds: [String], completion: @escaping APICompletion) {
    let params = ["cateId": cateIds]
    userManager.request(.addInterestCategory(params: params)) { resut in
      completion(resut)
    }
  }
}
