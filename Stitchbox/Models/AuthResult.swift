//
//  AuthResult.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 09/12/2022.
//

import ObjectMapper

class AuthResult: Mappable {
    
    
    private(set) var idToken: String?
    // Apple
    private(set) var providerID: String?
    private(set) var rawNonce: String?
    // Google
    private(set) var accessToken: String?
    
    private(set) var name: String?
    private(set) var email: String?
    private(set) var phone: String?
    private(set) var avatar: String?
    
    required init?(map: ObjectMapper.Map) {
        idToken <- map["idToken"]
        providerID <- map["providerID"]
        rawNonce <- map["rawNonce"]
        accessToken <- map["token"]
        name <- map["name"]
        email <- map["email"]
        phone <- map["phone"]
        avatar <- map["avatar"]
    }
    
    func mapping(map: ObjectMapper.Map) {
        
    }
    public init(idToken: String? = nil, providerID: String? = nil, rawNonce: String? = nil, accessToken: String? = nil, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: String?) {
        self.idToken = idToken
        self.providerID = providerID
        self.rawNonce = rawNonce
        self.accessToken = accessToken
        self.name = name
        self.email = email
        self.phone = phone
        self.avatar = avatar
    }
    
    
}
