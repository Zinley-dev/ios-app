//
//  UIViewController+Utils.swift
//  SendBird-iOS
//
//  Created by khoi Nguyen on 10/12/18.
//

import UIKit

extension DispatchQueue {
    /// Executes a block safely on the main thread, avoiding deadlocks if already on the main thread.
    static func syncSafe(execute block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }

    /// Executes a block that returns a value safely on the main thread, avoiding deadlocks if already on the main thread.
    static func syncSafe<T>(execute work: () -> T) -> T {
        if Thread.isMainThread {
            return work()
        } else {
            return DispatchQueue.main.sync {
                work()
            }
        }
    }
}

extension UIViewController {

    public static func findBestViewController(_ vc: UIViewController) -> UIViewController {
        return DispatchQueue.syncSafe(execute: {
            if let presentedViewController = vc.presentedViewController {
                return findBestViewController(presentedViewController)
            } else if let svc = vc as? UISplitViewController, let lastVC = svc.viewControllers.last {
                return findBestViewController(lastVC)
            } else if let svc = vc as? UINavigationController, let topVC = svc.topViewController {
                return findBestViewController(topVC)
            } else if let svc = vc as? UITabBarController, let selectedVC = svc.selectedViewController {
                return findBestViewController(selectedVC)
            } else {
                return vc
            }
        })
    }
    
    public static func currentViewController() -> UIViewController? {
        return DispatchQueue.syncSafe(execute: {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return nil
            }
            return findBestViewController(rootViewController)
        })
    }
}
