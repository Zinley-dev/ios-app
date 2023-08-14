//
//  VideoIssueModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/13/23.
//

import Foundation
import ObjectMapper

class VideoIssueModel: Mappable {
    private(set) var id: String = ""
    private(set) var userId: String = ""
    private(set) var videoUrl: String = ""
    private(set) var description: String = ""
    private(set) var status: IssueStatus = .pending
    private(set) var reportedAt: Date?
    private(set) var resolvedAt: Date?
    private(set) var reason: IssueReason?
    private(set) var actionTaken: IssueAction?

    required init?(map: ObjectMapper.Map) {}

    func mapping(map: ObjectMapper.Map) {
        id <- map["_id"]
        userId <- map["userId"]
        videoUrl <- map["videoUrl"]
        description <- map["description"]
        status <- map["status"]
        reportedAt <- (map["reportedAt"], ISODateTransform())
        resolvedAt <- (map["resolvedAt"], ISODateTransform())
        reason <- map["reason"]
        actionTaken <- map["actionTaken"]
    }
}

enum IssueStatus: String {
    case pending = "pending"
    case resolved = "resolved"
    // Add other statuses as needed
}

enum IssueReason: String {
    case copyright = "copyright"
    case explicitContent = "explicit content"
    // Add other reasons as needed
}

enum IssueAction: String {
    case deleted = "deleted"
    case suspended = "suspended"
    // Add other actions as needed
}

extension VideoIssueModel: Hashable {
    static func == (lhs: VideoIssueModel, rhs: VideoIssueModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
