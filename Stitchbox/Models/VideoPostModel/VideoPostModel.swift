//
//  VideoPostModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/1/23.
//

import ObjectMapper


struct VideoPostModel : Mappable {
    
    
    // MARK: - Properties
    private(set) var video_url: String = ""
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        video_url <- map["url"]
    }
        
}

