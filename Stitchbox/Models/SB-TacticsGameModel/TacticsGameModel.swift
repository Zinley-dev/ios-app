//
//  SB-TacticsGameModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import Foundation

class TacticsGameModel {
  

    fileprivate var _id: String!
    fileprivate var _logo: String!
    fileprivate var _name: String!
    fileprivate var _shortName: String!
    fileprivate var _status: Bool!
    
    var id: String! {
        get {
            if _id == nil {
                _id = ""
            }
            
            return _id
        }
    }
    
    var logo: String! {
        get {
            if _logo == nil {
                _logo = ""
            }
            
            return _logo
        }
    }
    
    var name: String! {
        get {
            if _name == nil {
                _name = ""
            }
            
            return _name
        }
    }
    
    var shortName: String! {
        get {
            if _shortName == nil {
                _shortName = ""
            }
            
            return _shortName
        }
    }
    
    var status: Bool! {
        get {
            if _status == nil {
                _status = true
            }
            
            return _status
        }
    }


    init(tacticsGameModel: Dictionary<String, Any>) {
        
        if let id = tacticsGameModel["_id"] as? String {
            self._id = id
        }
        
        if let logo = tacticsGameModel["logo"] as? String {
            self._logo = logo
        }
        
        if let name = tacticsGameModel["name"] as? String {
            self._name = name
        }
        
        if let shortName = tacticsGameModel["shortName"] as? String {
            self._shortName = shortName
        }
        
        if let status = tacticsGameModel["status"] as? Bool {
            self._status = status
        }
    
      
    }

}


extension TacticsGameModel: Equatable {
    
    static func == (lhs: TacticsGameModel, rhs: TacticsGameModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}

