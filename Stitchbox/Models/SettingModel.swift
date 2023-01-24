//
//  SettingModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/19/23.
//

import ObjectMapper
class NotificationModel: Mappable {
    
    private(set) var Posts: Bool?
    private(set) var Challenge: Bool?
    private(set) var Comment: Bool?
    private(set) var Mention: Bool?
    private(set) var Follow: Bool?
    private(set) var Message: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        Posts <- map["Highlight"]
        Challenge <- map["Challenge"]
        Comment <- map["Comment"]
        Mention <- map["Mention"]
        Follow <- map["Follow"]
        Message <- map["Message"]
    }
}
class SettingModel: Mappable {
    
    private(set) var AllowChallenge: Bool?
    private(set) var AllowDiscordLink: Bool?
    private(set) var AutoPlaySound: Bool?
    private(set) var PrivateAccount: Bool?
    private(set) var Notifications: NotificationModel?
    
    required init?(map: Map) {
        //
    }

    func mapping(map: Map) {
        AllowChallenge <- map["AllowChallenge"]
        AllowDiscordLink <- map["AllowDiscordLink"]
        AutoPlaySound <- map["AutoPlaySound"]
        PrivateAccount <- map["AutoMinimize"]
        Notifications <- map["Notifications"]
    }
}
