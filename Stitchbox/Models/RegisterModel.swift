//
//  RegisterModel.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/9/22.
//

import Foundation

struct RegisterModel {
    var userName = ""
    var password = ""
}

struct RegisterAccount: Codable {
    // MARK: - Tokens
    let refreshToken: String
    let accessToken: String
    //
    // MARK: - Account
    let device: String
    let accountVerified: String
    let _id: String
    let name: String
    let username: String
    let password: String
    let status: String
    let createdAt: String
    let updatedAt: String
    
    init(JSONbody: [String?: Any]?) throws {
        self.refreshToken = JSONbody?["refreshToken"] as? String ?? ""
        self.accessToken = JSONbody?["accessToken"] as? String ?? ""
        self.device = JSONbody?["device"] as? String ?? ""
        self.accountVerified = JSONbody?["accountVerified"] as? String ?? ""
        self._id = JSONbody?["_id"] as? String ?? ""
        self.name = JSONbody?["name"] as? String ?? ""
        self.username = JSONbody?["username"] as? String ?? ""
        self.password = JSONbody?["password"] as? String ?? ""
        self.status = JSONbody?["status"] as? String ?? ""
        self.createdAt = JSONbody?["createdAt"] as? String ?? ""
        self.updatedAt = JSONbody?["updatedAt"] as? String ?? ""

    }
}
