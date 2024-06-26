//
//  UserDataSource.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
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
enum UserGender : String {
    case male   = "male"
    case female = "female"
}

class UserDataSource: Mappable {
    private(set) var userID: String?
    
    private var _userName: String? = ""
    private var _passEligible :  Bool? = false
    
    var passEligible: Bool? {
      set(newValue) { _passEligible = newValue }
      get { return _passEligible}
    }
  
    var userName: String? {
      set(newValue) { _userName = newValue }
      get { return _userName}
    }
  
    private var _email: String = ""
    var email: String {
      set(newValue) { _email = newValue}
      get { return _email }
    }
  
    private var _phone : String = ""
    var phone: String {
      set(newValue) { _phone = newValue}
      get { return _phone }
    }
  
    private(set) var gender: UserGender = .male
    private var _avatarURL: String  = ""
    private var _gptAvatarURL : String  = "defaultuser"
    var avatarURL: String {
      set(newValue) { _avatarURL = newValue}
      get { return _avatarURL }
    }
    
    var gptAvatarURL: String {
      set(newValue) { _gptAvatarURL = newValue}
      get { return _gptAvatarURL }
    }
  
    private(set) var signinMethod : String = ""
    private(set) var socialId : String = ""
    private(set) var discordUrl : String = ""
    
    private var _favoriteContent : [String] = []
    var favoriteContent: [String] {
      set(newValue) { _favoriteContent = newValue}
      get { return _favoriteContent }
    }
    
    private var _name : String? = ""
    var name: String? {
      set(newValue) { _name = newValue }
      get { return _name}
    }
    private(set) var password: String = ""
    private var _cover: String = ""
    var cover: String {
      set(newValue) { _cover = newValue}
      get { return _cover }
    }
    private var _about: String = ""
    var about: String {
      set(newValue) { _about = newValue}
      get { return _about }
    }
    private var _bio: String = ""
    var bio: String {
      set(newValue) { _bio = newValue}
      get { return _bio }
    }
    private var _referralCode: String = ""
    var referralCode: String {
      set(newValue) { _referralCode = newValue}
      get { return _referralCode }
    }
    private var _birthday: Date?
    var birthday: Date? {
      set(newValue) { _birthday = newValue}
      get { return _birthday }
    }
  private var _isDelete: Bool?
  var isDelete: Bool {
    set(newValue) { _isDelete = newValue }
    get {
      if (deletedAt != nil && status == 1) {return true;}
      return false;
    }
  }

    private(set) var facebook: ThirdPartyCredential?
    private(set) var google: ThirdPartyCredential?
    private(set) var twitter: ThirdPartyCredential?
    private(set) var tiktok: ThirdPartyCredential?
    private(set) var apple: ThirdPartyCredential?
    private(set) var friendsIds: [String] = []
    private(set) var location: String = ""
    private(set) var createdAt: Date?
    private(set) var deletedAt: Date?
    
    private(set) var status: Int = 0
    
    private(set) var ageRange: AgeRange?
    required init?(map: Map) {
        //
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        userID          <- map["_id"]
        userName        <- map["username"]
        name            <- map["name"]
        email           <- map["email"]
        phone           <- map["phone"]
        gender          <- map["gender"]
        avatarURL       <- map["avatar"]
        gptAvatarURL    <- map["avatar"]
        signinMethod    <- map["signinMethod"]
        socialId        <- map["socialId"]
        password        <- map["password"]
        email           <- map["email"]
        cover           <- map["cover"]
        about           <- map["about"]
        bio             <- map["bio"]
        referralCode    <- map["referralCode"]
        birthday        <- (map["birthday"], ISODateTransform())
        facebook        <- map["facebook"]
        google          <- map["google"]
        twitter         <- map["twitter"]
        tiktok          <- map["tiktok"]
        apple           <- map["apple"]
        friendsIds      <- map["FriendsIds"]
        gender          <- map["gender"]
        location        <- map["location"]
        createdAt       <- (map["createdAt"], ISODateTransform())
        deletedAt       <- (map["deletedAt"], ISODateTransform())
        status          <- map["status"]
        ageRange        <- map["AgeRange"]
        discordUrl      <- map["discordLink"]
        passEligible  <- map["passEligible"]
        favoriteContent  <- map["favoriteContent"]
    }
}
