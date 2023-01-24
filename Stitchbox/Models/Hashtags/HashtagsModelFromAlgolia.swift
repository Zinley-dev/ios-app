//
//  HashtagsModelFromAlgolia.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/23/23.
//

import Foundation

class HashtagsModelFromAlgolia: Codable {
    
    let objectID: String
    let keyword: String
    let count: Int
    
}

extension HashtagsModelFromAlgolia: Equatable {
    static func == (lhs: HashtagsModelFromAlgolia, rhs: HashtagsModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}
