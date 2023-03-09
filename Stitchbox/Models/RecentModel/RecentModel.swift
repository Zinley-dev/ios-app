//
//  RecentModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/2/23.
//

import Foundation


class RecentModel {
 
    fileprivate var _type: String!
    fileprivate var _userId: String!
    fileprivate var _user_name: String!
    fileprivate var _user_nickname: String!
    fileprivate var _avatarUrl: String!
    fileprivate var _coverUrl: String!
    fileprivate var _game_name: String!
    fileprivate var _game_shortName: String!
    fileprivate var _text: String!
    fileprivate var _objectId: String!
    fileprivate var _gameList: [[String: Any]]!
    
    var objectId: String! {
        get {
            if _objectId == nil {
                _objectId = ""
            }
            return _objectId
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

    var type: String! {
        get {
            if _type == nil {
                _type = ""
            }
            return _type
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
    
    var coverUrl: String! {
        get {
            if _coverUrl == nil {
                _coverUrl = ""
            }
            return _coverUrl
        }
        
    }
    
    var game_name: String! {
        get {
            if _game_name == nil {
                _game_name = ""
            }
            return _game_name
        }
        
    }
    
    var game_shortName: String! {
        get {
            if _game_shortName == nil {
                _game_shortName = ""
            }
            return _game_shortName
        }
        
    }
    
    var gameList: [[String: Any]]! {
        get {
            if _gameList == nil {
                _gameList = nil
            }
            return _gameList
        }
        
    }
    
    
    init(RecentModel: Dictionary<String, Any>) {
        
        if let objectId = RecentModel["_id"] as? String {
            self._objectId = objectId
        }
        
        if let type = RecentModel["type"] as? String {
            self._type = type
        }
        
        if let user = RecentModel["user"] as? [String: Any] {
            
            if let userId = user["_id"] as? String {
                self._userId = userId
            }
            
            if let user_name = user["name"] as? String {
                self._user_name = user_name
            }
            
            if let user_nickname = user["username"] as? String {
                self._user_nickname = user_nickname
            }
            
            if let avatarUrl = user["avatar"] as? String {
                self._avatarUrl = avatarUrl
            }
            
            if let challengeCard = user["challengeCard"] as? [String:Any] {
                
                if let gameList = challengeCard["games"] as? [[String: Any]] {
                    self._gameList = gameList
                }
                
            }
            
        }

        
        if let coverUrl = RecentModel["coverUrl"] as? String {
            self._coverUrl = coverUrl
        }
        
        if let game_name = RecentModel["game_name"] as? String {
            self._game_name = game_name
        }
        
        if let game_shortName = RecentModel["game_shortName"] as? String {
            self._game_shortName = game_shortName
        }
        
        if let text = RecentModel["query"] as? String {
            self._text = text
        }

    }
    

}
