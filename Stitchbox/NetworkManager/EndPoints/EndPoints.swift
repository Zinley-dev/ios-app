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
    case register (params: [String:String])
}
extension UserApi: EndPointType {
    var module: String {
        return "/auth"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .phonelogin:
            return "/phone-login"
        case .phoneverify:
            return "/phone-verify"
        case .register:
            return "/register"
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
        case .register:
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
        case .register(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}



public enum SettingAPI {
    case getSettings
    case updateSettings (params: [String: Any])
}
extension SettingAPI: EndPointType {
    var module: String {
        return "/settings"
    }
    
    var path: String {
        switch self {
        case .getSettings:
            return "/"
        case .updateSettings:
            return "/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSettings:
            return .get
        case .updateSettings:
            return .patch
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getSettings:
            return .request
        case .updateSettings(let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}
