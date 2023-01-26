//
//  UserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import Foundation

class UserActionModel {
    
    fileprivate var _Follower_uid: String!
    fileprivate var _Following_uid: String!
    fileprivate var _Block_uid: String!
    fileprivate var _action: String!
    
    
    var action: String! {
        get {
            if _action == nil {
                _action = ""
            }
            return _action
        }
        
    }
    
    var Block_uid: String! {
        get {
            if _Block_uid == nil {
                _Block_uid = ""
            }
            return _Block_uid
        }
        
    }
    
    var Follower_uid: String! {
        get {
            if _Follower_uid == nil {
                _Follower_uid = ""
            }
            return _Follower_uid
        }
        
    }
    
    var Following_uid: String! {
        get {
            if _Following_uid == nil {
                _Following_uid = ""
            }
            return _Following_uid
        }
        
    }
   
    
    
    init(postKey: String, user_model: Dictionary<String, Any>) {
        
        if let Follower_uid = user_model["Follower_uid"] as? String {
            self._Follower_uid = Follower_uid
        }
        
        if let Following_uid = user_model["Following_uid"] as? String {
            self._Following_uid = Following_uid
        }
        if let Block_uid = user_model["Block_uid"] as? String {
            self._Block_uid = Block_uid
        }
        
        if let action = user_model["action"] as? String {
            self._action = action
        }
        
        
    }
    
}
