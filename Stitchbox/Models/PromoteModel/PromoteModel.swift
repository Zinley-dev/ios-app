//
//  File.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/18/23.
//

import Foundation

class PromoteModel {
    let id: String
    let description: String
    let createdAt: Date
    let endDate: Date
    let imageUrl: URL
    let originalLink: URL
    let isActive: Bool
    let maxMember: Int
    let name: String
    let startDate: Date
    let updatedAt: Date
    
    
    init?(data: [String: Any]) {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let id = data["_id"] as? String,
              let originalUrlString = data["originalLink"] as? String,
              let originalLink = URL(string: originalUrlString),
              let description = data["description"] as? String,
              let createdAtString = data["createdAt"] as? String,
              let createdAt = dateFormatter.date(from: createdAtString),
              let endDateString = data["endDate"] as? String,
              let endDate = dateFormatter.date(from: endDateString),
              let imageUrlString = data["img"] as? String,
              let imageUrl = URL(string: imageUrlString),
              let isActive = data["isActive"] as? Bool,
              let maxMember = data["maxMember"] as? Int,
              let name = data["name"] as? String,
              let startDateString = data["startDate"] as? String,
              let startDate = dateFormatter.date(from: startDateString),
              let updatedAtString = data["updatedAt"] as? String,
              let updatedAt = dateFormatter.date(from: updatedAtString)
        else {
            return nil
        }
        
        self.id = id
        self.description = description
        self.createdAt = createdAt
        self.endDate = endDate
        self.imageUrl = imageUrl
        self.originalLink = originalLink
        self.isActive = isActive
        self.maxMember = maxMember
        self.name = name
        self.startDate = startDate
        self.updatedAt = updatedAt
    }
}


