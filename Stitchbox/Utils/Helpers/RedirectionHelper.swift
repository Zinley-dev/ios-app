//
//  RedirectionHelper.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 27/10/2022.
//

import UIKit

struct RedirectionHelper {
    static func redirectToLogin() {
        DispatchQueue.main.async {
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController = loginVC
                windowScene.windows.first?.makeKeyAndVisible()
            }
        }
    }

    static func redirectToDashboard() {
        DispatchQueue.main.async {
            let dashboardVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController = dashboardVC
                windowScene.windows.first?.makeKeyAndVisible()
            }
        }
    }
}
