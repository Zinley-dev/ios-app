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

extension UIImage {
    enum ContentMode {
        case contentFill
        case contentAspectFill
        case contentAspectFit
    }
    
    func resize(withSize size: CGSize, contentMode: ContentMode = .contentAspectFill) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        
        switch contentMode {
        case .contentFill:
            return resize(withSize: size)
        case .contentAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        case .contentAspectFill:
            let aspectRatio = max(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        }
    }
    
    private func resize(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
