//
//  SearchModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import Foundation


class UserSearchModel {
 
    fileprivate var _type: String!
    fileprivate var _userId: String!
    fileprivate var _user_name: String!
    fileprivate var _user_nickname: String!
    fileprivate var _avatarUrl: String!
    fileprivate var _coverUrl: String!
    fileprivate var _game_name: String!
    fileprivate var _game_shortName: String!
    fileprivate var _gameList: [String]!
    fileprivate var _text: String!

    
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
    
    var gameList: [String]! {
        get {
            if _gameList == nil {
                _gameList = []
            }
            return _gameList
        }
        
    }
    
    
    init(type: String, RecentModel: Dictionary<String, Any>) {
        
        self._type = type
        
        if let userId = RecentModel["userId"] as? String {
            self._userId = userId
        }
        
        if let user_name = RecentModel["user_name"] as? String {
            self._user_name = user_name
        }
        
        if let user_nickname = RecentModel["user_nickname"] as? String {
            self._user_nickname = user_nickname
        }
        
        if let avatarUrl = RecentModel["avatarUrl"] as? String {
            self._avatarUrl = avatarUrl
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
        
        if let gameList = RecentModel["gameList"] as? [String] {
            self._gameList = gameList
        }
        
        if let text = RecentModel["text"] as? String {
            self._text = text
        }

    }
    

}

