//
//  FriendSuggestionModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import Foundation
import ObjectMapper
import UIKit // Required for CGFloat


class FriendSuggestionModel: Mappable {
    
    private(set) var userId: String?
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var name: String?
    private(set) var bio: String?
    private(set) var discordLink: String?
    
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
    }
}


extension FriendSuggestionModel: Hashable {
    
    static func == (lhs: FriendSuggestionModel, rhs: FriendSuggestionModel) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
}
