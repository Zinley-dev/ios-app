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
    
      let id = url.lastPathComponent
      getPost(id: id)
  }
    
    func getPost(id: String) {
        
            presentSwiftLoader()
            
            APIManager().getPostDetail(postId: id) { result in
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
                                
                                if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                                    
                                    if let vc = UIViewController.currentViewController() {
                                        
                                        let nav = UINavigationController(rootViewController: SPVC)

                                        SPVC.selectedPost = [post]
                                        SPVC.startIndex = 0
                                        SPVC.onPresent = true

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
