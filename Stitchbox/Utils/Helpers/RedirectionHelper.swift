//
//  RedirectionHelper.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 27/10/2022.
//

import UIKit

struct RedirectionHelper {
    static func setRootViewController(storyboardName: String) {
        DispatchQueue.main.async {
            if let newVC = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController(),
               let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window.windows.first?.rootViewController = newVC
                window.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
    static func redirectToLogin() {
        setRootViewController(storyboardName: "Main")
    }
    
    static func redirectToDashboard() {
        setRootViewController(storyboardName: "Dashboard")
    }
}
