//
//  AccountModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import ObjectMapper

class ThirdPartyCredential: Mappable {
    private(set) var uid: String = ""
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        uid <- map["uid"]
    }
    
}
class AgeRange: Mappable {
    private(set) var agemax: Int = 0
    private(set) var agemin: Int = 0
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        agemax <- map["agemax"]
        agemin <- map["agemin"]
    }
    
}
class User: Mappable {
    private(set) var ID: String! = ""
    private(set) var name: String = ""
    private(set) var username: String = ""
    private(set) var password: String = ""
    private(set) var email: String = ""
    private(set) var phone: String = ""
    private(set) var avatar: String = ""
    private(set) var cover: String = ""
    private(set) var about: String = ""
    private(set) var bio: String = ""
    private(set) var referralCode: String = ""
    private(set) var Birthday: String = ""
    private(set) var facebook: ThirdPartyCredential?
    private(set) var google: ThirdPartyCredential?
    private(set) var twitter: ThirdPartyCredential?
    private(set) var tiktok: ThirdPartyCredential?
    private(set) var apple: ThirdPartyCredential?
    private(set) var FriendsIds: [String] = []
    private(set) var gender: String = ""
    private(set) var location: String = ""
    private(set) var ageRange: AgeRange?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ID <- map["ID"]
        name <- map["name"]
        username <- map["username"]
        password <- map["password"]
        email <- map["email"]
        phone <- map["phone"]
        avatar <- map["avatar"]
        cover <- map["avatar"]
        about <- map["about"]
        bio <- map["bio"]
        referralCode <- map["referralCode"]
        Birthday <- map["Birthday"]
        facebook <- map["facebook"]
        google <- map["google"]
        twitter <- map["twitter"]
        tiktok <- map["tiktok"]
        apple <- map["apple"]
        FriendsIds <- map["FriendsIds"]
        gender <- map["gender"]
        location <- map["location"]
        ageRange <- map["AgeRange"]
    }
    
}

class Account : Mappable {
    enum logintype {
        case phoneLogin
        case normalLogin
    }
    
    
    // MARK: - Tokens
    private(set) var refreshToken: String!
    private(set) var accessToken: String!
    private(set) var user: User?
    
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
