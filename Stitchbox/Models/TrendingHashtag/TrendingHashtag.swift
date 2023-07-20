//
//  TrendingHashtag.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/20/23.
//

import Foundation

struct TrendingHashtag: Codable {
    let views: Int
    let id: String
    let hashtag: String
    
    enum CodingKeys: String, CodingKey {
        case views = "view"
        case id = "_id"
        case hashtag = "name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.views = try container.decode(Int.self, forKey: .views)
        self.id = try container.decode(String.self, forKey: .id)
        self.hashtag = try container.decode(String.self, forKey: .hashtag)
    }
    
    init(from dictionary: [String: Any]) throws {
        guard let views = dictionary["view"] as? Int,
              let id = dictionary["_id"] as? String,
              let hashtag = dictionary["name"] as? String else {
            throw NSError(domain: "", code: 100, userInfo: nil)
        }
        self.views = views
        self.id = id
        self.hashtag = hashtag
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(views, forKey: .views)
        try container.encode(id, forKey: .id)
        try container.encode(hashtag, forKey: .hashtag)
    }
}
