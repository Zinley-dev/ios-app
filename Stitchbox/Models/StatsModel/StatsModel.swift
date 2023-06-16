//
//  StatsModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/21/23.
//

import Foundation

struct Stats: Codable {
    let like: Statistic
    let view: Statistic
    let streamLink: Statistic
    
    enum CodingKeys: String, CodingKey {
        case like
        case view
        case streamLink
    }
}

struct Statistic: Codable {
    let total: Int
    let totalInDay: Int
    let totalInHour: Int
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalInDay
        case totalInHour
    }
}

