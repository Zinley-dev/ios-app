//
//  UserActivityModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import Foundation
import CoreLocation

class UserActivityModel {
    
    fileprivate var _content: String!
    fileprivate var _id: String!
    fileprivate var _os: String!
    fileprivate var _userId: String!
    fileprivate var _ip: String!
    fileprivate var _action: String!
    fileprivate var _createdAt: Date!
    fileprivate var _updatedAt: Date!
    fileprivate var _device: String!
    fileprivate var _postId: String!
    fileprivate var _post: PostModel!
    fileprivate var _rootComment: String!
    fileprivate var _replyToComment: String!
    fileprivate var _commentId: String!
    
    
    var action: String! {
        get {
            if _action == nil {
                _action = ""
            }
            return _action
        }
        
    }
    
    var device: String! {
        get {
            if _device == nil {
                _device = ""
            }
            return _device
        }
        
    }
    
    
    var ip: String! {
        get {
            if _ip == nil {
                _ip = ""
            }
            return _ip
        }
        
    }
    
    var os: String! {
        get {
            if _os == nil {
                _os = ""
            }
            return _os
        }
        
    }
    
    var id: String! {
        get {
            if _id == nil {
                _id = ""
            }
            return _id
        }
        
    }
    
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
    
    
    init(userActivityModel: Dictionary<String, Any>) {
        //DELETE
        if let metadata = userActivityModel["metadata"] as? [String: Any] {
            
            if let postId = metadata["postId"] as? String {
                self._postId = postId
            }
            
            if let commentId = metadata["commentId"] as? String {
                self._commentId = commentId
            }
            
            if let replyToComment = metadata["replyToComment"] as? String {
                self._replyToComment = replyToComment
            }
            
            if let rootComment = metadata["rootComment"] as? String {
                self._rootComment = rootComment
            }
            
        }
        
        if let id = userActivityModel["_id"] as? String {
            self._id = id
        }
        
        if let action = userActivityModel["action"] as? String {
            self._action = action
        }
        
        if let device = userActivityModel["device"] as? String {
            self._device = device
        }
        
        if let content = userActivityModel["content"] as? String {
            self._content = content
        }
        
        if let ip = userActivityModel["ip"] as? String {
            self._ip = ip
        }
        
        if let os = userActivityModel["os"] as? String {
            self._os = os
        }
        
        if let userId = userActivityModel["userId"] as? String {
            self._userId = userId
        }

        
        if let createdAt = userActivityModel["createdAt"] as? Date {
            self._createdAt = createdAt
        } else {
            if let createdAtFail = userActivityModel["createdAt"] {
                self._createdAt = transformFromJSON(createdAtFail)
            }
        }
        
        
        if let updatedAt = userActivityModel["updatedAt"] as? Date {
            self._updatedAt = updatedAt
        } else {
            if let updatedAtFail = userActivityModel["updatedAt"] {
                self._updatedAt = transformFromJSON(updatedAtFail)
            }
        }
        
    }
    

}
