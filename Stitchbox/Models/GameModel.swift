//
//  GameModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 16/02/2023.
//

import Foundation
class GameModel: Mappable {
    
    private(set) var id: String = ""
    private(set) var name: String = ""
    private(set) var shortName: String?
    private(set) var cover: String?
    private(set) var domains: [String]
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        shortName <- map["shortName"]
        cover <- map["cover"]
        domains <- map["domains"]
    }
}
