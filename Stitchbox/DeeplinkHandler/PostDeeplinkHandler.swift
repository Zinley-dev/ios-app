//
//  PostDeeplinkHandler.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation
import UIKit

final class PostDeeplinkHandler: DeeplinkHandlerProtocol {
  
  private weak var rootViewController: UIViewController?
  init(rootViewController: UIViewController?) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - DeeplinkHandlerProtocol
  
  func canOpenURL(_ url: URL) -> Bool {
    return url.absoluteString.hasPrefix("sb://posts")
  }
  func openURL(_ url: URL) {
    guard canOpenURL(url) else {
      return
    }
    
    // mock the navigation
    let viewController = UIViewController()
    print(url.path)
    viewController.view.backgroundColor = .orange
    rootViewController?.present(viewController, animated: true)
  }
}
