//
//  ProfileDeeplinkHandler.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation

import UIKit

final class ProfileDeeplinkHandler: DeeplinkHandlerProtocol {
  
  private weak var rootViewController: UIViewController?
  init(rootViewController: UIViewController?) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - DeeplinkHandlerProtocol
  
  func canOpenURL(_ url: URL) -> Bool {
    return url.absoluteString.hasPrefix("sb://account")
  }
  
  func openURL(_ url: URL) {
    guard canOpenURL(url) else {
      return
    }
    
    // mock the navigation
    let viewController = UIViewController()
    print(url.path)
    viewController.title = "Account"
    viewController.view.backgroundColor = .yellow
    rootViewController?.present(viewController, animated: true)
  }
}
