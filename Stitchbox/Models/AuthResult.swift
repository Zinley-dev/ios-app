//
//  AuthResult.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 09/12/2022.
//

import Foundation

public struct AuthResult {
    public var idToken: String?
    // Apple
    public var providerID: String?
    public var rawNonce: String?
    // Google
    public var accessToken: String?
    
    public var name: String?
    public var email: String?
    public var phone: String?
    
    public init(idToken: String? = nil, providerID: String? = nil, rawNonce: String? = nil, accessToken: String? = nil, name: String? = nil, email: String? = nil, phone: String? = nil) {
        self.idToken = idToken
        self.providerID = providerID
        self.rawNonce = rawNonce
        self.accessToken = accessToken
        self.name = name
        self.email = email
        self.phone = phone
    }
    
}
