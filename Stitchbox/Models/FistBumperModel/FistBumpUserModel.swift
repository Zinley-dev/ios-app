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
    private(set) var user: ListDisplayDataSource = ListDisplayDataSource()
    var isFollowing = false
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        isFollowing <- map["isFollowing"]
        user <- map ["user"]
    }
    
    
}
