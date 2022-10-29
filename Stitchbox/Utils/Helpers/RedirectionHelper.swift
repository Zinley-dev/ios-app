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
            let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.windows.first?.rootViewController = dashboardVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

    static func redirectToDashboard() {
        DispatchQueue.main.async {
            let dashboardVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.windows.first?.rootViewController = dashboardVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
