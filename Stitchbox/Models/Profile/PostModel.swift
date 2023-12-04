//
//  postThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import Foundation
import ObjectMapper
import UIKit // Required for CGFloat

class UserSettings: Mappable {
    private(set) var id: String = ""
    private(set) var allowChallenge: Bool = false
    private(set) var allowStitch: Bool = false
    private(set) var allowStreamingLink: Bool = false
    private(set) var autoPlaySound: Bool = false
    private(set) var enableEmailTwoFactor: Bool = false
    private(set) var enablePhoneTwoFactor: Bool = false
    private(set) var privateAccount: Bool = false
    private(set) var publicStitch: Bool = false
    private(set) var userId: String = ""
    
    private(set) var notifications: Notifications?

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        id <- map["_id"]
        allowChallenge <- map["allowChallenge"]
        allowStitch <- map["allowStitch"]
        allowStreamingLink <- map["allowStreamingLink"]
        autoPlaySound <- map["autoPlaySound"]
        enableEmailTwoFactor <- map["enableEmailTwoFactor"]
        enablePhoneTwoFactor <- map["enablePhoneTwoFactor"]
        privateAccount <- map["privateAccount"]
        publicStitch <- map["publicStitch"]
        userId <- map["userId"]
        notifications <- map["notifications"]
    }
}

class Notifications: Mappable {
    private(set) var comment: Bool = false
    private(set) var follow: Bool = false
    private(set) var mention: Bool = false
    private(set) var message: Bool = false
    private(set) var posts: Bool = false
    private(set) var stitch: Bool = false

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        comment <- map["comment"]
        follow <- map["follow"]
        mention <- map["mention"]
        message <- map["message"]
        posts <- map["posts"]
        stitch <- map["stitch"]
    }
}

class Setting: Mappable {
    private(set) var allowStitch: Bool = false
    private(set) var allowComment: Bool = false
    private(set) var isTitleGet: Bool = false
    private(set) var mode: Int = 0
    private(set) var mediaType: String = ""
    private(set) var languageCode: String = ""
    
    required init?(map: ObjectMapper.Map) { }
    
    func mapping(map: ObjectMapper.Map) {
        allowStitch <- map["allowStitch"]
        allowComment <- map["allowComment"]
        isTitleGet <- map["isTitleGet"]
        mode <- map["mode"]
        mediaType <- map["mediaType"]
        languageCode <- map["languageCode"]
    }
}

class EstimatedCount: Mappable {
    private(set) var sizeComments: Int = 0
    private(set) var sizeLikes: Int = 0
    private(set) var sizeViews: Int = 0

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        sizeComments <- map["sizeComments"]
        sizeLikes <- map["sizeLikes"]
        sizeViews <- map["sizeViews"]
    }
}

class PostMetadata: Mappable {
    private(set) var contentmode: Int = 0
    private(set) var height: CGFloat = 0.0
    private(set) var length: Int = 0
    private(set) var width: CGFloat = 0.0

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        contentmode <- map["contentmode"]
        height <- map["height"]
        length <- map["length"]
        width <- map["width"]
    }
}

class Owner: Mappable {
    private(set) var id: String = ""
    private(set) var avatar: String = ""
    private(set) var name: String = ""
    private(set) var username: String = ""

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        id <- map["_id"]
        avatar <- map["avatar"]
        name <- map["name"]
        username <- map["username"]
    }
}

class stitchTo: Mappable {
    private(set) var rootId: String = ""
  
    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        rootId <- map["rootId"]
    }
}

class PostModel: Mappable {
    var id: String = ""
    var stitchedTo = false
    var imageUrl: URL = URL(string: "https://via.placeholder.com/150")!
    private(set) var status: Int = 0
    private(set) var likeThreshold: Int = 0
    private(set) var totalSave: Int = 0
    private(set) var userId: String = ""
    private(set) var commentThreshold: Int = 0
    private(set) var viewThreshold: Int = 0
    private(set) var content: String = ""
    private(set) var videoUrl: String = ""
    private(set) var muxPlaybackId: String = ""
    private(set) var muxAssetId: String = ""
    private(set) var owner: Owner?
    private(set) var stitchTo: [stitchTo]?
    private(set) var setting: Setting?
    private(set) var estimatedCount: EstimatedCount?
    private(set) var metadata: PostMetadata?
    private(set) var createdAt: Date?
    private(set) var totalLikes: Int = 0
    private(set) var totalComments: Int = 0
    private(set) var totalShares: Int = 0
    private(set) var updatedAt: Date?
    private(set) var image: [String] = [""]
    private(set) var hashtags: [String]?
    private(set) var isApproved: Bool = false
    private(set) var totalMemberStitch: Int = 0
    private(set) var totalStitchTo: Int = 0
    private(set) var totalOnChain: Int = 0
    private(set) var positionOnChain: Int = 0
    private(set) var userSettings: UserSettings?
    
    required init?(map: ObjectMapper.Map) {}

    func mapping(map: ObjectMapper.Map) {
        id <- map["_id"]
        status <- map["status"]
        likeThreshold <- map["likeThreshold"]
        totalSave <- map["totalSave"]
        userId <- map["userId"]
        commentThreshold <- map["commentThreshold"]
        viewThreshold <- map["viewThreshold"]
        content <- map["content"]
        videoUrl <- map["video.rawurl"]
        muxPlaybackId <- map["mux.playbackId"]
        muxAssetId <- map["mux.assetId"]
        owner <- map["owner"]
        stitchTo <- map["stitchTo"]
        setting <- map["setting"]
        metadata <- map["metadata"]
        estimatedCount <- map["estimatedCount"]
        createdAt <- (map["createdAt"], ISODateTransform())
        totalLikes <- map["totalLikes"]
        totalComments <- map["totalComments"]
        totalShares <- map["totalShares"]
        updatedAt <- (map["updatedAt"], ISODateTransform())
        image <- map["images"]
        hashtags <- map["hashtags"]
        isApproved <- map["isApproved"]
        totalMemberStitch <- map["totalMemberStitch"]
        totalStitchTo <- map["totalStitchTo"]
        totalOnChain <- map["total"]
        positionOnChain <- map["position"]
        userSettings <- map["userSettings"]
        // Handle image URL logic as needed
        
        if image[0] != "" {
            imageUrl = URL(string: image[0])!
        } else {
            imageUrl = URL(string: "https://image.mux.com/\(muxPlaybackId)/thumbnail.jpg?time=1")!
        }
        
        
        
    }
}

extension PostModel: Hashable {
    
    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
