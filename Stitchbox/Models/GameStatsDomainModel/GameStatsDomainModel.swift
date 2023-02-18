//
//  GameStatsDomainMode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/17/23.
//

import Foundation

class GameStatsDomainModel {
    
    
    fileprivate var _domain: String!
    fileprivate var _id: String!
    
    var domain: String! {
        get {
            if _domain == nil {
                _domain = ""
            }
            return _domain
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
    
    
    init(postKey: String, GameStatsDomainModel : Dictionary<String, Any>) {
        
    
        if let domain = GameStatsDomainModel["domain"] as? String {
            self._domain = domain
        }
        
        if let id = GameStatsDomainModel["id"] as? String {
            self._id = id
        }
        
        
    }
    
    
    
}



