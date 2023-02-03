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
  let id = UUID()
  
  var imageUrl: URL = URL(string: "https://via.placeholder.com/150")!
  private(set) var content: String = ""
  private(set) var image: [String] = [""]
  private(set) var muxPlaybackId: String = ""
  private(set) var muxAssetId: String = ""
  private(set) var videoUrl: String = ""
  private(set) var streamUrl: String = ""
  private(set) var setting: [String: Any] = ["": ""]
  private(set) var metadata: PostMetadata?
  
  required init?(map: ObjectMapper.Map) {
    
  }
  
  func mapping(map: ObjectMapper.Map) {
    setting <- map["content"]
    content <- map["content"]
    image <- map["images"]
    muxPlaybackId <- map ["mux.playbackid"]
    muxAssetId <- map ["mux.assetid"]
    streamUrl <- map ["video.streamurl"]
    setting["allowcomment"] <- map["setting.allowcomment"]
    setting["mode"] <- map["setting.mode"]
    metadata <- map["metadata"]
    
    if image[0] != "" {
      imageUrl = URL(string: image[0])!
    } else {
      imageUrl = URL(string: "https://image.mux.com/\(muxPlaybackId)/thumbnail.png?width=400&height=200&fit_mode=smartcrop&time=1")!
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
