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
        static let ApiHost = "domain-name.com"
    }
}

extension APIBuilder: BaseURL {
    static var baseURL: String {
        return "\(APIBuilder.APIBuilderConstants.ApiScheme)://\(APIBuilder.APIBuilderConstants.ApiHost)"
    }
}

public enum UserApi {
    case login
    case signup
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
        case .signup:
            return .request
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
