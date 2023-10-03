//
//  SceneDelegate.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AppTrackingTransparency

enum RootType {
    case Main
    case Dashboard
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var lastInactiveTime: Date?

    lazy var deeplinkCoordinator : DeeplinkCoordinatorProtocol = {
      return DeeplinkCoordinator(handlers: [
        ProfileDeeplinkHandler(rootViewController: self.rootViewController),
        PostDeeplinkHandler(rootViewController: self.rootViewController)
      ])
    }()

    var rootViewController: UIViewController? {
      return window?.rootViewController
    }
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }

        deeplinkCoordinator.handleURL(firstUrl)

    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        CacheManager.shared.asyncRemoveExpiredObjects()
        
        do {
            let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 1GB
            try maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        CacheManager.shared.asyncRemoveExpiredObjects()

        // Maintain tmp directory
        do {
            let halfGigabyte = UInt64(0.5 * 1024 * 1024 * 1024)
            try maintainTmpDirectory(maxSizeInBytes: halfGigabyte)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }

        // Get current view controller
        guard let currentVC = UIViewController.currentViewController() else { return }
        
        // Calculate the two minutes ago time only once
        let twoMinsAgo = Date().addingTimeInterval(-120)

        // Check for each type of view controller
        if let startVC = currentVC as? StartViewController, startVC.player != nil {
            startVC.player?.play()
        } else if let parentVC = currentVC as? ParentViewController, parentVC.firstLoadDone {
            if let lastBackground = lastInactiveTime, lastBackground < twoMinsAgo {
                parentVC.seekToZero()
            }
            parentVC.loadFeed()
        } else if let selectedParentVC = currentVC as? SelectedParentVC {
            if let lastBackground = lastInactiveTime, lastBackground < twoMinsAgo {
                selectedParentVC.seekToZero()
            }
            selectedParentVC.resumeVideo()
        }

        // Reset application badge number and request a review
        UIApplication.shared.applicationIconBadgeNumber = 0
        requestAppleReview()
    }


    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        lastInactiveTime = Date()
        
        do {
            let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 1GB
            try maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }
        
        guard let currentVC = UIViewController.currentViewController() else { return }
        
        if let currentFeedVC = currentVC as? ParentViewController {
            if currentFeedVC.isFeed {
                
                if let index = currentFeedVC.feedViewController.currentIndex, !currentFeedVC.feedViewController.posts.isEmpty {
                    currentFeedVC.feedViewController.pauseVideoOnAppStage(index: index)
                }
                
            } else {
                
                if let index = currentFeedVC.stitchViewController.currentIndex, !currentFeedVC.stitchViewController.posts.isEmpty {
                    currentFeedVC.stitchViewController.pauseVideoOnAppStage(index: index)
                }
               
            }
        } else if let currentFeedVC = currentVC as? SelectedParentVC {
            if currentFeedVC.isRoot {
                
                if let index = currentFeedVC.selectedRootPostVC.currentIndex, !currentFeedVC.selectedRootPostVC.posts.isEmpty {
                    currentFeedVC.selectedRootPostVC.pauseVideoOnAppStage(index: index)
                }
                
            } else {
                
                if let index = currentFeedVC.stitchViewController.currentIndex, !currentFeedVC.stitchViewController.posts.isEmpty {
                    currentFeedVC.stitchViewController.pauseVideoOnAppStage(index: index)
                }
               
            }
        }
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        do {
            let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 1GB
            try maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        do {
            let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 1GB
            try maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }

    }
    
    func maintainTmpDirectory(maxSizeInBytes: UInt64) throws {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileManager = FileManager.default
        
        do {
            let tmpFiles = try fileManager.contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil, options: [])
            
            var totalSize: UInt64 = 0
            var fileAttributesMap: [URL: (UInt64, Date)] = [:]
            
            for fileURL in tmpFiles {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? UInt64,
                   let modificationDate = attributes[.modificationDate] as? Date {
                    totalSize += fileSize
                    fileAttributesMap[fileURL] = (fileSize, modificationDate)
                }
            }
            
            if totalSize > maxSizeInBytes {
                let sortedFiles = fileAttributesMap.sorted { $0.1.1 < $1.1.1 }
                
                var bytesToDelete = totalSize - maxSizeInBytes
                for (fileURL, (fileSize, _)) in sortedFiles {
                    try fileManager.removeItem(at: fileURL)
                    
                    if fileSize >= bytesToDelete {
                        break
                    }
                    
                    bytesToDelete -= fileSize
                }
            }
            
            print("Successfully maintained tmp directory.")
        } catch {
            print("Error maintaining tmp directory: \(error)")
            throw error
        }
    }




}

