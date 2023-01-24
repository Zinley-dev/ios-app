//
//  BlockUserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import ObjectMapper

class BlockUserModel: Mappable {
    
    private(set) var blockId: String = ""
    private(set) var blockUser: UserDataSource = UserDataSource()
    
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        print(map)
        blockId <- map["blockId"]
        blockUser <- map ["blockList.0"]
    }
    
    
}
