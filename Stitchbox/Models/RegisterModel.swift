//
//  RegisterModel.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/9/22.
//

import Foundation

struct RegisterModel{
    var userName = ""
    var password = ""
}

struct RegisterAccount: Codable {
//    // MARK: - Tokens
//    let refreshToken: String
//    let accessToken: String
//
    // MARK: - Properties
    let birthday: String
    let country: String
    let region: String
    let address1: String
    let address2: String
    let id: String
    let name: String
    let email: String
    let phone: String
    //let userUID: String
    //let username: String
    
    init(JSONbody: [String?: Any]?) throws {
        //self.refreshToken = JSONbody?["refreshToken"] as? String ?? ""
        //self.accessToken = JSONbody?["accessToken"] as? String ?? ""
        self.birthday = JSONbody?["dob"] as? String ?? ""
        self.country = JSONbody?["country"] as? String ?? ""
        self.region = JSONbody?["country"] as? String ?? ""
        self.address1 = JSONbody?["address1"] as? String ?? ""
        self.address2 = JSONbody?["address2"] as? String ?? ""
        self.id = JSONbody?["id"] as? String ?? ""
        self.name = JSONbody?["name"] as? String ?? ""
        self.email = JSONbody?["email"] as? String ?? ""
        self.phone = JSONbody?["phone"] as? String ?? ""
        //self.userUID = JSONbody?["userUID"] as? String ?? ""
        //self.username = JSONbody?["username"] as? String ?? ""
    }
}
