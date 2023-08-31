//
//  CategoryModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/27/23.
//

import ObjectMapper

class CategoryModel: Mappable {
    
    private(set) var id: String?
    private(set) var name: String?
    
    required init?(map: Map) {
        // Initialize properties if needed
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
    }
}

