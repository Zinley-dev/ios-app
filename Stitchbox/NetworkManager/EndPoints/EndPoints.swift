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
    case resetpassword (params: [String:String])
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
        case .resetpassword:
            return "/reset-password"
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
        case .resetpassword:
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
        case .resetpassword(params: let params):
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
public enum UserInfoAPI {
    case getme
    case updateme (params: [String: Any])
    case changepassword (params: [String: Any])
    case uploadavatar (params: [String: Any])
    case uploadcover (params: [String: Any])

}
extension UserInfoAPI: EndPointType {
    var module: String {
        return "/user"
    }
    
    var path: String {
        switch self {
        case .getme:
            return "/me"
        case .updateme:
            return "/me"
        case .changepassword:
            return "/change-password"
        case .uploadcover:
            return "/upload-cover"
        case .uploadavatar:
            return "/upload-avatar"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getme:
            return .get
        case .updateme:
            return .patch
        case .changepassword:
            return .post
        case .uploadcover:
            return .post
        case .uploadavatar:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getme:
            return .request
        case .updateme(let params):
            return .requestParameters(parameters: params)
        case .changepassword(params: let params):
            return .requestParameters(parameters: params)
        case .uploadavatar(params: let params):
            return .requestParameters(parameters: params)
        case .uploadcover(params: let params):
            return .requestParameters(parameters: params)
        }
    }
    
    var headers: [String: String]? {
        return ["Authorization": _AppCoreData.userSession.value!.accessToken]
    }
}
