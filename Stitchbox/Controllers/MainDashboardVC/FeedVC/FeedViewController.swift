//
//  FeedViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import ObjectMapper
import AnimatedCollectionViewLayout

class FeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    // MARK: - Properties
    // UI Components
    let homeButton: UIButton = UIButton(type: .custom)
    let notiButton = UIButton(type: .custom)
    let searchButton = UIButton(type: .custom)
    let backButton: UIButton = UIButton(type: .custom)
    private var pullControl = UIRefreshControl()

    // IBOutlet
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!

    // Data and State Management
    var currentIndex: Int? = 0
    var newPlayingIndex: Int? = 0
    var isVideoPlaying = false
    var isDraggingEnded: Bool = false
    var isfirstLoad = true
    var posts = [PostModel]()
    var editeddPost: PostModel?
    var refresh_request = false
    var lastLoadTime: Date?
    var readyToLoad = true
    var hasViewAppeared = false
    var firstLoadDone = false
    // Time Management
    var lastScrollTime: TimeInterval = 0
    var throttleTime: TimeInterval = 0.5 // Time in seconds

    // Collection Node
    var collectionNode: ASCollectionNode!

    // Delay Items
    lazy var delayItem = workItem()
    lazy var delayItem3 = workItem()
    

    // MARK: - View Lifecycle

    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the UI components.
        setupNavBar()         // Configures the navigation bar.
        setupButtons()        // Sets up buttons in the view.
        setupCollectionNode() // Initializes the collection node.

        // Configuring the Pull-to-Refresh control for the collection node.
        configurePullToRefresh()

        // Registering for notifications.
        // Observes for a notification to update the progress bar.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(FeedViewController.updateProgressBar),
            name: NSNotification.Name(rawValue: "updateProgressBar2"),
            object: nil
        )

        // Flag to indicate the initial load is done.
        firstLoadDone = true
    }
    
    // Called before the view is added to the view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Additional setup while the view appears.
        setupTabBar()          // Configures the tab bar.
        setupNavBar()          // Ensures navigation bar is set up correctly.
        checkNotification()    // Checks for new notifications.
        showMiddleBtn(vc: self) // Shows a middle button, if applicable.

        
    }

    // Additional utility method for delay.
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
    }

    @objc private func refreshListData(_ sender: Any) {
        // Call API
        
        self.clearAllData()
        
    }
    
    private func configurePullToRefresh() {
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)

        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }

        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
    }
    

}

// MARK: - FeedViewController Extension
// This extension focuses on additional UI setup specifically for the FeedViewController,
// including the navigation bar and tab bar configurations.

extension FeedViewController {

    // MARK: - Setup TabBar
    /// Sets up the tab bar with a custom appearance.
    func setupTabBar() {
        // Attempt to cast the tabBarController to DashboardTabBarController and setup its appearance
        if let tabbar = self.tabBarController as? DashboardTabBarController {
            tabbar.setupBlackTabBar()
        }
    }

    // MARK: - Setup NavBar
    /// Configures the navigation bar's appearance with a custom style.
    func setupNavBar() {
        // Customizing the navigation bar's appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundEffect = nil

        // Applying the customized appearance to the navigation bar
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.isTranslucent = true

        // Ensuring the navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // Add any additional methods related to UI setup below
}

// MARK: - Navigation Controller and Button Setup Extension

// This extension implements the navigation controller delegate and sets up various buttons in the navigation bar.
extension FeedViewController: UINavigationBarDelegate, UINavigationControllerDelegate {

    // MARK: - Navigation Controller Delegate Setup
    /// Sets the navigation controller delegate to self.
    func navigationControllerDelegate() {
        self.navigationController?.delegate = self
    }

    // MARK: - Button Setup Functions
    /// Sets up all buttons used in the navigation bar.
    func setupButtons() {
        setupHomeButton()
        // Add other button setup calls here if needed
    }

    /// Configures the home button with an image and action, then adds it to the navigation bar.
    func setupHomeButton() {
        homeButton.setImage(UIImage.init(named: "stitchboxlogonew")?.resize(targetSize: CGSize(width: 19.27, height: 30)), for: [])
        homeButton.addTarget(self, action: #selector(openChatBot(_:)), for: .touchUpInside)
        homeButton.frame = back_frame
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitle("", for: .normal)
        homeButton.sizeToFit()
        let homeButtonBarButton = UIBarButtonItem(customView: homeButton)
        
        self.navigationItem.leftBarButtonItem = homeButtonBarButton
    }

    /// Sets up a notification button when there are no notifications.
    func setupEmptyNotiButton() {
        configureNotificationButton(withImageName: "noNoti")
    }

    /// Sets up a notification button when there are notifications.
    func setupHasNotiButton() {
        configureNotificationButton(withImageName: "homeNoti")
    }

    /// Helper function to configure the notification button and search button.
    private func configureNotificationButton(withImageName imageName: String) {
        notiButton.setImage(UIImage.init(named: imageName)?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let notiBarButton = UIBarButtonItem(customView: notiButton)
        
        searchButton.setImage(UIImage(named: "search")?.resize(targetSize: CGSize(width: 20, height: 20)), for: [])
        searchButton.addTarget(self, action: #selector(onClickSearch(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        
        self.navigationItem.rightBarButtonItems = [notiBarButton, fixedSpace, searchBarButton]
    }

    // MARK: - Selector Functions
    @objc private func openChatBot(_ sender: UIButton) {
        // Implement chat bot opening functionality
        if let SBCB = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ChatBot") as? SB_ChatBot {
            
            SBCB.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SBCB, animated: true)
    
        }
    }

    @objc private func onClickNoti(_ sender: UIButton) {
        // Implement notification click functionality
        if let NVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            
            resetNoti()
            NVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(NVC, animated: true)
            
        }
    }

    @objc private func onClickSearch(_ sender: UIButton) {
        // Implement search functionality
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            
            SVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
    }

    // Add other methods related to navigation bar and button setup below
}

// MARK: - Profile and Notification Management Extension

// This extension of FeedViewController includes methods for switching to the profile view controller,
// handling notifications, and managing the progress bar.

extension FeedViewController {

    // MARK: - Profile Switching
    /// Switches the current tab to the Profile View Controller.
    func switchToProfileVC() {
        // Assuming the Profile VC is at index 4 in the tab bar's view controllers
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[4]
    }

    // MARK: - Notification Handling
    /// Resets the notification badge and updates the UI accordingly.
    func resetNoti() {
        APIManager.shared.resetBadge { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.setupEmptyNotiButton()
                }
                
            case .failure(let error):
                print(error) // Consider handling the error more gracefully
            }
        }
    }

    /// Checks the current status of notifications and updates the UI accordingly.
    func checkNotification() {
        APIManager.shared.getBadge { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                DispatchQueue.main.async {
                    if let badge = apiResponse.body?["badge"] as? Int, badge > 0 {
                        self.setupHasNotiButton()
                    } else {
                        self.setupEmptyNotiButton()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.setupEmptyNotiButton()
                }
                print(error) // Consider handling the error more gracefully
            }
        }
    }
}

// MARK: - Progress Bar Management Extension

// This extension focuses on updating the progress bar based on global completion percentage.

extension FeedViewController {

    // MARK: - Progress Bar Update
    @objc func updateProgressBar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Hiding the progress bar when completion is 0% or 100%
            if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
                self.progressBar.isHidden = true
                global_percentComplete = 0.00
            } else {
                // Updating the progress bar for other percentages
                self.progressBar.isHidden = false
                self.progressBar.progress = CGFloat(global_percentComplete) / 100
            }
        }
    }
}

// MARK: - UIScrollViewDelegate Extension for FeedViewController

// This extension focuses on handling scroll events in the collection view, specifically for controlling
// video playback based on the scroll position.

extension FeedViewController {

    // MARK: - Scroll View Will End Dragging
    /// Handles the logic when the user ends dragging the scroll view.
    /// Adjusts the target content offset to align with the start of the next or previous page.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !posts.isEmpty, scrollView == collectionNode.view, !refresh_request {
            
            // Define the page height and calculate the new target offset
            let pageHeight: CGFloat = scrollView.bounds.height
            let currentOffset: CGFloat = scrollView.contentOffset.y
            let targetOffset: CGFloat = targetContentOffset.pointee.y
            var newTargetOffset: CGFloat = targetOffset > currentOffset ?
                ceil(currentOffset / pageHeight) * pageHeight :
                floor(currentOffset / pageHeight) * pageHeight

            // Bounds checking for the new target offset
            newTargetOffset = max(min(newTargetOffset, scrollView.contentSize.height - pageHeight), 0)

            // Adjust the target content offset
            targetContentOffset.pointee.y = newTargetOffset
            
            // Set the flag to indicate dragging has ended
            isDraggingEnded = true
        }
    }

    // MARK: - Scroll View Did Scroll
    /// Called when the scroll view has been scrolled.
    /// Handles video playback logic based on the current scroll position.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !posts.isEmpty, scrollView == collectionNode.view, !refresh_request {
            
            if isDraggingEnded {
                // Reset the flag and skip further logic in this scroll event
                isDraggingEnded = false
                return
            }

            // Calculate visible cells and find the one closest to the center of the screen
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? VideoNode }
            var minDistanceFromCenter = CGFloat.infinity
            var foundVisibleVideo = false
            var newPlayingIndex: Int?

            for cell in visibleCells {
                if let indexPath = cell.indexPath {
                    let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                    let distanceFromCenter = abs(cellRect.midY - visibleRect.midY)
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = indexPath.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            }


            // Handle video playback if a new video is found and is different from the current one
            if let index = newPlayingIndex, index != currentIndex, !posts[index].muxPlaybackId.isEmpty {
                foundVisibleVideo = true
                // Update the current index and play the new video
                if let currentIndex = currentIndex {
                    pauseVideoOnScrolling(index: currentIndex)
                }
                currentIndex = newPlayingIndex
                playVideo(index: currentIndex!)
                isVideoPlaying = true

                // Reset the view for the new video
                if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? VideoNode {
                    resetView(cell: node)
                }
            }
        }
    }

    // MARK: - Additional Helper Methods
    /// Add any additional methods related to scroll view handling here

    // Implement playVideo and pauseVideoOnScrolling methods if not already implemented
}

// MARK: - ASCollectionNode Delegate and Data Source Extensions

extension FeedViewController: ASCollectionDelegate {

    // Determines the size range for each item at the specified index path in the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let frameWidth = self.collectionNode.frame.width
        let frameHeight = self.collectionNode.frame.height

        // Check for excessively large sizes to prevent layout issues.
        guard frameWidth < CGFloat.greatestFiniteMagnitude,
              frameHeight < CGFloat.greatestFiniteMagnitude else {
            print("Frame width or height is too large")
            return ASSizeRangeMake(CGSize.zero, CGSize.zero)
        }

        // Define minimum and maximum sizes for the items.
        let min = CGSize(width: frameWidth, height: 50) // Minimum height set to 50
        let max = CGSize(width: frameWidth, height: frameHeight) // Maximum height equal to collection node's height

        return ASSizeRangeMake(min, max)
    }

    // Decides whether the collection node should fetch more data as the user scrolls.
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true // Always return true to enable batch fetching
    }
}

extension FeedViewController: ASCollectionDataSource {

    // Returns the number of sections in the collection node. In this case, it's always 1.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    // Provides the total number of items in a section, determined by the count of 'posts'.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    // Generates a block that will create a cell node for a specific item at the given index path.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        return {
            let node = RootNode(with: post) // RootNode is a custom ASCellNode
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.automaticallyManagesSubnodes = true
            return node
        }
    }

    // Manages batch fetching behavior when the user scrolls towards the end of the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        if !refresh_request, posts.count <= 200, readyToLoad {
            retrieveNextPageWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                context.completeBatchFetching(true)
            }
        } else {
            context.completeBatchFetching(true)
        }
    }
}

// Collection node setup and styling extension.
extension FeedViewController {

    // Sets up the collection node with specific layout and configuration.
    func setupCollectionNode() {
        
        
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.animator = ZoomInOutAttributesAnimator()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0

        // Set the data source and delegate for collection node.
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self

        // Add the collection node to the view hierarchy.
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        // Apply additional styles and reload data.
        self.applyStyle()
        self.collectionNode.reloadData()
    }

    // Applies additional styling to the collection node's view.
    func applyStyle() {
        self.collectionNode.view.isPagingEnabled = true // Enables paging
        self.collectionNode.view.backgroundColor = UIColor.clear // Sets background color to clear
        self.collectionNode.view.showsVerticalScrollIndicator = false // Hides vertical scroll indicator
        self.collectionNode.view.allowsSelection = false // Disables selection of items
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never // Adjusts content inset behavior
        self.collectionNode.view.decelerationRate = UIScrollView.DecelerationRate.fast // Sets a faster deceleration rate
    }
}


// MARK: - Data Management Extension

extension FeedViewController {
    
    // MARK: - Clear All Data
    /// Clears all data and resets relevant flags. Then updates the data.
    @objc func clearAllData() {
        // Resetting flags and indices
        refresh_request = true
        currentIndex = 0
        isfirstLoad = true
        updateData() // Call to update the data
    }

    // MARK: - Update Data
    /// Fetches the next page of posts and updates the collection node.
    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] newPosts in
            guard let self = self else { return }

            // Insert new rows in the collection node
            self.insertNewRowsInCollectionNode(newPosts: newPosts)

            // End refreshing if the pull control is active
            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
        }
    }

    // MARK: - Retrieve Next Page
    /// Fetches the next page of posts from the API.
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getUserFeed { [weak self] result in
            var items: [[String: Any]] = []
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    items = data
                    self?.lastLoadTime = Date()
                    print("Successfully retrieved \(data.count) posts.")
                }
            case .failure(let error):
                print(error) // Handle the error appropriately
            }
            DispatchQueue.main.async {
                block(items) // Pass the items for further processing
            }
        }
    }

    // MARK: - Insert New Rows in Collection Node
    /// Inserts new rows into the collection node.
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        if refresh_request {
            clearExistingPosts() // Clear existing posts if refresh is requested
        }

        // Processing new posts and filtering out duplicates
        let uniquePosts = Set(self.posts) // Create a set for fast lookup
        var newUniquePosts: [PostModel] = []

        for newPost in newPosts {
            if let postModel = PostModel(JSON: newPost), !uniquePosts.contains(postModel) {
                newUniquePosts.append(postModel)
            }
        }

        guard !newUniquePosts.isEmpty else { return }

        // Append new unique posts and update the collection node
        self.posts.append(contentsOf: newUniquePosts)
        let indexPaths = (posts.count - newUniquePosts.count..<posts.count).map { IndexPath(row: $0, section: 0) }
        collectionNode.insertItems(at: indexPaths)

        // Reset the refresh request flag
        if refresh_request {
            refresh_request = false
        }
    }

    // MARK: - Clear Existing Posts
    /// Clears existing posts from the collection node.
    func clearExistingPosts() {
        posts.removeAll() // Clear the posts array
        collectionNode.reloadData() // Reload the collection node to reflect the changes
    }
}


// MARK: - Video Playback Control Extension

// This extension provides methods to control video playback within the FeedViewController, including pausing and playing videos.

extension FeedViewController {
    
    // Pauses the video at a specific index and optionally seeks to the start.
    func pauseVideoOnScrolling(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.pauseVideo(shouldSeekToStart: true)
        }
    }
    
    // Pauses the video at a specific index without seeking to the start.
    func pauseVideoOnAppStage(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.pauseVideo(shouldSeekToStart: false)
        }
    }

    // Plays the video at a specified index and updates the root ID for notification.
    func playVideo(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.isActive = true
            cell.playVideo()
            mainRootId = cell.post.id
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "observeRootChangeForFeed"), object: nil)
        }
    }
    
    // Seeks the video at a specific index to the beginning (time zero).
    func seekToZero(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            //cell.seekToZero()
        }
    }
}

// MARK: - UI Alert and Loader Extension

// This extension includes methods for displaying alert messages and configuring loaders.

extension FeedViewController {
    
    // Displays an error alert with a title and message.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Configures and shows a loader with a custom progress message.
    func swiftLoader(progress: String) {
        var config = SwiftLoader.Config()
        config.size = 170
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        SwiftLoader.setConfig(config: config)
        SwiftLoader.show(title: progress, animated: true)
    }
}

