//
//  uploadImageGroupModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/4/23.
//

import ObjectMapper

struct uploadImageGroupModel : Mappable {
    

    // MARK: - Properties
    private(set) var url: String = ""
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
    }
    
        
}
