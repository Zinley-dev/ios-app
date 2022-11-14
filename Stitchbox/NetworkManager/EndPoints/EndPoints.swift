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
    case signup(params: [String: Any]?)
}

extension UserApi: EndPointType {
    var module: String {
        return "/restApi"
    }

    var path: String {
        switch self {
        case .login:
            return "/api/mobile/auth/login"
        case .signup:
            return "/api/mobile/auth/register"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signup:
            return .post
        }
    }

    var task: HTTPTask {
        switch self {
        case .login:
            return .request
        case .signup(let params):
            return .requestParameters(parameters: params)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
