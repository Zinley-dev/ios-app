//
//  AccountModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import Foundation
import RxSwift

struct Credentials {
    let username: String
    let password: String
}

struct Account : Codable {
    // MARK: - Tokens
    let refreshToken: String
    let accessToken: String
    
    // MARK: - Properties
    let avatarUrl: String
    let birthday: String
    let email: String
    let id: String
    let name: String
    let referalCode: String
    let userUID: String
    let username: String
    
    init(JSONbody: [String?: Any]?) throws {
        self.refreshToken = JSONbody?["refreshToken"] as? String ?? ""
        self.accessToken = JSONbody?["accessToken"] as? String ?? ""
        self.avatarUrl = JSONbody?["avatarUrl"] as? String ?? ""
        self.birthday = JSONbody?["birthday"] as? String ?? ""
        self.email = JSONbody?["email"] as? String ?? ""
        self.id = JSONbody?["id"] as? String ?? ""
        self.referalCode = JSONbody?["referalCode"] as? String ?? ""
        self.name = JSONbody?["name"] as? String ?? ""
        self.userUID = JSONbody?["userUID"] as? String ?? ""
        self.username = JSONbody?["username"] as? String ?? ""
    }
}
