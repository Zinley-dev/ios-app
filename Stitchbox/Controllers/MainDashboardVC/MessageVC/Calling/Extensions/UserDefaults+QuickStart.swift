//
//  UserDefaults+QuickStart.swift
//  QuickStart Swift
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String, CaseIterable {
        case credential
        case voipPushToken
        case callHistories
        case designatedAppId
        
        var value: String { "Dual.LLC.Dual.\(self.rawValue.lowercased())" }
    }
    
}

extension UserDefaults {
   
    var voipPushToken: Data? {
        get { UserDefaults.standard.value(forKey: Key.voipPushToken.value) as? Data }
        set { UserDefaults.standard.set(newValue, forKey: Key.voipPushToken.value) }
    }
    
    var designatedAppId: String? {
        get { UserDefaults.standard.value(forKey: Key.designatedAppId.value) as? String }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.designatedAppId.value) }
    }
}

extension UserDefaults {
    func clear() {
        Key.allCases
            .filter { $0 != .voipPushToken && $0 != .designatedAppId }
            .map { $0.value }
            .forEach(UserDefaults.standard.removeObject)
    }
}

extension UserDefaults {
    func set<T: Codable>(object: T, forKey: String) {
        guard let jsonData = try? JSONEncoder().encode(object) else {
            self.removeObject(forKey: forKey)
            return
        }
        set(jsonData, forKey: forKey)
    }

    func get<T: Codable>(objectType: T.Type, forKey: String) -> T? {
        guard let result = value(forKey: forKey) as? Data else { return nil }
        return try? JSONDecoder().decode(objectType, from: result)
    }
}
