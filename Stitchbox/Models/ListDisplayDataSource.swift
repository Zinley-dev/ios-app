//
//  ListDisplayDataSource.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/30/23.
//

import ObjectMapper

class ListDisplayDataSource: Mappable {

    private(set) var userName :  String = ""
    private(set) var avatarURL : String  = "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
    private(set) var name : String = ""
    
    required init?(map: Map) {
        //
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        userName        <- map["username"]
        name            <- map["name"]
        avatarURL       <- map["avatar"]
    }
}
