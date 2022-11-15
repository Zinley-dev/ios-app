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
        static let ApiHost = "dual-api.tek4.vn/api"
    }
}

extension APIBuilder: BaseURL {
    static var baseURL: String {
        return "\(APIBuilder.APIBuilderConstants.ApiScheme)://\(APIBuilder.APIBuilderConstants.ApiHost)"
    }
}


public enum UserApi {
    case login (username: String, password: String)
    case phonelogin (phone: String, countryCode: String, via: String)
    case phoneverify (phone: String, countryCode: String, code: String)
}
extension UserApi: EndPointType {
    var module: String {
        return "/user"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .phonelogin:
            return "/sms/login"
        case .phoneverify:
            return "/sms/login/verify"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .phonelogin:
            return .post
        case .phoneverify:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let username, let password):
            return .requestParameters(parameters: ["username": username,
                                                   "password": password])
        case .phonelogin(let phone, let countrycode, let via):
            print(["phone": phone,
                   "countryCode": countrycode,
                   "via": via])
            return .requestParameters(parameters: ["phone": phone,
                    "countryCode": countrycode,
                    "via": via])
        case .phoneverify(let phone, let countrycode, let code):
            return .requestParameters(parameters: ["phone": phone,
                    "countryCode": countrycode,
                    "code": code])
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
