//
//  UserDataSource.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import ObjectMapper

enum UserGender : String {
    case male   = "male"
    case female = "female"
}

class UserDataSource: Mappable {
    
    private(set) var userID :    String? = ""
    private(set) var userName :  String = ""
    private(set) var email :     String = ""
    private(set) var phone :     String = ""
    private(set) var gender :    UserGender = .male
    private(set) var avatarURL : String  = "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
    private(set) var signinMethod : String = ""
    private(set) var socialId : String = ""
    
    required init?(map: Map) {
        //
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        userID      <- map["ID"]
        userName    <- map["username"]
        email       <- map["email"]
        phone       <- map["phone"]
        gender      <- map["gender"]
        avatarURL   <- map["avatar"]
        signinMethod   <- map["signinMethod"]
        socialId   <- map["socialId"]
    }
}
