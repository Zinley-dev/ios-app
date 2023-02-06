//
//  postThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//
import Foundation
import ObjectMapper
class PostMetadata: Mappable {
  private(set) var contentmode: String = ""
    private(set) var height: CGFloat = 0.0
    private(set) var lenght: Int = 0
    private(set) var width: CGFloat = 0.0

  required init?(map: ObjectMapper.Map) {
    
  }
  
  func mapping(map: ObjectMapper.Map) {
    contentmode <- map["contentmode"]
    height <- map["height"]
    lenght <- map["lenght"]
    width <- map["width"]
  }
}

class PostModel: Mappable {
    var id: String = ""
  
  var imageUrl: URL = URL(string: "https://via.placeholder.com/150")!
  
  private(set) var content: String = ""
  private(set) var image: [String] = [""]
  private(set) var hashtags: [String] = [""]
  private(set) var muxPlaybackId: String = ""
  private(set) var muxAssetId: String = ""
  private(set) var videoUrl: String = ""
  private(set) var streamUrl: String = ""
  private(set) var setting: [String: Any] = ["": ""]
  private(set) var metadata: PostMetadata?
  private(set) var createdAt: Date?
  
  required init?(map: ObjectMapper.Map) {
    
  }
  
  func mapping(map: ObjectMapper.Map) {
    id <- map["_id"]
    content <- map["content"]
    image <- map["images"]
      hashtags <- map["hashtags"]
    muxPlaybackId <- map ["mux.playbackid"]
    muxAssetId <- map ["mux.assetid"]
    streamUrl <- map ["video.streamurl"]
    setting["allowcomment"] <- map["settings.allowcomment"]
    setting["mode"] <- map["settings.mode"]
    setting["languageCode"] <- map["settings.languageCode"]
    setting["mediaType"] <- map["settings.mediaType"]
    setting["isTitleGet"] <- map["settings.isTitleGet"]
    metadata <- map["metadata"]
      createdAt <- (map["createdat"], ISODateTransform())
    
    if image[0] != "" {
      imageUrl = URL(string: image[0])!
    } else {
      imageUrl = URL(string: "https://image.mux.com/\(muxPlaybackId)/thumbnail.png?width=400&height=200&fit_mode=smartcrop&time=0.025")!
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
