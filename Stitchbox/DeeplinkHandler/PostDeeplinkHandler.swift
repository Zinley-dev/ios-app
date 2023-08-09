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
        return url.absoluteString.hasPrefix("sb://post")
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
                                    getPost(id: id)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    func getPost(id: String) {
        
          presentSwiftLoader()

          APIManager.shared.getPostDetail(postId: id) { result in
           
              switch result {
              case .success(let apiResponse):
                  guard let data = apiResponse.body else {
                      Dispatch.main.async {
                          SwiftLoader.hide()
                      }
                    return
                  }
                 
                  if !data.isEmpty {
                      Dispatch.main.async {
                          SwiftLoader.hide()
                          
                          if let post = PostModel(JSON: data) {
                              
                              if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                                  
                                  if let vc = UIViewController.currentViewController() {
                                  

                                      if general_vc != nil {
                                          general_vc.viewWillDisappear(true)
                                      }
                                      
                                      RVC.onPresent = true
                                      
                                      let nav = UINavigationController(rootViewController: RVC)

                                      // Set the user ID, nickname, and onPresent properties of UPVC
                                      RVC.posts = [post]
                                      RVC.startIndex = 0
                                     
                                      // Customize the navigation bar appearance
                                      nav.navigationBar.barTintColor = .white
                                      nav.navigationBar.tintColor = .black
                                      nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                                      nav.modalPresentationStyle = .fullScreen
                                      vc.present(nav, animated: true, completion: nil)


                                  }
                              }
                              
                          }
                          
                      }
                      
                  } else {
                      Dispatch.main.async {
                          SwiftLoader.hide()
                      }
                  }

              case .failure(let error):
                  print(error)
                  Dispatch.main.async {
                      SwiftLoader.hide()
                  }
                  
          }
      }
        
        
    }
    
    
    
    
    
}
