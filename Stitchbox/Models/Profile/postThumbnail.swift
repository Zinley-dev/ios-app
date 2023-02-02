//
//  postThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//
import Foundation
import ObjectMapper

class postThumbnail: Mappable {
  let id = UUID()

  var imageUrl: URL = URL(string: "https://via.placeholder.com/150")!
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
    
    if image[0] != "" {
      imageUrl = URL(string: image[0])!
    } else {
      imageUrl = URL(string: "https://image.mux.com/\(muxPlaybackId)/thumbnail.png?width=400&height=200&fit_mode=smartcrop&time=1")!
    }
  }
}
extension postThumbnail: Hashable {
  static func == (lhs: postThumbnail, rhs: postThumbnail) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
