//
//  RedirectionHelper.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 27/10/2022.
//

import UIKit

/// A utility struct for handling redirections within the app.
struct RedirectionHelper {
    
    /// Sets the root view controller from a specified storyboard.
    /// - Parameter storyboardName: The name of the storyboard to use.
    static func setRootViewController(storyboardName: String) {
        DispatchQueue.main.async {
            guard let newVC = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() else {
                print("Failed to instantiate view controller from storyboard: \(storyboardName)")
                return
            }

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = newVC
                window.makeKeyAndVisible()
            } else {
                print("Unable to access the windowScene or its first window.")
            }
        }
    }

    /// Redirects to the login view controller.
    static func redirectToLogin() {
        setRootViewController(storyboardName: "Main")
    }

    /// Redirects to the dashboard view controller.
    static func redirectToDashboard() {
        setRootViewController(storyboardName: "Dashboard")
    }
}

