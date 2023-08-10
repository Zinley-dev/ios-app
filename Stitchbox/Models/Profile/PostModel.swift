//
//  postThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//
import Foundation
import ObjectMapper

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
    private(set) var contentmode: String = ""
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

class PostModel: Mappable {
    var id: String = ""
    var stitchedTo = false
    var imageUrl: URL = URL(string: "https://via.placeholder.com/150")!
    private(set) var isApproved: Bool = false // Make sure to handle this properly, as it's not in the sample data
    private(set) var content: String = ""
    private(set) var image: [String]?
    private(set) var hashtags: [String]?
    private(set) var muxPlaybackId: String = ""
    private(set) var muxAssetId: String = ""
    private(set) var videoUrl: String = ""
    private(set) var streamLink: String = ""
    private(set) var owner: OwnerModel?
    private(set) var setting: Setting?
    private(set) var estimatedCount: EstimatedCount?
    private(set) var metadata: PostMetadata?
    private(set) var createdAt: Date?
    private(set) var totalLikes: Int = 0
    private(set) var totalComments: Int = 0
    private(set) var totalShares: Int = 0
    private(set) var updatedAt: Date?

    required init?(map: ObjectMapper.Map) { }

    func mapping(map: ObjectMapper.Map) {
        id <- map["_id"]
        content <- map["content"]
        image <- map["images"]
        hashtags <- map["hashtags"]
        muxPlaybackId <- map["mux.playbackId"]
        muxAssetId <- map["mux.assetId"]
        videoUrl <- map["video.rawurl"]
        owner <- map["owner"]
        streamLink <- map["streamLink"]
        setting <- map["setting"]
        metadata <- map["metadata"]
        estimatedCount <- map["estimatedCount"]
        createdAt <- (map["createdAt"], ISODateTransform())
        totalLikes <- map["totalLikes"]
        totalComments <- map["totalComments"]
        totalShares <- map["totalShares"]
        updatedAt <- (map["updatedAt"], ISODateTransform())

        if let firstImage = image?.first, !firstImage.isEmpty {
            imageUrl = URL(string: firstImage)!
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

