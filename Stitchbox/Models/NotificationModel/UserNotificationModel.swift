//
//  NotificationModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/9/23.
//

import Foundation

class UserNotificationModel {

    fileprivate var _name: String!
    fileprivate var _username: String!
    fileprivate var _avatarUrl: String!
    fileprivate var _notiId: String!
    fileprivate var _content: String!
    fileprivate var _postId: String!
    fileprivate var _commentId: String!
    fileprivate var _userId: String!
    fileprivate var _createdAt: Date!
    fileprivate var _updatedAt: Date!
    fileprivate var _sender: String!
    fileprivate var _template: String!
    fileprivate var _fistbumpCount: Int!
    fileprivate var _post: PostModel!
    fileprivate var _rootComment: String!
    fileprivate var _replyToComment: String!

   
    var _isRead = true
    
    var post: PostModel! {
        get {
            if _post == nil {
                _post = nil
            }
            return _post
        }
        
    }
    
    var rootComment: String! {
        get {
            if _rootComment == nil {
                _rootComment = ""
            }
            return _rootComment
        }
        
    }
    
    var replyToComment: String! {
        get {
            if _replyToComment == nil {
                _replyToComment = ""
            }
            return _replyToComment
        }
        
    }
   
    var fistbumpCount: Int! {
        get {
            if _fistbumpCount == nil {
                _fistbumpCount = 0
            }
            return _fistbumpCount
        }
        
    }
    
    
    var template: String! {
        get {
            if _template == nil {
                _template = ""
            }
            return _template
        }
        
    }
    
    
    var sender: String! {
        get {
            if _sender == nil {
                _sender = ""
            }
            return _sender
        }
        
    }
    
    var userId: String! {
        get {
            if _userId == nil {
                _userId = ""
            }
            return _userId
        }
        
    }
    
    
    var postId: String! {
        get {
            if _postId == nil {
                _postId = ""
            }
            return _postId
        }
        
    }
    
    
    var commentId: String! {
        get {
            if _commentId == nil {
                _commentId = ""
            }
            return _commentId
        }
        
    }
    
    var content: String! {
        get {
            if _content == nil {
                _content = ""
            }
            return _content
        }
        
    }
    
    var notiId: String! {
        get {
            if _notiId == nil {
                _notiId = ""
            }
            return _notiId
        }
        
    }
    
    var name: String! {
        get {
            if _name == nil {
                _name = ""
            }
            return _name
        }
        
    }
    
    var username: String! {
        get {
            if _username == nil {
                _username = ""
            }
            return _username
        }
        
    }
    
    var avatarUrl: String! {
        get {
            if _avatarUrl == nil {
                _avatarUrl = ""
            }
            return _avatarUrl
        }
        
    }

    var createdAt: Date! {
        get {
            if _createdAt == nil {
                _createdAt = Date()
            }
            
            return _createdAt
        }
    }
    
    
    var updatedAt: Date! {
        get {
            if _updatedAt == nil {
                _updatedAt =  Date()
            }
            
            return _updatedAt
        }
    }
    
    init(UserNotificationModel: Dictionary<String, Any>) {
        
        if let isRead = UserNotificationModel["isRead"] as? Bool {
            self._isRead = isRead
        }
        
        
        if let notification = UserNotificationModel["notification"] as? [String: Any] {
            
            if let notiId = notification["_id"] as? String {
                self._notiId = notiId
            }
            
            if let content = notification["content"] as? String {
                self._content = content
            }
            
            if let content = notification["metadata"] as? [String: Any] {
               
                if let postId = content["postId"] as? String {
                    self._postId = postId
                }
                
                if let sender = content["sender"] as? String {
                    self._sender = sender
                }
                
                if let commentId = content["commentId"] as? String {
                    self._commentId = commentId
                }
                
                if let fistbumpCount = content["fistbumpCount"] as? Int {
                    self._fistbumpCount = fistbumpCount
                }
                
                if let replyToComment = content["replyToComment"] as? String {
                    self._replyToComment = replyToComment
                }
                
                if let rootComment = content["rootComment"] as? String {
                    self._rootComment = rootComment
                }
                
                
            }
            
            if let template = notification["type"] as? String {
                self._template = template
                
                if template == "NEW_POST" || template == "NEW_COMMENT" || template == "REPLY_COMMENT" || template == "NEW_TAG" {
                    
                    if let getPostId = self._postId, getPostId != "" {
                        
                        APIManager().getPostDetail(postId: getPostId) { result in
                            switch result {
                                
                              case .success(let response):
                                guard let data = response.body else {
                                  return
                                }
                                
                                let getPost = PostModel(JSON: data)
                                self._post = getPost
                                

                              case .failure(let error):
                                print(error)
                            }
                          }
                        
                    }
                     
                }
                
            }
            
            
            if let sender = notification["sender"] as? [String: Any] {
                
                if let userId = sender["_id"] as? String {
                    self._userId = userId
                }
                
                if let avatarUrl = sender["avatar"] as? String {
                    self._avatarUrl = avatarUrl
                }
                
                if let name = sender["name"] as? String {
                    self._name = name
                }
                
                if let username = sender["username"] as? String {
                    self._username = username
                }
                
            }
            
        }
        
        if let createdAt = UserNotificationModel["createdAt"] as? Date {
            self._createdAt = createdAt
        } else {
            if let createdAtFail = UserNotificationModel["createdAt"] {
                self._createdAt = transformFromJSON(createdAtFail)
            }
        }
        
        
        if let updatedAt = UserNotificationModel["updatedAt"] as? Date {
            self._updatedAt = updatedAt
        } else {
            if let updatedAtFail = UserNotificationModel["updatedAt"] {
                self._updatedAt = transformFromJSON(updatedAtFail)
            }
        }

        
    }
    
    func getPost() {
        
        
        
        
    }
    

}


extension UserNotificationModel: Equatable {
    static func == (lhs: UserNotificationModel, rhs: UserNotificationModel) -> Bool {
        return lhs.notiId == rhs.notiId
    }
}


