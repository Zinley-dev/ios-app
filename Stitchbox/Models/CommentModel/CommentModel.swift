//
//  CommentModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/21/23.
//

import Foundation


class CommentModel {
    
    var replies: [CommentModel]?
    
    var just_add: Bool!
    var lastCmtSnapshot: Int!
    var hasLoadedReplied = false
    
    fileprivate var _replyTotal: Int!
    fileprivate var _owner_uid: String!
    fileprivate var _comment_id: String!
    fileprivate var _comment_uid: String!
    fileprivate var _comment_name: String!
    fileprivate var _comment_avatarUrl: String!
    fileprivate var _comment_username: String!
    fileprivate var _text: String!
    fileprivate var _isReply: Bool!
    fileprivate var _post_id: String!
    fileprivate var _root_id: String!
    fileprivate var _has_reply: Bool!
    fileprivate var _is_title: Bool!
    fileprivate var _number_of_reply: Int!
    fileprivate var _createdAt: Date!
    fileprivate var _updatedAt: Date!
    fileprivate var _last_modified: Date!
    fileprivate var _reply_to: String!
    fileprivate var _reply_to_username: String!
    fileprivate var _just_add: Bool!
    fileprivate var _reply_to_cid: String!
    fileprivate var _IsNoti: Bool!
    fileprivate var _mention: [[String:Any]]!
    var _is_pinned: Bool!
    
    
    var mention: [[String:Any]]! {
        get {
            if _mention == nil {
                _mention = [[:]]
            }
            return _mention
        }
        
    }
    
    
    var replyTotal: Int! {
        get {
            if _replyTotal == nil {
                _replyTotal = 0
            }
            return _replyTotal
        }
        
    }

    var comment_name: String! {
        get {
            if _comment_name == nil {
                _comment_name = ""
            }
            return _comment_name
        }
        
    }
    
    var comment_avatarUrl: String! {
        get {
            if _comment_avatarUrl == nil {
                _comment_avatarUrl = ""
            }
            return _comment_avatarUrl
        }
        
    }
    
    var comment_username: String! {
        get {
            if _comment_username == nil {
                _comment_username = ""
            }
            return _comment_username
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
    
    var last_modified: Date! {
        get {
            if _last_modified == nil {
                _last_modified =  Date()
            }
            
            return _last_modified
        }
    }
    
    
    var is_pinned: Bool! {
        get {
            if _is_pinned == nil {
                _is_pinned = false
            }
            
            return _is_pinned
        }
    }
   
    
    var IsNoti: Bool! {
        get {
            if _IsNoti == nil {
                _IsNoti = false
            }
            
            return _IsNoti
        }
    }
    
    var reply_to_username: String! {
        get {
            if _reply_to_username == nil {
                _reply_to_username = ""
            }
            return _reply_to_username
        }
        
    }
  
  
    var reply_to_cid: String! {
        get {
            if _reply_to_cid == nil {
                _reply_to_cid = ""
            }
            return _reply_to_cid
        }
        
    }
    
    var owner_uid: String! {
        get {
            if _owner_uid == nil {
                _owner_uid = ""
            }
            return _owner_uid
        }
        
    }
    
    
    var number_of_reply: Int! {
        get {
            if _number_of_reply == nil {
                _number_of_reply = 1
            }
            return _number_of_reply
        }
        
    }
    
       
    var reply_to: String! {
        get {
            if _reply_to == nil {
                _reply_to = ""
            }
            return _reply_to
        }
        
    }
    
    var comment_uid: String! {
        get {
            if _comment_uid == nil {
                _comment_uid = ""
            }
            return _comment_uid
        }
        
    }
    
    var comment_id: String! {
        get {
            if _comment_id == nil {
                _comment_id = ""
            }
            return _comment_id
        }
        
    }
    
    var text: String! {
        get {
            if _text == nil {
                _text = ""
            }
            return _text
        }
        
    }
    
    
    var is_title: Bool! {
        get {
            if _is_title == nil {
                _is_title = false
            }
            
            return _is_title
        }
    }
    
    var isReply: Bool! {
        get {
            if _isReply == nil {
                _isReply = false
            }
            
            return _isReply
        }
    }
    
    var has_reply: Bool! {
        get {
            if _has_reply == nil {
                _has_reply = false
            }
            
            return _has_reply
        }
    }

    
    var post_id: String! {
        
        get {
            if _post_id == nil {
                _post_id = ""
            }
            return _post_id
        }
        
    }
    
    var root_id: String! {
        
        get {
            if _root_id == nil {
                _root_id = ""
            }
            return _root_id
        }
        
    }

    
    
    
    init(postKey: String, Comment_model: Dictionary<String, Any>) {
        
        self._comment_id = postKey
    
        if let mention = Comment_model["mention"] as? [[String: Any]] {
            
            self._mention = mention
            
        }
        
        if let mention = Comment_model["mention_dict"] as? [[String: Any]]  {
            
            self._mention = mention
            
        }
        
        if let hasLoadedReplied = Comment_model["hasLoadedReplied"] as? Bool  {
            
            self.hasLoadedReplied = hasLoadedReplied
            
        }
        
        if let owner = Comment_model["owner"] as? [String: Any] {
            
            if let comment_avatarUrl = owner["avatar"] as? String {
                self._comment_avatarUrl = comment_avatarUrl
            }
            
            if let comment_username = owner["username"] as? String {
                self._comment_username = comment_username
            }
            
            if let comment_uid = owner["_id"] as? String {
                self._comment_uid = comment_uid
            }
            
            if let comment_name = owner["name"] as? String {
                self._comment_name = comment_name
            }
        }
        
        if let replyTo = Comment_model["replyTo"] as? [String: Any] {
            
            if !replyTo.isEmpty {
                
                self._isReply = true
                
                if let reply_to_cid = replyTo["_id"] as? String {
                    self._reply_to_cid = reply_to_cid
                }
                
               if let replyOwner = replyTo["owner"] as? [String: Any] {
                   
                   if let reply_to_username = replyOwner["username"] as? String {
                       self._reply_to_username = reply_to_username
                   }
                   
                   if let reply_to = replyOwner["_id"] as? String {
                       self._reply_to = reply_to
                   }
     
               }
                
            } else {
                self._isReply = false
            }
            
            

        } else {
            
            self._isReply = false
        }
        
        if let isReply = Comment_model["isReply"] as? Bool {
            self._isReply = isReply
        }
        
        
        if let replyTotal = Comment_model["replyTotal"] as? Int {
            self._replyTotal = replyTotal
        }
    
        if let reply_to_username = Comment_model["reply_to_username"] as? String {
            self._reply_to_username = reply_to_username
        }
        
        if let reply_to_cid = Comment_model["reply_to_cid"] as? String {
            self._reply_to_cid = reply_to_cid
        }
       
        if let text = Comment_model["content"] as? String {
            self._text = text
        }
        
        if let post_id = Comment_model["postId"] as? String {
            self._post_id = post_id
        }
        
        if let root_id = Comment_model["parentId"] as? String {
            self._root_id = root_id
        }
    
        
        if let is_pinned = Comment_model["isPined"] as? Bool {
            self._is_pinned = is_pinned
        }
        
        if let has_reply = Comment_model["hasReply"] as? Bool {
            self._has_reply = has_reply
        }
        
        if let is_title = Comment_model["isTitle"] as? Bool {
            self._is_title = is_title
        }
        
        if let owner_uid = Comment_model["ownerId"] as? String {
            self._owner_uid = owner_uid
        }
        
        if let createdAt = Comment_model["createdAt"] as? Date {
            self._createdAt = createdAt
        } else {
            if let createdAtFail = Comment_model["createdAt"] {
                self._createdAt = transformFromJSON(createdAtFail)
            }
        }
        
        
        if let updatedAt = Comment_model["updatedAt"] as? Date {
            self._updatedAt = updatedAt
        } else {
            if let updatedAtFail = Comment_model["updatedAt"] {
                self._updatedAt = transformFromJSON(updatedAtFail)
            }
        }
        
        
        if let last_modified = Comment_model["last_modified"] as? Date {
            self._last_modified = last_modified
        } else {
            if let last_modifiedFail = Comment_model["last_modified"] {
                self._last_modified = transformFromJSON(last_modifiedFail)
            }
        }
        


    }
    
    static func ==(lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.comment_uid == rhs.comment_uid && lhs.comment_id == rhs.comment_id
    }
    

}
