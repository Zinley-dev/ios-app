//
//  SelectedRootPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/2/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage

class SelectedRootPostVC: UIViewController, UICollectionViewDelegateFlowLayout, ASCollectionDelegate {

    // MARK: - Enums and Constants

    enum LoadingMode {
        case myPost, userPost, hashTags, search, save, trending, none
    }

    // MARK: - Outlets and Properties

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    var isFirstLoad = true
    var onPresent = false
    var posts = [PostModel]()
    var collectionNode: ASCollectionNode!
    var editedPost: PostModel?
    var startIndex: Int?
    var currentIndex: Int?
    var hasViewAppeared = false
    let backButton = UIButton(type: .custom)
    var keyword = ""
    var userId = ""
    var hashtag = ""
    var firstAnimated = true
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    
    var selectedLoadingMode = LoadingMode.none
    var page = 0
    var isDraggingEnded = false
    var completedLoading = false

    var editeddPost: PostModel?
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViewState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoading()
        prepareForAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupBeforeDisappearance()
    }

    deinit {
        print("SelectedRootPostVC is being deallocated.")
    }

    // MARK: - Setup Methods

    private func setupInitialViewState() {
        setupButtons()
        setupNavBar()
        setupCollectionNode()
        loadPosts()
        completedLoading = true
    }

    private func prepareForAppearance() {
        setupNavBar()
        hasViewAppeared = true
        setupObservation()
        if completedLoading {
            resumeVideo()
        }
    }

    private func cleanupBeforeDisappearance() {
        hasViewAppeared = false
        removeObservations()
        if let currentIndex = currentIndex {
            pauseVideoOnAppStage(index: currentIndex)
        }
    }

}

extension SelectedRootPostVC {

    // MARK: - Setup Methods

    /// Sets up notifications for various actions.
    func setupObservation() {
        let notificationNames = [
            "copy_profile_selected",
            "copy_post_selected",
            "report_post_selected",
            "remove_post_selected",
            "share_post_selected",
            "create_new_for_stitch_selected",
            "stitch_to_exist_one_selected",
            "delete_selected",
            "edit_selected",
            "download_selected",
            "stats_selected"
        ]

        notificationNames.forEach { name in
            NotificationCenter.default.addObserver(self, selector: getSelector(for: name), name: NSNotification.Name(rawValue: name), object: nil)
        }
    }

    /// Removes all observations related to this view controller.
    func removeObservations() {
        NotificationCenter.default.removeObserver(self)
    }

    /// Configures the navigation bar's appearance.
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        configureNavigationBarAppearance(navigationBarAppearance)

        if let navigationController = navigationController {
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.compactAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController.navigationBar.isTranslucent = true
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }

    // MARK: - Private Helpers

    /// Returns a selector for a given notification name.
    /// - Parameter name: The name of the notification.
    /// - Returns: A selector to be used with the notification.
    private func getSelector(for name: String) -> Selector {
        switch name {
        case "copy_profile_selected": return #selector(copyProfile)
        case "copy_post_selected": return #selector(copyPost)
        case "report_post_selected": return #selector(reportPost)
        case "remove_post_selected": return #selector(removePost)
        case "create_new_for_stitch_selected": return #selector(createPostForStitch)
        case "stitch_to_exist_one_selected": return #selector(stitchToExistingPost)
        case "delete_selected": return #selector(onClickDelete)
        case "edit_selected": return #selector(onClickEdit)
        case "download_selected": return #selector(onClickDownload)
        case "stats_selected": return #selector(onClickStats)
        // Add other cases here
        default: return #selector(defaultSelector)
        }
    }

    /// Configures the appearance of the navigation bar.
    /// - Parameter appearance: The UINavigationBarAppearance to configure.
    private func configureNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil
    }

    /// Default selector for notifications.
    @objc private func defaultSelector() {
        // Implement default action for notification
    }

}

extension SelectedRootPostVC {

    // MARK: - Setup Methods

    /// Sets up buttons and title for the view controller.
    func setupButtons() {
        setupBackButton()
        setupTitle()
    }

    /// Configures the back button with appropriate styling and adds it to the navigation bar.
    func setupBackButton() {
        backButton.frame = back_frame
        backButton.contentMode = .center
        configureBackButtonImage()
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle("", for: .normal)

        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonBarButton
    }

    /// Sets up the navigation item title.
    func setupTitle() {
        navigationItem.title = "" // Consider using an actual title if needed
    }

    // MARK: - Action Handlers

    /// Handles the back button click event.
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = navigationController {
            if onPresent {
                self.dismiss(animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
        }
    }


    // MARK: - Private Helpers

    /// Configures the back button's image.
    private func configureBackButtonImage() {
        guard let backImage = UIImage(named: "back_icn_white") else { return }
        let imageSize = CGSize(width: 13, height: 23)
        let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                   left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                   bottom: (back_frame.height - imageSize.height) / 2,
                                   right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
        backButton.imageEdgeInsets = padding
        backButton.setImage(backImage, for: [])
    }
}


// MARK: - UI Alert and Loader Extension

// This extension includes methods for displaying alert messages and configuring loaders.

extension SelectedRootPostVC {
    
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


// MARK: - UIScrollViewDelegate Extension for FeedViewController

// This extension focuses on handling scroll events in the collection view, specifically for controlling
// video playback based on the scroll position.

extension SelectedRootPostVC {

    // MARK: - Scroll View Will End Dragging
    /// Handles the logic when the user ends dragging the scroll view.
    /// Adjusts the target content offset to align with the start of the next or previous page.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !posts.isEmpty, scrollView == collectionNode.view {
            
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
        
        if !posts.isEmpty, scrollView == collectionNode.view {
    
            
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

extension SelectedRootPostVC {

    // MARK: - Batch Fetching

    /// Determines whether the collection node should fetch the next batch of data.
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }

    /// Handles the beginning of a batch fetch in the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { [weak self] newPosts in
            guard let self = self else { return }

            self.insertNewRowsInCollectionNode(newPosts: newPosts, for: collectionNode)
            context.completeBatchFetching(true)
        }
    }

    // MARK: - Data Retrieval

    /// Retrieves the next page of posts and executes the completion block with the results.
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {

        let handleResponse: (Result) -> Void = { [weak self] result in
            var items: [[String: Any]] = []
            if case .success(let apiResponse) = result,
               let data = apiResponse.body?["data"] as? [[String: Any]],
               !data.isEmpty {
                items = data
                self?.page += 1
                print("Successfully retrieved \(data.count) posts for SelectedRootPostVC")
            }

            DispatchQueue.main.async {
                block(items)
            }
        }

        switch selectedLoadingMode {
        case .hashTags:
            APIManager.shared.getHashtagPost(tag: hashtag, page: page, completion: handleResponse)
        case .myPost:
            APIManager.shared.getMyPost(page: page, completion: handleResponse)
        case .userPost:
            APIManager.shared.getUserPost(userId: self.userId, page: page, completion: handleResponse)
        case .search:
            APIManager.shared.searchPost(query: keyword, page: page, completion: handleResponse)
        case .save:
            APIManager.shared.getSavedPost(page: page, completion: handleResponse)
        case .trending:
            APIManager.shared.getPostTrending(page: page, completion: handleResponse)
        case .none:
            DispatchQueue.main.async {
                block([])
            }
        }
    }

    // MARK: - Data Insertion

    /// Inserts new rows into the collection node.
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]], for collectionNode: ASCollectionNode) {
        guard !newPosts.isEmpty, posts.count <= 150 else { return }

        let uniquePosts = Set(posts)
        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !uniquePosts.contains($0) }

        guard !items.isEmpty else { return }

        posts.append(contentsOf: items)
        let indexPaths = (posts.count - items.count..<posts.count).map { IndexPath(row: $0, section: 0) }
        collectionNode.insertItems(at: indexPaths)
    }
}

extension SelectedRootPostVC: ASCollectionDataSource {
    
    // MARK: - ASCollectionDelegateFlowLayout

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

    // MARK: - ASCollectionDataSource

    /// Returns the number of sections in the collection node.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    /// Returns the number of items in a given section of the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    /// Returns a block that creates and configures a cell node for the item at the specified index path.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]

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

    // MARK: - Private Helpers

    /// Configures properties of a cell node.
    /// - Parameters:
    ///   - node: The `ASCellNode` to configure.
    ///   - indexPath: The index path of the node.
    private func configureNode(_ node: RootNode, at indexPath: IndexPath) {
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        node.automaticallyManagesSubnodes = true
    }
}

extension SelectedRootPostVC {

    // Constants for time delays
    private enum Constants {
        static let initialScrollDelay: TimeInterval = 0.25
        static let videoPlayDelay: TimeInterval = 0.25
    }

    /// Loads posts into the collection node.
    func loadPosts() {
        guard !posts.isEmpty else { return }

        let indexPaths = indexPathsForNewPosts()
        insertNewItems(at: indexPaths)

        guard let startIndex = startIndex, startIndex != 0 else { return }
        scrollToItem(at: startIndex)
    }

    // MARK: - Private Helper Methods

    /// Creates index paths for new posts.
    private func indexPathsForNewPosts() -> [IndexPath] {
        return (0..<posts.count).map { IndexPath(row: $0, section: 0) }
    }

    /// Inserts new items into the collection node.
    /// - Parameter indexPaths: An array of index paths where new items will be inserted.
    private func insertNewItems(at indexPaths: [IndexPath]) {
        collectionNode.performBatchUpdates({
            collectionNode.insertItems(at: indexPaths)
        }, completion: nil)
    }

    /// Scrolls to a specific item in the collection node after a delay.
    /// - Parameter index: The index to scroll to.
    private func scrollToItem(at index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.initialScrollDelay) { [weak self] in
            self?.performScrollToItem(at: index)
        }
    }

    /// Performs the action of scrolling to the item and starting video playback.
    /// - Parameter index: The index of the item to scroll to.
    private func performScrollToItem(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.videoPlayDelay) { [weak self] in
            self?.startVideoPlaybackIfNeeded(at: indexPath)
        }
    }

    /// Starts video playback if the node is a `RootNode`.
    /// - Parameter indexPath: The index path of the node.
    private func startVideoPlaybackIfNeeded(at indexPath: IndexPath) {
        guard let node = collectionNode.nodeForItem(at: indexPath) as? RootNode else { return }
        currentIndex = indexPath.row
        newPlayingIndex = indexPath.row
        isVideoPlaying = true
        node.playVideo(index: 0)
    }
}

extension SelectedRootPostVC {

    // MARK: - Collection Node Setup

    /// Sets up the collection node with layout, appearance, and constraints.
    func setupCollectionNode() {
        configureFlowLayout()
        configureCollectionNodeProperties()
        addCollectionNodeToView()
        applyStyleToCollectionNode()
        wireDelegates()
    }

    /// Configures the flow layout for the collection node.
    private func configureFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    }

    /// Configures properties of the collection node.
    private func configureCollectionNodeProperties() {
        collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        collectionNode.leadingScreensForBatching = 2.0
        collectionNode.view.contentInsetAdjustmentBehavior = .never
        collectionNode.backgroundColor = .blue
    }

    /// Adds the collection node to the view and sets up constraints.
    private func addCollectionNodeToView() {
        contentView.addSubview(collectionNode.view)
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionNode.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionNode.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionNode.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionNode.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// Applies style and appearance settings to the collection node.
    private func applyStyleToCollectionNode() {
        collectionNode.view.isPagingEnabled = true
        collectionNode.view.backgroundColor = .clear
        collectionNode.view.showsVerticalScrollIndicator = false
        collectionNode.view.allowsSelection = false
        collectionNode.view.contentInsetAdjustmentBehavior = .never
        collectionNode.needsDisplayOnBoundsChange = true
    }

    // MARK: - Delegate Configuration

    /// Sets up delegates for the collection node.
    func wireDelegates() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
    }
}

// MARK: - Video Playback Control Extension

// This extension provides methods to control video playback within the FeedViewController, including pausing and playing videos.

extension SelectedRootPostVC {
    
    // Pauses the video at a specific index and optionally seeks to the start.
    func hideStitchedView(index: Int) {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
            cell.hideStitchedView()
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

extension SelectedRootPostVC {

    // MARK: - Post Actions
    
    // MARK: - Removing Post from List

    /// Removes the selected post from the list and updates the collection view.
    @objc func removePost(_ sender: AnyObject) {
        guard let deletingPost = editeddPost, let indexPath = posts.firstIndex(of: deletingPost) else { return }

        posts.removeObject(deletingPost)

        // Reload the collection node if no more posts are available, otherwise delete the specific item.
        if posts.isEmpty {
            collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            navigationController?.popViewController(animated: true)
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
            print(error)
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
            collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            navigationController?.popViewController(animated: true)
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

    /// Determines whether the feed should be refreshed.
    /// - Parameters:
    ///   - lastLoadTime: The last time the feed was loaded.
    ///   - thresholdTime: The time threshold for deciding whether to refresh.
    /// - Returns: Boolean indicating whether the feed should be refreshed.
    private func shouldRefreshFeed(lastLoadTime: Date?, comparedTo thresholdTime: Date) -> Bool {
        return lastLoadTime == nil || lastLoadTime! < thresholdTime
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

extension SelectedRootPostVC {

    // MARK: - Loading Animation Handling

    /// Shows a loading animation.
    func showLoading() {
        if firstAnimated {
            setupLoadingView()
            loadAndSetLoadingAnimation()
            firstAnimated = false
            
            hideLoading()
        }
    }

    /// Hides the loading animation.
    func hideLoading() {
        performLoadingAnimationFadeOut()
    }

    // MARK: - Private Helper Methods

    /// Sets up the initial state of the loading view.
    private func setupLoadingView() {
        loadingView.backgroundColor = .white
    }

    /// Loads and sets the loading animation.
    private func loadAndSetLoadingAnimation() {
        DispatchQueue.global(qos: .background).async {
            do {
                let gifData = try self.loadGifData(resourceName: "fox2", type: "gif")
                DispatchQueue.main.async { [weak self] in
                    self?.setLoadingImage(with: gifData)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    /// Loads GIF data from the specified resource.
    private func loadGifData(resourceName: String, type: String) throws -> Data? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: type) else { return nil }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    /// Sets the loading image with the provided GIF data.
    private func setLoadingImage(with gifData: Data?) {
        guard let gifData = gifData else { return }
        let image = FLAnimatedImage(animatedGIFData: gifData)
        loadingImage.animatedImage = image
    }

    /// Performs the fade-out animation for the loading view and then hides it.
    private func performLoadingAnimationFadeOut() {
        delay(1) { [weak self] in
            UIView.animate(withDuration: 0.5, animations: {
                self?.loadingView.alpha = 0
            }, completion: { _ in
                self?.finalizeLoadingViewHide()
            })
        }
    }

    /// Finalizes the hiding of the loading view.
    private func finalizeLoadingViewHide() {
        guard loadingView.alpha == 0 else { return }
        
        loadingView.isHidden = true
        loadingImage.stopAnimating()
        loadingImage.animatedImage = nil
        loadingImage.image = nil
        loadingImage.removeFromSuperview()
    }

}

