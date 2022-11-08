//
//  UserAuthenticationModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/8/22.
//

import Foundation
class Account {
    private var _id: String {get}
    private var dob: String {get}
    private var country: String {get}
    private var region: String {get}
    private var address1: String {get}
    private var address2: String {get}
    private var name: String {get}
    private var email: String {get}
    private var phone: String {get}
    private var password: String {get}
    private var status: String {get}
    private var createdAt: String {get}
    private var updatedAt: String {get}
    
    init(account: [String: Any]) {
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
    private var refreshToken: String {get, set}
    private var accessToken: String {get, set}
    private var account: Account {get, set}
    
    init(refreshToken: String, accessToken: String, account: [String: Any]) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.account = Account(account)
    }
    
}
