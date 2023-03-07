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

    
    init(type: String, RecentModel: Dictionary<String, Any>) {
        
        self._type = type
        
        if let userId = RecentModel["userId"] as? String {
            self._userId = userId
        }
        
        if let user_name = RecentModel["name"] as? String {
            self._user_name = user_name
        }
        
        if let user_nickname = RecentModel["username"] as? String {
            self._user_nickname = user_nickname
        }
        
        if let avatarUrl = RecentModel["avatar"] as? String {
            self._avatarUrl = avatarUrl
        }

    }
    

}


extension UserSearchModel: Equatable {
    static func == (lhs: UserSearchModel, rhs: UserSearchModel) -> Bool {
        return lhs.userId == rhs.userId
    }
}
