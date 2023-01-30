//
//  BlockUserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import ObjectMapper

class BlockUserModel: Mappable {
    
    private(set) var blockId: String = ""
    private(set) var userId: String = ""
    private(set) var blockUser: ListDisplayDataSource = ListDisplayDataSource()
    var isBlock = true
    var isFollowing = false
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        print(map)
        blockId <- map["blockId"]
        userId <- map["userId"]
        blockUser <- map ["blockList"]
    }
    
    
}
