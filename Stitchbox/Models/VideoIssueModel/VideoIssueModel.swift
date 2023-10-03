//
//  VideoIssueModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/13/23.
//

import Foundation
import ObjectMapper

class VideoIssueModel: Mappable {
    
    private(set) var setting: Setting?
    private(set) var updatedAt: Date?
    private(set) var video: Video?
    private(set) var status: Int = 0
    private(set) var content: String?
    private(set) var mux: Mux?
    private(set) var streamLink: String?
    private(set) var contentModerationMessage: String?
    private(set) var algoliaObjectId: Int64?
    private(set) var id: String = ""
    private(set) var metadata: Metadata?
    private(set) var createdAt: Date?
    private(set) var contentModeration: Int?
    private(set) var commentThreshold: Int?
    private(set) var likeThreshold: Int?
    private(set) var moderationLog: ModerationLog?
    private(set) var estimatedCount: EstimatedCount?
    private(set) var viewThreshold: Int?
    private(set) var userId: String = ""

    required init?(map: ObjectMapper.Map) {}

    func mapping(map: ObjectMapper.Map) {
        setting <- map["setting"]
        updatedAt <- (map["updatedAt"], ISODateTransform())
        video <- map["video"]
        status <- map["status"]
        content <- map["content"]
        mux <- map["mux"]
        streamLink <- map["streamLink"]
        contentModerationMessage <- map["contentModerationMessage"]
        algoliaObjectId <- map["algoliaObjectId"]
        id <- map["_id"]
        metadata <- map["metadata"]
        createdAt <- (map["createdAt"], ISODateTransform())
        contentModeration <- map["contentModeration"]
        commentThreshold <- map["commentThreshold"]
        likeThreshold <- map["likeThreshold"]
        moderationLog <- map["moderationLog"]
        estimatedCount <- map["estimatedCount"]
        viewThreshold <- map["viewThreshold"]
        userId <- map["userId"]
    }
}


class Video: Mappable {
    var rawUrl: String?
    
    required init?(map: ObjectMapper.Map) {}
    func mapping(map: ObjectMapper.Map) {
        rawUrl <- map["rawUrl"]
    }
}

class Mux: Mappable {
    var assetId: String?
    var playbackId: String?
    
    required init?(map: ObjectMapper.Map) {}
    func mapping(map: ObjectMapper.Map) {
        assetId <- map["assetId"]
        playbackId <- map["playbackId"]
    }
}

class Metadata: Mappable {
    var contentMode: Int?
    var height: Int?
    var length: String?
    var width: Int?
    
    required init?(map: ObjectMapper.Map) {}
    func mapping(map: ObjectMapper.Map) {
        contentMode <- map["contentMode"]
        height <- map["height"]
        length <- map["length"]
        width <- map["width"]
    }
}

class ModerationLog: Mappable {
    var actionTaken: String?
    var actionTime: Date?
    var performBy: String?
    
    required init?(map: ObjectMapper.Map) {}
    func mapping(map: ObjectMapper.Map) {
        actionTaken <- map["actionTaken"]
        actionTime <- (map["actionTime"], ISODateTransform())
        performBy <- map["performBy"]
    }
}

extension VideoIssueModel: Hashable {
    
    static func == (lhs: VideoIssueModel, rhs: VideoIssueModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
