//
//  SendBirdRoomModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/19/22.
//
import ObjectMapper


struct SendBirdRoom : Mappable {
    
    
    // MARK: - Properties
    private(set) var room_id: String = ""
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        room_id <- map["room"]
    }
        
}
