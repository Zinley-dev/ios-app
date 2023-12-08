//
//  PostDeeplinkHandler.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation
import UIKit

// MARK: - PostDeeplinkHandler Class
// Handles deep links that direct to specific posts in the application.

final class PostDeeplinkHandler: DeeplinkHandlerProtocol {
    
    // Reference to the root view controller for presenting new view controllers.
    private weak var rootViewController: UIViewController?

    // Initializes with an optional root view controller.
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol Implementation
    
    // Determines if the handler can open the given URL.
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("sb://post")
    }

    // Opens the URL if it's recognized as a post deep link.
    func openURL(_ url: URL) {
        guard canOpenURL(url), _AppCoreData.userDataSource.value != nil else {
            return
        }
        
        // Extracting the post ID from the URL.
        if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let id = queryItems.first(where: { $0.name == "id" })?.value {
            getPost(id: id)
        }
    }
    
    // Retrieves and processes the post based on its ID.
    private func getPost(id: String) {
        presentSwiftLoader()
        APIManager.shared.getPostDetail(postId: id) { [weak self] result in
            switch result {
            case .success(let apiResponse):
                self?.processPostData(apiResponse.body)
            case .failure(_):
                //print(error)
                Dispatch.main.async {
                    SwiftLoader.hide()
                }
            }
        }
    }
    
    // Process post data retrieved from the API and present the relevant view controller.
    private func processPostData(_ data: [String: Any]?) {
        guard let data = data, !data.isEmpty,
              let post = PostModel(JSON: data),
              let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedRootPostVC") as? SelectedRootPostVC,
              let vc = UIViewController.currentViewController() else {
            Dispatch.main.async {
                SwiftLoader.hide()
            }
            return
        }
        
        // Prepare and present the view controller for the selected post.
        Dispatch.main.async {
            if general_vc != nil {
                general_vc.viewWillDisappear(true)
            }
            RVC.onPresent = true
            RVC.posts = [post]
            RVC.startIndex = 0
            let nav = UINavigationController(rootViewController: RVC)
            nav.modalPresentationStyle = .fullScreen
            vc.present(nav, animated: true, completion: nil)
            SwiftLoader.hide()
        }
    }

    // Present a loader during API calls or processing.
    private func presentSwiftLoader() {
        SwiftLoader.show(animated: true)
    }
}
