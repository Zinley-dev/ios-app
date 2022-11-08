//
//  UserAuthenticationModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/8/22.
//

import Foundation
class Account {
    var _id: String?
    var dob: String?
    var country: String?
    var region: String?
    var address1: String?
    var address2: String?
    var name: String?
    var email: String?
    var phone: String?
    var password: String?
    var status: String?
    var createdAt: String?
    var updatedAt: String?

    init(account: [String: String]) {
        self._id = account["_id"];
        self.dob = account["dob"];
        self.country = account["country"];
        self.region = account["region"];
        self.address1 = account["address1"];
        self.address2 = account["address2"];
        self.name = account["name"];
        self.email = account["email"];
        self.phone = account["phone"];
        self.password = account["password"];
        self.status = account["status"];
        self.createdAt = account["createdAt"];
        self.updatedAt = account["updatedAt"];
    }
}

final class UserAuthenticationModel {
    var refreshToken: String
    var accessToken: String
    var account: Account

    init(refreshToken: String, accessToken: String, account: [String: String]) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.account = Account(account: account)
    }

}
