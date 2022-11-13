//
//  EndPoints.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

protocol BaseURL {
    static var baseURL: String { get }
}

enum APIBuilder {
    struct APIBuilderConstants {
        static let ApiScheme = "https"
        static let ApiHost = "api.stitchbox.dev"
    }
}

extension APIBuilder: BaseURL {
    static var baseURL: String {
        return "\(APIBuilder.APIBuilderConstants.ApiScheme)://\(APIBuilder.APIBuilderConstants.ApiHost)"
    }
}

public enum MobileAuthApi {
    case login (email: String, password: String)
}

public enum UserApi {
    case phonelogin (phone: String, countryCode: String, via: String)
    case phoneverify (phone: String, countryCode: String, code: String)
}
extension UserApi: EndPointType {
    var module: String {
        return "/api/user"
    }
    
    var path: String {
        switch self {
        case .phonelogin:
            return "/sms/login"
        case .phoneverify:
            return "/sms/login/verify"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .phonelogin:
            return .get
        case .phoneverify:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .phonelogin:
            return .request
        case .phoneverify:
            return .request
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case let .phonelogin(phone, countrycode, via):
            return ["phone": phone,
                    "countryCode": countrycode,
                    "via": via]
        case let .phoneverify(phone, countrycode, code):
            return ["phone": phone,
                    "countryCode": countrycode,
                    "code": code]
        }
        
    }
}

extension MobileAuthApi: EndPointType {
    var module: String {
        return "/api/user/"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/mobile/auth/login"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login:
            return .request
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case let .login(email, password):
            return ["email": email,
                    "password": password]
        }
        
    }
}
