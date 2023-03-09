//
//  NotificationModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/9/23.
//

import Foundation

class UserNotificationModel {
 
    fileprivate var _userId: String!
    fileprivate var _user_name: String!
    fileprivate var _user_nickname: String!
    fileprivate var _avatarUrl: String!
    fileprivate var _gameList: [[String: Any]]!
    
    
    var gameList: [[String: Any]]! {
        get {
            if _gameList == nil {
                _gameList = nil
            }
            return _gameList
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

    
    init(UserNotificationModel: Dictionary<String, Any>) {
        
        if let userId = UserNotificationModel["_id"] as? String {
            self._userId = userId
        }
        
        if let user_name = UserNotificationModel["name"] as? String {
            self._user_name = user_name
        }
        
        if let user_nickname = UserNotificationModel["username"] as? String {
            self._user_nickname = user_nickname
        }
        
        if let avatarUrl = UserNotificationModel["avatar"] as? String {
            self._avatarUrl = avatarUrl
        }
        
        if let challengeCard = UserNotificationModel["challengeCard"] as? [String:Any] {
            
            if let gameList = challengeCard["games"] as? [[String: Any]] {
                self._gameList = gameList
            }
            
        }
  
        
    }
    

}

extension UserNotificationModel: Equatable {
    static func == (lhs: UserNotificationModel, rhs: UserNotificationModel) -> Bool {
        return lhs.userId == rhs.userId
    }
}


