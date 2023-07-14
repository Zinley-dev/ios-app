//
//  GameList.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/17/23.
//

import ObjectMapper

class GameList: Mappable {
    private(set) var _id: String = ""
    private(set) var cover: String = ""
    private(set) var name: String = ""
    private(set) var shortName: String = ""
    private(set) var domains: [String] = []
    
  
    required init?(map: Map) {
        
    }
  
    
    func mapping(map: ObjectMapper.Map) {
        _id <- map["_id"]
        cover <- map ["cover"]
        name <- map ["name"]
        shortName <- map["shortName"]
        domains <- map["domains"]
    }
    
}


extension GameList: Equatable {
    static func == (lhs: GameList, rhs: GameList) -> Bool {
        return lhs._id == rhs._id
    }
}
