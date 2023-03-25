//
//  FollowerModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 28/01/2023.
//

import Foundation
import ObjectMapper

class FollowModel: Mappable {
    
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var name: String?
    private(set) var userId: String?
    private(set) var isFollowing: Bool = false
    
    var action: String = "follow"
    var needCheck: Bool = true
    var loadFromUserId: String = ""
    var loadFromMode: String = "follower"
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        name        <- map["name"]
        avatar      <- map["avatar"]
        username    <- map["username"]
        userId      <- map["userId"]
        isFollowing <- map ["isFollowing"]
    }
}
