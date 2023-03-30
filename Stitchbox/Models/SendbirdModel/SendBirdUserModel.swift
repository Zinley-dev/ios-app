//
//  SendBirdUserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/24/22.
//
import ObjectMapper


struct SearchUser : Mappable {

    // MARK: - Properties
    private(set) var userID: String = ""
    private(set) var avatar: String = ""
    private(set) var username: String = ""
    
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        userID <- map["_id"]
        avatar <- map["avatar"]
        username <- map["username"]
    }

        
}
