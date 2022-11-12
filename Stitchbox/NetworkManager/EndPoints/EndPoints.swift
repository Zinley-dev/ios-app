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

public enum UserApi {
    case login
    case normallogin (email: String, password: String)
    case signup
    case phonelogin (phone: String, countryCode: String, via: String)
    case phoneverify (phone: String, countryCode: String, code: String)
}

extension UserApi: EndPointType {
    var module: String {
        return "/restApi"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .signup:
            return "/signup"
        case .normallogin:
            return "/api/mobile/auth/login"
        case .phonelogin:
            return "/api/user/sms/login"
        case .phoneverify:
            return "/api/user/sms/login/verify"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signup:
            return .post
        case .normallogin:
            return .get
        case .phonelogin:
            return .get
        case .phoneverify:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login:
            return .request
        case .signup:
            return .request
        case .normallogin:
            return .request
        case .phonelogin:
            return .request
        case .phoneverify:
            return .request
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case let .normallogin(email, password):
            return ["email": email,
                    "password": password]
        case let .phonelogin(phone, countrycode, via):
            return ["phone": phone,
                    "countryCode": countrycode,
                    "via": via]
        case let .phoneverify(phone, countrycode, code):
            return ["phone": phone,
                    "countryCode": countrycode,
                    "code": code]
        default:
           return nil
        }
        
    }
}
