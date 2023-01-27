//
//  FollowerModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 28/01/2023.
//

import Foundation
import ObjectMapper

class FollowerModel: Mappable {
    
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var userId: String?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        avatar      <- map["avatar"]
        username    <- map["username"]
        userId      <- map["userId"]
    }
}
