//
//  AccountModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import ObjectMapper

class Account : Mappable {
    enum logintype {
        case phoneLogin
        case normalLogin
    }
    
    
    // MARK: - Tokens
    private(set) var refreshToken: String!
    private(set) var accessToken: String!
    private(set) var user: UserDataSource?
    
    required init?(map: Map) {
        // check if a required "token" and "refresh-token" property exists within the JSON.
        if map.JSON["token"] == nil || map.JSON["refresh-token"] == nil {
            return nil
        }
    }
    func mapping(map: Map) {
        refreshToken <- map["refresh-token"]
        accessToken <- map["token"]
        user <- map["user"]
    }
}
