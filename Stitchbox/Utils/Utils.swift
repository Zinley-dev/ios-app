//
//  Utils.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import MobileCoreServices

enum UtilsAction {
    case cancel, close
    
    func create(on viewController: UIViewController) -> UIAlertAction {
        switch self {
        case .cancel:
            let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            return action
        case .close:
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            return action
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (exists index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//Random String Generator for Channel Url
extension String {
    static func randomUUIDString() -> String{
        return String(UUID().uuidString[..<String.Index(utf16Offset: 8, in: UUID().uuidString)])
    }
}
extension String {
  static func ~= (lhs: String, rhs: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
    let range = NSRange(location: 0, length: lhs.utf16.count)
    return regex.firstMatch(in: lhs, options: [], range: range) != nil
  }
}
