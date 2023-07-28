//
//  FriendSuggestionModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import Foundation
import ObjectMapper

class FriendSuggestionModel: Mappable {
    
    private(set) var userId: String?
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var name: String?
    private(set) var bio: String?
    private(set) var discordLink: String?
    private(set) var challengeCard: ChallengeCard?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        userId            <- map["_id"]
        avatar         <- map["avatar"]
        username       <- map["username"]
        name           <- map["name"]
        bio            <- map["bio"]
        discordLink    <- map["discordLink"]
        challengeCard  <- map["challengeCard"]
    }
}

class ChallengeCard: Mappable {
    private(set) var badge: String?
    private(set) var games: String?
    private(set) var quote: String?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        badge <- map["badge"]
        games <- map["games"]
        quote <- map["quote"]
    }
}

