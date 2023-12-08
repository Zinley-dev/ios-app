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

    // Lazy initialization of a DeeplinkCoordinator with specific handlers
    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
        return DeeplinkCoordinator(handlers: [
            ProfileDeeplinkHandler(rootViewController: self.rootViewController),
            PostDeeplinkHandler(rootViewController: self.rootViewController)
        ])
    }()

    // Computed property to access the root view controller of the window
    var rootViewController: UIViewController? {
        return window?.rootViewController
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }

        // Perform additional configuration here if needed
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Handle URL contexts for deep linking
        guard let firstUrl = URLContexts.first?.url else {
            return
        }

        // Use the deeplink coordinator to handle the URL
        deeplinkCoordinator.handleURL(firstUrl)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded
        // (see `application:didDiscardSceneSessions` instead).

        // Remove expired objects from cache
        CacheManager.shared.asyncRemoveExpiredObjects()
        
        // Maintain the temporary directory size
        cleanTemporaryDirectory()
    }


    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Restart any tasks that were paused (or not yet started) when the scene was inactive.

        // Remove expired objects from cache
        CacheManager.shared.asyncRemoveExpiredObjects()

        // Maintain the temporary directory size
        cleanTemporaryDirectory()

        // Get the current view controller
        guard let currentVC = UIViewController.currentViewController() else { return }
        
        // Calculate the time two minutes ago
        let twoMinsAgo = Date().addingTimeInterval(-120)

        // Handling specific logic based on the type of the current view controller
        if let startVC = currentVC as? StartViewController {
            startVC.player?.play()  // Resume playback if player exists
        } else if let feedVC = currentVC as? FeedViewController {
            // For FeedViewController, check if it's the first load and handle background time
            if feedVC.firstLoadDone {
                if let lastBackground = lastInactiveTime, lastBackground < twoMinsAgo {
                    //feedVC.seekToZero(index: feedVC.currentIndex ?? 0)  // Safely unwrap currentIndex
                }
                //feedVC.loadFeed()
            }
        } else if let rootVC = currentVC as? SelectedRootPostVC {
            if rootVC.completedLoading {
                //rootVC.resumeVideo()
            }
        }

        // Reset the application's badge number and request an Apple review
        UIApplication.shared.applicationIconBadgeNumber = 0
        requestAppleReview()
    }



    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).

        // Record the time of inactivity
        lastInactiveTime = Date()

        // Maintain the size of the temporary directory
        cleanTemporaryDirectory()

        // Pause video in the current FeedViewController, if applicable
        if let currentVC = UIViewController.currentViewController(),
           let currentFeedVC = currentVC as? FeedViewController {
            currentFeedVC.pauseVideoOnAppStage(index: currentFeedVC.currentIndex!)
        }
    }


    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Undo the changes made on entering the background.
        cleanTemporaryDirectory()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Save data, release shared resources, and store scene-specific state information.
        cleanTemporaryDirectory()
    }
    
    func cleanTemporaryDirectory() {
        let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 0.5 GB
        do {
            try FileManager.default.maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }
    }



}


extension FileManager {

    /// Maintains the temporary directory by ensuring it does not exceed a specified size limit.
    /// If the total size of files in the temporary directory exceeds `maxSizeInBytes`, the oldest files are deleted first until the directory size is within the limit.
    /// - Parameter maxSizeInBytes: The maximum allowed size of the temporary directory in bytes.
    /// - Throws: An error if file operations fail.
    func maintainTmpDirectory(maxSizeInBytes: UInt64) throws {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        
        do {
            // Fetch the contents of the temporary directory
            let tmpFiles = try contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil, options: [])
            
            var totalSize: UInt64 = 0
            var fileAttributesMap: [URL: (UInt64, Date)] = [:]
            
            // Iterate over each file in the directory
            for fileURL in tmpFiles {
                let attributes = try attributesOfItem(atPath: fileURL.path)
                
                // Extract file size and modification date
                if let fileSize = attributes[.size] as? UInt64,
                   let modificationDate = attributes[.modificationDate] as? Date {
                    totalSize += fileSize
                    fileAttributesMap[fileURL] = (fileSize, modificationDate)
                }
            }
            
            // Check if the total size exceeds the limit
            if totalSize > maxSizeInBytes {
                let sortedFiles = fileAttributesMap.sorted { $0.1.1 < $1.1.1 }
                
                var bytesToDelete = totalSize - maxSizeInBytes
                for (fileURL, (fileSize, _)) in sortedFiles {
                    try removeItem(at: fileURL)
                    
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
