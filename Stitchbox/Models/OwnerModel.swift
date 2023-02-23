//
//  OwnerModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 23/02/2023.
//

import ObjectMapper

class OwnerModel: Mappable {
    
    private(set) var id: String?
    private(set) var name: String?
    private(set) var username: String?
    private(set) var avatar: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        username <- map["username"]
        avatar <- map["avatar"]
    }
}
