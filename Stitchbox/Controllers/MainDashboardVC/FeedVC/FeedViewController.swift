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
    var isFirstLoad = true
    var posts = [PostModel]()
    var editeddPost: PostModel?
    var refresh_request = false
    var lastLoadTime: Date?
    var hasViewAppeared = false
    var firstLoadDone = false
    var isScrollingToTop = false
    // Time Management
    var lastScrollTime: TimeInterval = 0
    var throttleTime: TimeInterval = 0.5 // Time in seconds

    // Collection Node
    var collectionNode: ASCollectionNode!

    // Delay Items
    lazy var delayItem = workItem()
    lazy var delayItem3 = workItem()
    
    // MARK: - View Lifecycle

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI setup
        setupNavBar()         // Configures the navigation bar
        setupButtons()        // Sets up buttons in the view
        globalHasNotch = UIDevice.current.ifHasNotch
        setupCollectionNode() // Initializes the collection node

        // Configuring pull-to-refresh for the collection node
        configurePullToRefresh()
        
        // Setup observe functions
        setupObservation()

        // Registering for notification to update the progress bar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(FeedViewController.updateProgressBar),
            name: NSNotification.Name(rawValue: "updateProgressBar2"),
            object: nil
        )
        
    }

    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning for feedvc")
        // Remove expired objects from cache
        CacheManager.shared.asyncRemoveExpiredObjects()
        
        // Maintain the temporary directory size
        cleanTemporaryDirectory()
    }
    
    func cleanTemporaryDirectory() {
        let maxSizeInBytes: UInt64 = UInt64(0.1 * 1024 * 1024 * 1024)  // 0.1 GB
        do {
            try FileManager.default.maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }
    }
    
    /// Called before the view is added to the view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Additional UI and data setup while the view appears
        setupTabBar()          // Configures the tab bar
        setupNavBar()          // Ensures navigation bar is set up correctly
        checkNotification()    // Checks for new notifications
        showMiddleBtn(vc: self) // Shows a middle button, if applicable
        

        // Load the feed if the initial loading has been done
        if firstLoadDone {
            loadFeed()
        }

        hasViewAppeared = true

        // Delayed registration for a notification to scroll to top
        delay(1.25) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(FeedViewController.shouldScrollToTop),
                name: NSNotification.Name(rawValue: "scrollToTop"),
                object: nil
            )
        }
        
    }

    /// Called when the view is about to be removed from the view hierarchy.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unregister from the 'scrollToTop' notification
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "scrollToTop"),
            object: nil
        )

        hasViewAppeared = false

        // Pause video if applicable
        if let index = currentIndex {
            pauseVideoOnAppStage(index: index)
        }
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
            
            if isScrollingToTop {
                return
            }
            
            if isDraggingEnded {
                // Skip scrollViewDidScroll logic if we have just ended dragging
                isDraggingEnded = false
                return
            }

            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)

            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? RootNode }

            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            var foundVisibleVideo = false
            var newPlayingIndex: Int?

            for cell in visibleCells {
                if let indexPath = cell.indexPath {
                    let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.y - visibleRect.midY)
                    
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = indexPath.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            }

            if let index = newPlayingIndex, !posts[index].muxPlaybackId.isEmpty {
                foundVisibleVideo = true
            }

            if foundVisibleVideo {
                // Start playing the new video if it's different from the current playing video.
                if let newPlayingIndex = newPlayingIndex, currentIndex != newPlayingIndex {
            
                    // Pause the current video, if any.
                    if let currentIndex = currentIndex {
                        hideStitchedView(index: currentIndex)
                        pauseVideoOnScrolling(index: currentIndex)
                    }
                    // Play the new video.
                    currentIndex = newPlayingIndex
                    playVideo(index: currentIndex!)
                    isVideoPlaying = true
                
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

    // MARK: - ASCollectionDataSource

    /// Generates a block that will create a cell node for a specific item at the given index path.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting the node.
    ///   - indexPath: The index path specifying the location of the item.
    /// - Returns: A block that returns an `ASCellNode` for the item at the specified index path.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]

        // Returns a block that creates and configures a cell node.
        return { [weak self] in
            guard let self = self else { return ASCellNode() }
            let isFirstItem = self.isFirstLoad && indexPath.row == 0
            let node = RootNode(with: post, firstItem: isFirstItem, level: indexPath.row)
            self.configureNode(node, at: indexPath)

            // Update the flag after the first load.
            if isFirstItem {
                self.isFirstLoad = false
            }

            return node
        }
    }

    /// Configures properties of a cell node.
    /// - Parameters:
    ///   - node: The `ASCellNode` to configure.
    ///   - indexPath: The index path of the node.
    private func configureNode(_ node: RootNode, at indexPath: IndexPath) {
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        node.automaticallyManagesSubnodes = true
    }


    // MARK: - Batch Fetching in Collection Node

    /// Manages batch fetching for the collection node when the user scrolls towards the end.
    /// - Parameters:
    ///   - collectionNode: The collection node in use.
    ///   - context: The batch fetching context.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        guard shouldFetchNextPage() else {
            completeBatchFetching(context)
            return
        }

        retrieveNextPageWithCompletion { [weak self] newPosts in
            self?.insertNewRowsInCollectionNode(newPosts: newPosts)
            self?.completeBatchFetching(context)
        }
    }

    /// Determines whether the next page of content should be fetched.
    /// - Returns: Boolean indicating if the next page should be fetched.
    private func shouldFetchNextPage() -> Bool {
        return !refresh_request
    }

    /// Completes the batch fetching process and sets the initial load flag.
    /// - Parameter context: The batch fetching context.
    private func completeBatchFetching(_ context: ASBatchContext) {
        context.completeBatchFetching(true)
        if !firstLoadDone {
            firstLoadDone = true
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
        isFirstLoad = true
        isScrollingToTop = false
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
        // Calculate the total number of posts before removal.
        let total = posts.count

        // Iterate through each index and clear posts in each cell.
        for index in 0..<total {
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
                // Clear the posts array for each cell.
                cell.clearExistingPosts()
            }
        }

        // Clear the main posts array.
        posts.removeAll()
        // Reload the main collection node to reflect the changes.
        collectionNode.reloadData()
    }

}


// MARK: - Video Playback Control Extension

// This extension provides methods to control video playback within the FeedViewController, including pausing and playing videos.

extension FeedViewController {
    
    // Pauses the video at a specific index and optionally seeks to the start.
    func hideStitchedView(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.showAllViews()
        }
    }
    
    // Pauses the video at a specific index and optionally seeks to the start.
    func pauseVideoOnScrolling(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.pauseVideoOnScrolling(index: cell.currentIndex!)
        }
    }
    
    // Pauses the video at a specific index without seeking to the start.
    func pauseVideoOnAppStage(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.pauseVideoOnAppStage(index: cell.currentIndex!)
        }
    }

    // Plays the video at a specified index and updates the root ID for notification.
    func playVideo(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.playVideo(index: cell.currentIndex!)
            
            guard cell.animatedLabel != nil else {
                return
            }
            
            if cell.animatedLabel.text != "" {
                cell.animatedLabel.restartLabel()
            }
        }
    }
    
    // Seeks the video at a specific index to the beginning (time zero).
    func seekToZero(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.seekToZero(index: cell.currentIndex!)
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


extension FeedViewController {
    /// Sets up observation for various notification actions related to a feed.
    private func setupObservation() {
        // Consolidated method to add observer
        let actions: [(selector: Selector, name: NSNotification.Name)] = [
            (#selector(copyProfile), NSNotification.Name(rawValue: "copy_profile")),
            (#selector(copyPost), NSNotification.Name(rawValue: "copy_post")),
            (#selector(reportPost), NSNotification.Name(rawValue: "report_post")),
            (#selector(removePost), NSNotification.Name(rawValue: "remove_post")),
            (#selector(sharePost), NSNotification.Name(rawValue: "share_post")),
            (#selector(createPostForStitch), NSNotification.Name(rawValue: "create_new_for_stitch")),
            (#selector(stitchToExistingPost), NSNotification.Name(rawValue: "stitch_to_exist_one")),
            (#selector(onClickDelete), NSNotification.Name(rawValue: "delete")),
            (#selector(onClickEdit), NSNotification.Name(rawValue: "edit")),
            (#selector(onClickDownload), NSNotification.Name(rawValue: "download")),
            (#selector(onClickStats), NSNotification.Name(rawValue: "stats"))
        ]
        
        actions.forEach { action in
            NotificationCenter.default.addObserver(self, selector: action.selector, name: action.name, object: nil)
        }
    }
    
    // MARK: - Scrolling Management

    /// Scrolls to the top of the feed if not already there.
    @objc func shouldScrollToTop() {
        // Check if the current index is at the top.
        guard let currentIndex = currentIndex, currentIndex != 0 else {
            handleCurrentIndexAtTop()
            return
        }

        // Scroll to the appropriate item based on the current index.
        scrollToAppropriateItemBasedOnCurrentIndex(currentIndex)
    }

    /// Handles the scenario when the current index is at the top.
    private func handleCurrentIndexAtTop() {
        if currentIndex == 0 {
            // Reset the feed if the current index is 0.
            resetFeed()
        }
    }

    // MARK: - Scrolling Management

    /// Scrolls to an appropriate item in the collection node based on the current index.
    /// - Parameter currentIndex: The current index of the collection node.
    private func scrollToAppropriateItemBasedOnCurrentIndex(_ currentIndex: Int) {
        guard collectionNode.numberOfItems(inSection: 0) > 0 else {
            print("No items in the collection node.")
            return
        }

        // Flag indicating the start of scrolling to the top.
        isScrollingToTop = true
        // Pause video at currentIndex.
        pauseVideoOnScrolling(index: currentIndex)

        if currentIndex > 1 {
            // If the current index is greater than 1, scroll first to index 1 without animation.
            collectionNode.scrollToItem(at: IndexPath(row: 1, section: 0), at: .top, animated: false)

            // Then, scroll to index 0 with animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

                // Update current index and play video after scrolling.
                self?.finishScrollToTopActions()
            }
        } else if currentIndex == 1 {
            // If the current index is 1, scroll directly to the top with animation.
            collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

            // Update current index and play video after scrolling.
            finishScrollToTopActions()
        }
    }

    /// Finalizes actions after scrolling to the top, such as updating the current index and playing a video.
    private func finishScrollToTopActions() {
        currentIndex = 0
        playVideo(index: currentIndex!)
        
        delay(0.5) { [weak self] in
            self?.isScrollingToTop = false
        }

    }

}

extension FeedViewController {

    // MARK: - Post Actions
    
    // MARK: - Removing Post from List

    /// Removes the selected post from the list and updates the collection view.
    @objc func removePost(_ sender: AnyObject) {
        guard let deletingPost = editeddPost, let indexPath = posts.firstIndex(of: deletingPost) else { return }

        posts.removeObject(deletingPost)

        // Reload the collection node if no more posts are available, otherwise delete the specific item.
        if posts.isEmpty {
            collectionNode.reloadData()
        } else {
            collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
        }
    }


    /// Deletes a post based on its identifier.
    @objc func onClickDelete(_ sender: AnyObject) {
        presentSwiftLoader()

        guard let postId = editeddPost?.id, !postId.isEmpty else {
            showErrorAfterDelay(message: "Unable to delete this post, please try again.")
            return
        }

        APIManager.shared.deleteMyPost(pid: postId) { [weak self] result in
            self?.handleDeletePostResult(result)
        }
    }

    /// Handles the result of the delete post request.
    /// - Parameter result: The result of the deletion request.
    private func handleDeletePostResult(_ result: Result) {
        SwiftLoader.hide()
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                self?.removePostFromList()
            }
        case .failure(let error):
            showErrorAfterDelay(message: "Unable to delete this post. \(error.localizedDescription), please try again.")
        }
    }

    /// Removes the deleted post from the list and updates the UI.
    private func removePostFromList() {
        guard let deletingPost = editeddPost, let indexPath = posts.firstIndex(of: deletingPost) else { return }

        needReloadPost = true
        posts.removeObject(deletingPost)
        manageCollectionView(for: indexPath)
    }

    /// Manages the collection view after post deletion.
    /// - Parameter indexPath: The index of the deleted post.
    private func manageCollectionView(for indexPath: Int) {
        if posts.isEmpty {
            collectionNode.reloadData()
        } else {
            collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
        }
    }

    /// Shows an error message after a delay.
    /// - Parameter message: The error message to show.
    private func showErrorAfterDelay(message: String) {
        delay(0.1) { [weak self] in
            SwiftLoader.hide()
            self?.showErrorAlert("Oops!", msg: message)
        }
    }

    // MARK: - Edit and View Post

    /// Navigates to edit post view controller.
    @objc func onClickEdit(_ sender: AnyObject) {
        navigateToViewController(withIdentifier: "EditPostVC", type: EditPostVC.self) { vc in
            vc.selectedPost = editeddPost
        }
    }

    /// Navigates to view post statistics view controller.
    @objc func onClickStats(_ sender: AnyObject) {
        navigateToViewController(withIdentifier: "ViewVC", type: ViewVC.self) { vc in
            vc.selected_item = editeddPost
        }
    }

    /// Navigates to a specified view controller from the storyboard.
    /// - Parameters:
    ///   - identifier: The storyboard identifier of the view controller.
    ///   - type: The type of the view controller.
    ///   - configure: A closure to configure the view controller.
    private func navigateToViewController<T: UIViewController>(withIdentifier identifier: String, type: T.Type, configure: (T) -> Void) {
        guard let viewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: identifier) as? T else { return }

        configure(viewController)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Download Video

    /// Initiates video download for a selected post.
    @objc func onClickDownload(_ sender: AnyObject) {
        guard let selectedPost = editeddPost, !selectedPost.muxPlaybackId.isEmpty else { return }
        
        let url = "https://stream.mux.com/\(selectedPost.muxPlaybackId)/high.mp4"
        downloadVideo(url: url, id: selectedPost.muxAssetId)
    }

    
    // MARK: - Video Downloading

    /// Downloads a video from a specified URL and saves it locally.
    /// - Parameters:
    ///   - url: The URL of the video to download.
    ///   - id: The identifier to use for saving the video.
    func downloadVideo(url: String, id: String) {
        AF.request(url).downloadProgress { [weak self] progress in
            self?.updateDownloadProgress(progress.fractionCompleted)
        }.responseData { [weak self] response in
            self?.handleDownloadResponse(response, id: id)
        }
    }

    /// Updates the UI to reflect the current download progress.
    /// - Parameter progress: The current progress of the download.
    private func updateDownloadProgress(_ progress: Double) {
        let formattedProgress = String(format: "%.2f", progress * 100) + "%"
        swiftLoader(progress: formattedProgress)
    }

    /// Handles the response of the video download request.
    /// - Parameters:
    ///   - response: The response from the download request.
    ///   - id: The identifier used for saving the video.
    private func handleDownloadResponse(_ response: AFDataResponse<Data>, id: String) {
        switch response.result {
        case .success(let data):
            saveVideoWithData(data, id: id)
        case .failure(let error):
            print(error)
        }
    }

    // MARK: - Saving Video

    /// Saves the downloaded video data to the device and adds it to the photo library.
    /// - Parameters:
    ///   - data: The video data to save.
    ///   - id: The identifier to use for saving the video.
    func saveVideoWithData(_ data: Data, id: String) {
        let videoURL = createLocalURLForVideo(id)
        do {
            try data.write(to: videoURL)
            addVideoToPhotoLibrary(url: videoURL)
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.handleVideoSaveError()
            }
        }
    }

    /// Creates a local URL for saving the video.
    /// - Parameter id: The identifier to use for the video file.
    /// - Returns: A URL where the video should be saved.
    private func createLocalURLForVideo(_ id: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("\(id).mp4")
    }

    /// Handles errors that occur while saving the video.
    private func handleVideoSaveError() {
        SwiftLoader.hide()
        print("Something went wrong!")
        showErrorAlert("Oops!", msg: "Failed to save video.")
    }

    // MARK: - Adding Video to Photo Library

    /// Adds the saved video to the device's photo library.
    /// - Parameter url: The local URL of the saved video.
    func addVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { [weak self] saved, error in
            self?.handlePhotoLibraryUpdateResult(saved, error: error)
        }
    }

    /// Handles the result of adding the video to the photo library.
    /// - Parameters:
    ///   - saved: A Boolean indicating whether the video was successfully added.
    ///   - error: An error that occurred during the process, if any.
    private func handlePhotoLibraryUpdateResult(_ saved: Bool, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.displayVideoSaveResult(saved, error: error)
        }
    }

    /// Displays an alert based on the result of saving the video to the photo library.
    /// - Parameters:
    ///   - saved: Indicates whether the video was saved successfully.
    ///   - error: An error that occurred during saving, if any.
    private func displayVideoSaveResult(_ saved: Bool, error: Error?) {
        SwiftLoader.hide()
        if let error = error {
            print("Error: \(error.localizedDescription)")
            showErrorAlert("Oops!", msg: error.localizedDescription)
        } else {
            showErrorAlert("Your video was successfully saved", msg: "")
        }
    }

    // MARK: - Copying Links

    /// Copies the link of the current post to the clipboard.
    @objc func copyPost() {
        if let postID = editeddPost?.id {
            let link = "https://stitchbox.net/app/post/?uid=\(postID)"
            copyToClipboard(link, message: "Post link is copied")
        } else {
            showNote(text: "Post link is unable to be copied")
        }
    }

    /// Copies the link of the post owner's profile to the clipboard.
    @objc func copyProfile() {
        if let ownerID = editeddPost?.owner?.id {
            let link = "https://stitchbox.net/app/account/?uid=\(ownerID)"
            copyToClipboard(link, message: "User profile link is copied")
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
    }

    /// Copies a link to the clipboard and shows a notification.
    /// - Parameters:
    ///   - link: The link to copy.
    ///   - message: The message to display after copying.
    private func copyToClipboard(_ link: String, message: String) {
        UIPasteboard.general.string = link
        showNote(text: message)
    }

    // MARK: - Reporting Post

    /// Presents a view controller for reporting a post.
    @objc func reportPost() {
        let slideVC = ReportView()
        configureAndPresentReportView(slideVC)
    }

    /// Configures and presents the report view controller.
    /// - Parameter viewController: The `ReportView` instance to configure and present.
    private func configureAndPresentReportView(_ viewController: ReportView) {
        viewController.setupForPostReporting(with: editeddPost?.id ?? "")
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        global_presetingRate = 0.75
        global_cornerRadius = 35

        present(viewController, animated: true, afterDelay: 0.1)
    }

    /// Presents a given view controller after a specified delay.
    /// - Parameters:
    ///   - viewController: The view controller to present.
    ///   - delay: The delay before presenting the view controller.
    private func present(_ viewController: UIViewController, animated: Bool, afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.present(viewController, animated: animated)
        }
    }


    
    // MARK: - Post Sharing

    /// Shares a post to various platforms.
    /// Ensures that user data and post ID are valid before proceeding.
    @objc func sharePost() {
        guard let userDataSource = _AppCoreData.userDataSource.value,
              let userUID = userDataSource.userID,
              !userUID.isEmpty else {
            print("Error: Can't get userUID")
            return
        }

        guard let postId = editeddPost?.id else {
            print("Failed to get postId")
            return
        }

        let username = userDataSource.userName ?? ""
        let shareURL = URL(string: "https://stitchbox.net/app/post/?uid=\(postId)")!
        let shareItems: [Any] = ["Hi I am \(username) from Stitchbox, let's check out this!", shareURL]

        presentActivityController(with: shareItems)
    }

    /// Presents an `UIActivityViewController` with the specified items.
    /// - Parameter items: Items to be shared.
    private func presentActivityController(with items: [Any]) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            // Handle completion if needed
        }

        presentActivityControllerAfterDelay(activityController)
    }

    /// Presents a given view controller after a short delay.
    /// - Parameter viewController: The view controller to present.
    private func presentActivityControllerAfterDelay(_ viewController: UIViewController) {
        delay(0.1) { [weak self] in
            self?.present(viewController, animated: true, completion: nil)
        }
    }

    // MARK: - Post Creation

    /// Creates and presents a new post.
    /// Ensures that the `PostNavVC` is instantiated correctly before presenting.
    @objc func createPostForStitch() {
        guard let postNavVC = instantiateViewController(withIdentifier: "PostNavVC", storyboardName: "Dashboard") as? PostNavVC else {
            return
        }

        postNavVC.modalPresentationStyle = .fullScreen
        configurePostVC(for: postNavVC)

        delay(0.1) { [weak self] in
            self?.present(postNavVC, animated: true)
        }
    
    }

    /// Configures the `PostVC` within the navigation controller.
    /// - Parameter navController: The navigation controller containing `PostVC`.
    private func configurePostVC(for navController: PostNavVC) {
        let postForStitch = editeddPost
        if let postVC = navController.viewControllers.first as? PostVC {
            postVC.stitchPost = postForStitch
        } else {
            printContent(navController.viewControllers.first)
        }
    }

    // MARK: - Stitching Post

    /// Navigates to `AddStitchToExistingVC` to stitch to an existing post.
    @objc func stitchToExistingPost() {
        guard let addStitchVC = instantiateViewController(withIdentifier: "AddStitchToExistingVC", storyboardName: "Dashboard") as? AddStitchToExistingVC else {
            return
        }

        configureAndPushAddStitchVC(addStitchVC)
    }

    /// Configures and pushes `AddStitchToExistingVC` onto the navigation stack.
    /// - Parameter viewController: The `AddStitchToExistingVC` to configure and push.
    private func configureAndPushAddStitchVC(_ viewController: AddStitchToExistingVC) {
        viewController.hidesBottomBarWhenPushed = true
        viewController.stitchedPost = editeddPost
        hideMiddleBtn(vc: self)

        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Feed Loading and Refreshing

    /// Loads the feed, refreshing it if necessary based on the time since the last load.
    func loadFeed() {
        let now = Date()
        let thirtyMinutesAgo = now.addingTimeInterval(-1800) // 1800 seconds = 30 minutes

        // Check if the feed needs to be refreshed.
        guard shouldRefreshFeed(lastLoadTime: lastLoadTime, comparedTo: thirtyMinutesAgo) else {
            // Resume video playback if the feed does not need refreshing.
            resumeVideo()
            return
        }

        // Reset the feed if refreshing is needed.
        resetFeed()
    }

    /// Determines whether the feed should be refreshed.
    /// - Parameters:
    ///   - lastLoadTime: The last time the feed was loaded.
    ///   - thresholdTime: The time threshold for deciding whether to refresh.
    /// - Returns: Boolean indicating whether the feed should be refreshed.
    private func shouldRefreshFeed(lastLoadTime: Date?, comparedTo thresholdTime: Date) -> Bool {
        return lastLoadTime == nil || lastLoadTime! < thresholdTime
    }

    /// Resets the feed by refreshing the content and clearing existing data.
    func resetFeed() {
        // Refresh the feed content.
        scrollToAppropriateItemBasedOnCurrentIndex(currentIndex!)

        // Clear existing posts and any related data.
        hardReset()
    }
    
    func hardReset() {
        // Clear existing posts and any related data.
        clearAllData()
        clearExistingPosts()
    }
    
    /// Instantiates a view controller from a storyboard.
    /// - Parameters:
    ///   - identifier: The identifier of the view controller in the storyboard.
    ///   - storyboardName: The name of the storyboard file.
    /// - Returns: An instantiated view controller of the specified type, or nil if the instantiation fails.
    private func instantiateViewController(withIdentifier identifier: String, storyboardName: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }


    // MARK: - Video Playback

    /// Resumes video playback at the current index.
    func resumeVideo() {
        if let currentIndex = currentIndex {
            playVideo(index: currentIndex)
        }
    }

}
