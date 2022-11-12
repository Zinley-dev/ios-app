//
//  AccountModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import Foundation
import Unbox

final class Account: Unboxable {
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
   
   init(unboxer: Unboxer) throws {
       self.refreshToken = try unboxer.unbox(key: "refreshToken")
       self.accessToken = try unboxer.unbox(key: "accessToken")
       self._id = try unboxer.unbox(keyPath: "account._id")
       self.dob = try unboxer.unbox(keyPath: "account.dob")
       self.country = try unboxer.unbox(keyPath: "account.country")
       self.region = try unboxer.unbox(keyPath: "account.region")
       self.address1 = try unboxer.unbox(keyPath: "account.address1")
       self.address2 = try unboxer.unbox(keyPath: "account.address2")
       self.name = try unboxer.unbox(keyPath: "account.name")
       self.email = try unboxer.unbox(keyPath: "account.email")
       self.phone = try unboxer.unbox(keyPath: "account.phone")
       self.password = try unboxer.unbox(keyPath: "account.password")
       self.status = try unboxer.unbox(keyPath: "account.status")
       self.createdAt = try unboxer.unbox(keyPath: "account.createdAt")
       self.updatedAt = try unboxer.unbox(keyPath: "account.updatedAt")
   }
}
