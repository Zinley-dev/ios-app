//
//  SessionDataSource.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import Foundation
import ObjectMapper

class SessionDataSource: Mappable {
  
  var accessToken: String! = ""
  var refreshToken: String! = ""
  
  required init?(map: Map) {
    //
  }
  
  func mapping(map: Map) {
    accessToken     <- map["accessToken"]
    refreshToken    <- map["refreshToken"]
  }
}
