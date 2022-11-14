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

final class Account {
    // MARK: - Tokens
    let refreshToken: String
    let accessToken: String
    
    // MARK: - Properties
    let _id: String
    let dob: String
    let country: String
    let region: String
    let address1: String
    let address2: String
    let name: String
    let email: String
    let phone: String
    let password: String
    let status: String
    let createdAt: String
    let updatedAt: String
    
    init(JSONbody: [String: Any]?) throws {
        self.refreshToken = JSONbody?["refreshToken"] as! String
        self.accessToken = JSONbody?["refreshToken"] as! String
        let account = JSONbody?["account"] as! [String: Any]
        self._id = account["_id"] as! String
        self.dob = account["dob"] as! String
        self.country = account["country"] as! String
        self.region = account["region"] as! String
        self.address1 = account["address1"] as! String
        self.address2 = account["address2"] as! String
        self.name = account["name"] as! String
        self.email = account["email"] as! String
        self.phone = account["phone"] as! String
        self.password = account["password"] as! String
        self.status = account["status"] as! String
        self.createdAt = account["createdAt"] as! String
        self.updatedAt = account["updatedAt"] as! String
    }
}
