//
//  UserLoginActivity.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/20/23.
//

import Foundation

class UserLoginActivityModel {
  

    fileprivate var _id: String!
    fileprivate var _action: String!
    fileprivate var _device: String!
    fileprivate var _content: String!
    fileprivate var _ip: String!
    fileprivate var _os: String!
    fileprivate var _userId: String!
    fileprivate var _createdAt: Date!
    
    var id: String! {
        get {
            if _id == nil {
                _id = ""
            }
            
            return _id
        }
    }
    
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
    
    var content: String! {
        get {
            if _content == nil {
                _content = ""
            }
            
            return _content
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
    
    var userId: String! {
        get {
            if _userId == nil {
                _userId = ""
            }
            
            return _userId
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
    
    
    init(userLoginActivity: Dictionary<String, Any>) {
        
        if let id = userLoginActivity["_id"] as? String {
            self._id = id
        }
        
        if let action = userLoginActivity["action"] as? String {
            self._action = action
        }
        
        if let device = userLoginActivity["device"] as? String {
            self._device = device
        }
        
        if let content = userLoginActivity["content"] as? String {
            self._content = content
        }
        
        if let ip = userLoginActivity["ip"] as? String {
            self._ip = ip
        }
        
        if let os = userLoginActivity["os"] as? String {
            self._os = os
        }
        
        if let userId = userLoginActivity["userId"] as? String {
            self._userId = userId
        }
       
        if let createdAt = userLoginActivity["createdAt"] as? Date {
            self._createdAt = createdAt
        } else {
            if let createdAtFail = userLoginActivity["createdAt"] {
                self._createdAt = transformFromJSON(createdAtFail)
            }
        }
      
    }

}


extension UserLoginActivityModel: Equatable {
    
    static func == (lhs: UserLoginActivityModel, rhs: UserLoginActivityModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}

