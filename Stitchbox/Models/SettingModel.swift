//
//  SettingModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/19/23.
//

import ObjectMapper
class NotificationModel: Mappable {
    
    private(set) var Posts: Bool?
    private(set) var Comment: Bool?
    private(set) var Mention: Bool?
    private(set) var Follow: Bool?
    private(set) var Message: Bool?
    private(set) var Stitch: Bool?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        Posts <- map["posts"]
        Comment <- map["comment"]
        Mention <- map["mention"]
        Follow <- map["follow"]
        Message <- map["message"]
        Stitch <- map["stitch"]
    }
}
class SettingModel: Mappable {

    private(set) var AutoPlaySound: Bool?
    private(set) var PrivateAccount: Bool?
    private(set) var EnableEmailTwoFactor: Bool?
    private(set) var EnablePhoneTwoFactor: Bool?
    private(set) var Notifications: NotificationModel?
    private(set) var AllowStitch: Bool?
    
    required init?(map: Map) {
        //
    }

    func mapping(map: Map) {
        AutoPlaySound <- map["autoPlaySound"]
        PrivateAccount <- map["privateAccount"]
        AllowStitch <- map["allowStitch"]
        Notifications <- map["notifications"]
        EnablePhoneTwoFactor <- map["enablePhoneTwoFactor"]
        EnableEmailTwoFactor <- map["enableEmailTwoFactor"]
    }
}
