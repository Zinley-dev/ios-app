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
  
  var userID :    String! = ""
  var userName :  String! = ""
  var email :     String! = ""
  var phone :     String! = ""
  var gender :    UserGender = .male
  var avatarURL : String!  = "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
  var coverURL : String!  = "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
  var signinMethod : String! = ""
  var socialId : String! = ""
  var referralCode : String! = ""
  
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
    coverURL   <- map["cover"]
    signinMethod   <- map["signinMethod"]
    socialId   <- map["socialId"]
    referralCode   <- map["referralCode"]
  }
}
