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
      
      
      if _AppCoreData.userDataSource.value != nil {
          
          
          if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
                  if let queryItems = components.queryItems {
                      for queryItem in queryItems {
                          if queryItem.name == "id" {
                              if let id = queryItem.value {
                                  
                                  if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                                      
                                      if let vc = UIViewController.currentViewController() {
                                          
                                          let nav = UINavigationController(rootViewController: UPVC)

                                          // Set the user ID, nickname, and onPresent properties of UPVC
                                          UPVC.userId = id
                                          UPVC.onPresent = true

                                          // Customize the navigation bar appearance
                                          nav.navigationBar.barTintColor = .background
                                          nav.navigationBar.tintColor = .white
                                          nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                                          nav.modalPresentationStyle = .fullScreen
                                          vc.present(nav, animated: true, completion: nil)


                                      }
                                  }
                              }
                          }
                      }
                  }
              }

      }

  }
}
