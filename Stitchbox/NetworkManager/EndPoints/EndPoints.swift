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
    case login
    case signup(params: [String: Any]?)
}

public enum MobileApi {
    case login
    case register(params: [String: Any]?)
}

extension UserApi: EndPointType {
    var module: String {
        return "/user"
    }

    var path: String {
        switch self {
        case .login:
            return "/login"
        case .signup:
            return "/signup"
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

extension MobileApi: EndPointType {
    var module: String {
        return "/mobile"
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .register:
            return .post
        }
    }

    var task: HTTPTask {
        switch self {
        case .login:
            return .request
        case .register(let params):
            return .requestParameters(parameters: params)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
