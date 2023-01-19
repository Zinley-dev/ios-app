//
//  FindFriendsModel.swift
//  StitchBox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import Foundation

class FindFriendsModel {
    
    fileprivate var _firstName: String!
    fileprivate var _familyName: String!
    fileprivate var _phoneNumber: String!
    fileprivate var _imageData: Data!
    
    var _username: String!
    var _userUID: String!
    var _avatarURL: String!
    var _isIn: Bool!
    var _isInvited: Bool!
    
    
    var firstName: String! {
        get {
            return _firstName == nil ? "" : _firstName
        }
    }
    
    var familyName: String! {
        get {
            return _familyName == nil ? "" : _familyName
        }
    }
    
    var imageData: Data! {
        get {
            return _imageData == nil ? nil : _imageData
        }
    }
    
  
    
    var phoneNumber: String! {
        get {
            
            if _phoneNumber != nil {
                
                if _phoneNumber.count == 10 {
                    if !_phoneNumber.contains("+") {
                        
                        if _phoneNumber.first != "0" {
                            _phoneNumber.insert("1", at: _phoneNumber.startIndex)
                            _phoneNumber.insert("+", at: _phoneNumber.startIndex)
                        } else {
                            _phoneNumber.removeFirst()
                            _phoneNumber.insert("4", at: _phoneNumber.startIndex)
                            _phoneNumber.insert("8", at: _phoneNumber.startIndex)
                            _phoneNumber.insert("+", at: _phoneNumber.startIndex)
                        }
                       
                    }
                }
                
            }
            
            
            return _phoneNumber == nil ? "" : _phoneNumber
        }
    }
    
    var isIn: Bool! {
        get {
            return _isIn == nil ? false : _isIn
        }
    }
    
  
    
    init(FindFriendsModel: Dictionary<String, Any>) {
        
        if let firstName = FindFriendsModel["firstName"] as? String {
            self._firstName = firstName
        }
        
        
        if let familyName = FindFriendsModel["familyName"] as? String {
            self._familyName = familyName
        }
        
        if let phoneNumber = FindFriendsModel["phoneNumber"] as? String {
            self._phoneNumber = phoneNumber
        }
        
        if let imageData = FindFriendsModel["imageData"] as? Data {
            self._imageData = imageData
        }
        
        
    }
    
    
    
}
