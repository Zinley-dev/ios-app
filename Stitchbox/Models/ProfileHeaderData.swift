//
//  ProfileHeaderData.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import Foundation

struct ProfileHeaderData: Hashable {
    var name: String
    var accountType: String
    var postCount: Int = 0
    var followers: Int = 0
    var following: Int = 0
    var fistBumped: Int = 0
    var discord: String?
    var about: String?
    var cover: String?
    var avatar: String?
}
