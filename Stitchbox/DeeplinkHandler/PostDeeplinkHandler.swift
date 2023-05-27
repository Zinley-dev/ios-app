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
        
        if _AppCoreData.userDataSource.value != nil {
            let id = url.lastPathComponent
            getPost(id: id)
        }
        
        
    }
    
    func getPost(id: String) {
        
        presentSwiftLoader()
        
        APIManager.shared.getPostDetail(postId: id) { [weak self] result in
            guard let self = self else { return }
            
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
                        print(data)
                        if let post = PostModel(JSON: data) {
                            
                            if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ReelVC") as? ReelVC {
                                
                                if let vc = UIViewController.currentViewController() {
                                    
                                    let nav = UINavigationController(rootViewController: RVC)
                                    
                                    // Set the user ID, nickname, and onPresent properties of UPVC
                                    RVC.posts = [post]
                                    
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
