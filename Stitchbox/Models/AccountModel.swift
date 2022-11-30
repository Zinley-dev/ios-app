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
    var birthday: String
    var email: String
    var id: String
    var name: String
    var referralCode: String
    var userUID: String
    var username: String
    
    init(JSONbody: [String?: Any]?, type: logintype) throws {
        if type == .normalLogin {
            self.refreshToken = JSONbody?["refreshToken"] as? String ?? ""
            self.accessToken = JSONbody?["accessToken"] as? String ?? ""
            self.avatarUrl = JSONbody?["avatarUrl"] as? String ?? ""
            self.birthday = JSONbody?["birthday"] as? String ?? ""
            self.email = JSONbody?["email"] as? String ?? ""
            self.id = JSONbody?["id"] as? String ?? ""
            self.referralCode = JSONbody?["referralCode"] as? String ?? ""
            self.name = JSONbody?["name"] as? String ?? ""
            self.userUID = JSONbody?["userUID"] as? String ?? ""
            self.username = JSONbody?["username"] as? String ?? ""
        } else if type == .phoneLogin {
            self.refreshToken = JSONbody?["refreshToken"] as? String ?? ""
            self.accessToken = JSONbody?["token"] as? String ?? ""
            let userInfo = JSONbody?["user"] as? [String: Any]? ?? ["":""]
            self.avatarUrl =  userInfo?["avatar"]  as? String ?? ""
            self.birthday = userInfo?["bod"] as? String ?? ""
            self.email = userInfo?["email"] as? String ?? ""
            self.id = userInfo?["_id"] as? String ?? ""
            self.referralCode = userInfo?["referralCode"] as? String ?? ""
            self.name = userInfo?["name"] as? String ?? ""
            self.userUID = userInfo?["firebaseId"] as? String ?? ""
            self.username = userInfo?["username"] as? String ?? ""
            
        } else {
            self.refreshToken = ""
            self.accessToken = ""
            self.avatarUrl =  ""
            self.birthday = ""
            self.email = ""
            self.id = ""
            self.referralCode = ""
            self.name = ""
            self.userUID = ""
            self.username = ""
        }
    }
}
