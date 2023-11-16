//
//  ProfileDeeplinkHandler.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation
import UIKit

// MARK: - ProfileDeeplinkHandler Class
// This class handles deep links specifically related to profile navigation in the app.

final class ProfileDeeplinkHandler: DeeplinkHandlerProtocol {
  
  // Reference to the root view controller for presenting new view controllers.
  private weak var rootViewController: UIViewController?

  // Initializes with an optional root view controller.
  init(rootViewController: UIViewController?) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - DeeplinkHandlerProtocol
  
  // Determines if the handler can open the given URL.
  func canOpenURL(_ url: URL) -> Bool {
    // Check if the URL matches the pattern for profile deep links.
    return url.absoluteString.hasPrefix("sb://account")
  }
  
  // Opens the URL if it's recognized as a profile deep link.
  func openURL(_ url: URL) {
    guard canOpenURL(url) else {
      return
    }
    
    // Logic for handling a recognized profile deep link.
    if _AppCoreData.userDataSource.value != nil {
      if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
         let queryItems = components.queryItems {
        for queryItem in queryItems {
          if queryItem.name == "id", let id = queryItem.value {
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
               let vc = UIViewController.currentViewController() {
              // Create and configure a navigation controller for the profile view.
              let nav = UINavigationController(rootViewController: UPVC)
              UPVC.userId = id
              UPVC.onPresent = true
              configureNavigationBar(nav)
              presentProfileViewController(nav, on: vc)
            }
          }
        }
      }
    }
  }
  
  // Configures the appearance of the navigation bar.
  private func configureNavigationBar(_ nav: UINavigationController) {
    nav.navigationBar.barTintColor = .white
    nav.navigationBar.tintColor = .black
    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
  }

  // Presents the profile view controller.
  private func presentProfileViewController(_ nav: UINavigationController, on viewController: UIViewController) {
    nav.modalPresentationStyle = .fullScreen
    viewController.present(nav, animated: true, completion: nil)
  }
}
