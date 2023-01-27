//
//  CreatePostRequest.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 28/01/2023.
//
/**
 
 
 {
 "content": "test",
 "hashtags": ["abc"],
 "images": [
 "https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png"
 ],
 "setting": {
 "allow_comment": true,
 "mode": 0
 },
 "tags": ["639e6786ab2572f58918d2e5"]
 }
 
 
 */
import Foundation
import ObjectMapper

class PostSetting: Mappable {
    
    private(set) var allow_comment: Bool?
    private(set) var mode: Int?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        allow_comment      <- map["allow_comment"]
        mode      <- map["mode"]
    }
    
    
}
class PostVideo: Mappable {
    private(set) var raw_url: String?
    private(set) var stream_url: String?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        raw_url      <- map["raw_url"]
        stream_url      <- map["stream_url"]
    }
}

class CreatePostRequest: Mappable {
    
    private(set) var content: String?
    private(set) var hashtags: [String]?
    private(set) var images: [String]?
    private(set) var video: PostVideo?
    private(set) var setting: [PostSetting]?
    private(set) var tags: [String]?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        content      <- map["content"]
        hashtags    <- map["hashtags"]
        images      <- map["images"]
        video      <- map["video"]
        setting    <- map["setting"]
        tags      <- map["tags"]
    }
}
