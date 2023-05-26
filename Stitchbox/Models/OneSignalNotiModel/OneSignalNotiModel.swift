//
//  OneSignalNotiModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/2/23.
//

import Foundation

class OneSignalNotiModel {

    fileprivate var _username: String!
    fileprivate var _postId: String!
    fileprivate var _commentId: String!
    fileprivate var _userId: String!
    fileprivate var _sender: String!
    fileprivate var _template: String!
    fileprivate var _post: PostModel!
    fileprivate var _rootComment: String!
    fileprivate var _replyToComment: String!

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
    
    var username: String! {
        get {
            if _username == nil {
                _username = ""
            }
            return _username
        }
        
    }
    
    
    init(OneSignalNotiModel: Dictionary<String, Any>) {
        
        if let userId = OneSignalNotiModel["senderId"] as? String {
            self._userId = userId
        }
        
        if let username = OneSignalNotiModel["sender"] as? String {
            self._username = username
        }
        
        if let postId = OneSignalNotiModel["postId"] as? String {
            self._postId = postId
        }
        
        if let commentId = OneSignalNotiModel["commentId"] as? String {
            self._commentId = commentId
        }
        
        
        if let replyToComment = OneSignalNotiModel["replyToComment"] as? String {
            self._replyToComment = replyToComment
        }
        
        if let rootComment = OneSignalNotiModel["rootComment"] as? String {
            self._rootComment = rootComment
        }
        
        if let template = OneSignalNotiModel["type"] as? String {
            self._template = template
            
            if template == "NEW_POST" || template == "NEW_COMMENT" || template == "REPLY_COMMENT" || template == "NEW_TAG" {
                
                if let getPostId = self._postId, getPostId != "" {
                    
                    APIManager.shared.getPostDetail(postId: getPostId) { result in
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

      
    }

}

