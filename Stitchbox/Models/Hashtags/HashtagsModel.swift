//
//  HashtagsModelFromAlgolia.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/23/23.
//

import Foundation

class HashtagsModel: Codable {

    fileprivate var _objectID: String!
    fileprivate var _keyword: String!
    fileprivate var _count: Int!
    

    
    var objectID: String! {
        get {
            if _objectID == nil {
                _objectID = ""
            }
            return _objectID
        }
        
    }

    var keyword: String! {
        get {
            if _keyword == nil {
                _keyword = ""
            }
            return _keyword
        }
        
    }

    var count: Int! {
        get {
            if _count == nil {
                _count = 0
            }
            return _count
        }
        
    }

    
    
    init(type: String, hashtagModel: Dictionary<String, Any>) {
        
        if let objectID = hashtagModel["objectID"] as? String {
            self._objectID = objectID
        }
        
        if let keyword = hashtagModel["name"] as? String {
            self._keyword = keyword
        }
        
        if let count = hashtagModel["postCount"] as? Int {
            self._count = count
        }
        
    }
    
}

extension HashtagsModel: Equatable {
    static func == (lhs: HashtagsModel, rhs: HashtagsModel) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}

