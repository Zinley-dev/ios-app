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
        static let ApiHost = "api.stitchbox.dev/v1"
    }
}

extension APIBuilder: BaseURL {
    static var baseURL: String {
        return "\(APIBuilder.APIBuilderConstants.ApiScheme)://\(APIBuilder.APIBuilderConstants.ApiHost)"
    }
}

public enum UserApi {
    case login (params: [String:String])
    case phonelogin (params: [String:String])
    case phoneverify (params: [String:String])
    case roomIDRequest (params: [String:String])
}
extension UserApi: EndPointType {
    var module: String {
        switch self {
        case .login:
            return "/auth"
        case .phonelogin:
            return "/auth"
        case .phoneverify:
            return "/auth"
        case .roomIDRequest:
            return "/chat"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .phonelogin:
            return "/phone-login"
        case .phoneverify:
            return "/phone-verify"
        case .roomIDRequest:
            return "/call"
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
        case .roomIDRequest:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let params):
            return .requestParameters(parameters: params)
        case .phonelogin(let params):
            return .requestParameters(parameters: params)
        case .phoneverify(let params):
            return .requestParameters(parameters: params)
        case .roomIDRequest(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
