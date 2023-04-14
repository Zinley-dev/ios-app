//
//  RegionModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import Foundation


class RegionModel {
  
    fileprivate var _id: String!
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


    init(regionModel: Dictionary<String, Any>) {
        
        if let id = regionModel["_id"] as? String {
            self._id = id
        }
        
        if let shortName = regionModel["shortName"] as? String {
            self._shortName = shortName
        }
        
        if let name = regionModel["name"] as? String {
            self._name = name
        }

        if let status = regionModel["status"] as? Bool {
            self._status = status
        }
    
    }

}


extension RegionModel: Equatable {
    
    static func == (lhs: RegionModel, rhs: RegionModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}

