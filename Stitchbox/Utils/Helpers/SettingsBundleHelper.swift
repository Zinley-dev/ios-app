//
//  SettingsBundleHelper.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 27/10/2022.
//

import Foundation

enum Environment: String {
    case production
    case testing
    case development
    var baseUrl: String {
        switch self {
        case .development:
            return Constants.URLs.development
        case .testing:
            return Constants.URLs.testing
        default:
            return Constants.URLs.production
        }
    }
}

struct SettingsBundleHelper {
    static let shared = SettingsBundleHelper()
    private init() {}
    var currentEnvironment: Environment {
        if let env = UserDefaults.standard.string(forKey: kEnvironment) {
            return Environment(rawValue: env.lowercased()) ?? Environment.production
        }
        return Environment.production
    }
}
