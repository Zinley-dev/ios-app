//
//  MyPost.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 02/02/2023.
//

import Foundation
import ObjectMapper

class MyPost: Mappable {
  private(set) var content: String = ""
  private(set) var image: [String] = [""]
  private(set) var muxPlaybackId: String = ""
  private(set) var muxAssetId: String = ""
  private(set) var videoUrl: String = ""
  private(set) var streamUrl: String = ""
  
  required init?(map: ObjectMapper.Map) {
    
  }
  
  func mapping(map: ObjectMapper.Map) {
    content <- map["content"]
    image <- map["images"]
    muxPlaybackId <- map ["mux.playbackid"]
    muxAssetId <- map ["mux.assetid"]
    streamUrl <- map ["video.streamurl"]
  }
}
