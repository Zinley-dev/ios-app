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
    enum logintype {
        case phoneLogin
        case normalLogin
    }
    var refreshToken: String
    var accessToken: String
    
    // MARK: - Properties
    var avatarUrl: String
    var email: String
    var about: String
    var id: String
    var name: String
    var phone: String
    var username: String
    
    init(JSONbody: [String?: Any]?, type: logintype) throws {
        if type == .normalLogin {
            self.refreshToken = JSONbody?["refresh-token"] as? String ?? ""
            self.accessToken = JSONbody?["token"] as? String ?? ""
            let user = JSONbody?["user"] as? [String?: Any]
            self.avatarUrl = user?["avatar"] as? String ?? ""
            self.email = user?["email"] as? String ?? ""
            self.id = user?["ID"] as? String ?? ""
            self.name = user?["name"] as? String ?? ""
            self.about = user?["about"] as? String ?? ""
            self.phone = user?["phone"] as? String ?? ""
            self.username = user?["username"] as? String ?? ""
        } else if type == .phoneLogin {
            self.refreshToken = JSONbody?["refresh-token"] as? String ?? ""
            self.accessToken = JSONbody?["token"] as? String ?? ""
            let user = JSONbody?["user"] as? [String: Any]? ?? ["":""]
            self.avatarUrl = user?["avatar"] as? String ?? ""
            self.email = user?["email"] as? String ?? ""
            self.id = user?["ID"] as? String ?? ""
            self.name = user?["name"] as? String ?? ""
            self.about = user?["about"] as? String ?? ""
            self.phone = user?["phone"] as? String ?? ""
            self.username = user?["username"] as? String ?? ""
        } else {
            self.refreshToken = ""
            self.accessToken = ""
            self.avatarUrl =  ""
            self.email = ""
            self.id = ""
            self.name = ""
            self.username = ""
            self.about = ""
            self.phone = ""
        }
    }
}
