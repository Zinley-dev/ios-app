//
//  File.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/1/23.
//
//
//  BlockUserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import ObjectMapper

class FistBumpUserModel: Mappable {
    private(set) var avatar: String = "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
    
    private(set) var userID: String = ""
    private(set) var userName: String = ""
    var isFollowing = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        isFollowing <- map["isFollowing"]
        userName <- map ["userName"]
        isFollowing <- map ["isFollowing"]
        userID <- map["userId"]
    }
    
    
}
