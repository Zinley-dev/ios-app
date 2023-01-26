//
//  UserDataSource.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import ObjectMapper

class ChallengeCardData: Mappable {
    private(set) var badge: String = ""
    private(set) var quote: String = ""
    private(set) var games: [String] = []
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        badge <- map["badge"]
        quote <- map["quote"]
        games <- map["games"]
    }
}

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
    private(set) var discordUrl : String = ""
    
    private(set) var name : String = ""
    private(set) var password: String = ""
    private(set) var cover: String = ""
    private(set) var about: String = ""
    private(set) var bio: String = ""
    private(set) var referralCode: String = ""
    private(set) var birthday: String = ""
    private(set) var facebook: ThirdPartyCredential?
    private(set) var google: ThirdPartyCredential?
    private(set) var twitter: ThirdPartyCredential?
    private(set) var tiktok: ThirdPartyCredential?
    private(set) var apple: ThirdPartyCredential?
    private(set) var friendsIds: [String] = []
    private(set) var location: String = ""
    private(set) var ageRange: AgeRange?
    private(set) var challengeCard: ChallengeCardData?
    required init?(map: Map) {
        //
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        userID          <- map["ID"]
        userName        <- map["username"]
        name            <- map["name"]
        email           <- map["email"]
        phone           <- map["phone"]
        gender          <- map["gender"]
        avatarURL       <- map["avatar"]
        signinMethod    <- map["signinMethod"]
        socialId        <- map["socialId"]
        password        <- map["password"]
        email           <- map["email"]
        cover           <- map["cover"]
        about           <- map["about"]
        bio             <- map["bio"]
        referralCode    <- map["referralCode"]
        birthday        <- map["Birthday"]
        facebook        <- map["facebook"]
        google          <- map["google"]
        twitter         <- map["twitter"]
        tiktok          <- map["tiktok"]
        apple           <- map["apple"]
        friendsIds      <- map["FriendsIds"]
        gender          <- map["gender"]
        location        <- map["location"]
        ageRange        <- map["AgeRange"]
        discordUrl      <- map["discordLink"]
        challengeCard   <- map["challengeCard"]
    }
}
