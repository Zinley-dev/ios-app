//
//  NotificationModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/9/23.
//

import Foundation

class UserNotificationModel {

    fileprivate var _user_name: String!
    fileprivate var _user_nickname: String!
    fileprivate var _avatarUrl: String!
    fileprivate var _notiId: String!
    fileprivate var _isRead: Bool!
    fileprivate var _content: String!
    fileprivate var _postId: String!
    fileprivate var _commentId: String!
    fileprivate var _userId: String!
    fileprivate var _createdAt: Date!
    fileprivate var _updatedAt: Date!
    fileprivate var _sender: String!
    fileprivate var _fistbumpCount: Int!
   

    var fistbumpCount: Int! {
        get {
            if _fistbumpCount == nil {
                _fistbumpCount = 0
            }
            return _fistbumpCount
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
    

    var isRead: Bool! {
        get {
            if _isRead == nil {
                _isRead = true
            }
            return _isRead
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
    
    var user_name: String! {
        get {
            if _user_name == nil {
                _user_name = ""
            }
            return _user_name
        }
        
    }
    
    var user_nickname: String! {
        get {
            if _user_nickname == nil {
                _user_nickname = ""
            }
            return _user_nickname
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
        
        
        if let notiId = UserNotificationModel["_id"] as? String {
            self._notiId = notiId
        }
        
        
        if let isRead = UserNotificationModel["isRead"] as? Bool {
            self._isRead = isRead
        }
        
        
        if let notification = UserNotificationModel["notification"] as? [String: Any] {
            
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
                
            }
            
        }
        
        if let sender = UserNotificationModel["sender"] as? [String: Any] {
            
            if let userId = sender["_id"] as? String {
                self._userId = userId
            }
            
            if let userId = sender["avatar"] as? String {
                self._userId = userId
            }
            
            if let userId = sender["name"] as? String {
                self._userId = userId
            }
            
            if let userId = sender["username"] as? String {
                self._userId = userId
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
    

}


extension UserNotificationModel: Equatable {
    static func == (lhs: UserNotificationModel, rhs: UserNotificationModel) -> Bool {
        return lhs.notiId == rhs.notiId
    }
}


