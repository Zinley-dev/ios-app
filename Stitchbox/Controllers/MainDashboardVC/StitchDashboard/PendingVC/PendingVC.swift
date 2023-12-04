//
//  PendingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/15/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class PendingVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
   
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var contentView: UIView!

   
    var myPost = [PostModel]()
    var waitPost = [PostModel]()
    var lastContentOffset: CGFloat = 0
    var myCollectionNode: ASCollectionNode!
    var waitCollectionNode: ASCollectionNode!
    var imageIndex: Int?
    var myPage = 1
    var waitPage = 1
    var allowLoadingWaitList = false
    var prevIndexPath: IndexPath?
    var firstLoad = true
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var firstWaitReload = true
    var rootPost: PostModel!
    var refresh_request = false
    
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionNodes()
        configurePullControl()
    }

    /// Configures the pull-to-refresh control.
    private func configurePullControl() {
        if #available(iOS 10.0, *) {
            waitCollectionNode.view.refreshControl = pullControl
        } else {
            myCollectionNode.view.addSubview(pullControl)
        }

        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
    }
    
    /// Called when the pull-to-refresh control is activated.
    @objc private func refreshListData(_ sender: Any) {
        clearAllData()
    }
    
    /// Clears all data and initiates data update.
    @objc private func clearAllData() {
        guard rootPost != nil else {
            endRefreshing()
            return
        }

        refresh_request = true
        waitPage = 1
        currentIndex = 0
        updateData()
    }

    /// Ends the refreshing animation of the pull control.
    private func endRefreshing() {
        if pullControl.isRefreshing {
            pullControl.endRefreshing()
        }
    }
    
}

extension PendingVC {
    
    /// Updates data for the wait list.
    func updateData() {
        retrieveNextPageForWaitListWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            
            if !newPosts.isEmpty {
                self.handleNewPosts(newPosts)
            } else {
                self.handleNoNewPosts()
            }
            
            self.finishRefreshingIfNecessary()
        }
    }

    // MARK: - Private Helper Methods

    /// Handles the scenario where new posts are retrieved.
    /// - Parameter newPosts: The new posts that were retrieved.
    private func handleNewPosts(_ newPosts: [[String: Any]]) {
        insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
    }

    /// Handles the scenario where no new posts are retrieved.
    private func handleNoNewPosts() {
        refresh_request = false
        waitPost.removeAll()
        waitCollectionNode.reloadData()
        updateEmptyStateForWaitCollectionNode()
    }

    /// Updates the empty state for the wait collection node.
    private func updateEmptyStateForWaitCollectionNode() {
        if waitPost.isEmpty {
            waitCollectionNode.view.setEmptyMessage("No stitch found", color: .black)
        } else {
            waitCollectionNode.view.restore()
        }
    }

    /// Ends the refreshing animation if it is in progress.
    private func finishRefreshingIfNecessary() {
        if pullControl.isRefreshing {
            pullControl.endRefreshing()
        }
    }
}



extension PendingVC: ASCollectionDelegate {

    // MARK: - Item Size Configuration

    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        if collectionNode == myCollectionNode {
            return sizeRangeForMyCollectionNode()
        } else {
            return sizeRangeForWaitCollectionNode()
        }
    }

    // MARK: - Batch Fetching Configuration

    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        if collectionNode == myCollectionNode {
            return true
        } else {
            return allowLoadingWaitList
        }
    }

    // MARK: - Private Helper Methods

    /// Calculates the size range for items in 'My Collection Node'.
    private func sizeRangeForMyCollectionNode() -> ASSizeRange {
        let height = contentView.layer.frame.height
        let width = height * 9 / 13.5
        let size = CGSize(width: width, height: height)
        return ASSizeRangeMake(size, size)
    }

    /// Calculates the size range for items in 'Wait Collection Node'.
    private func sizeRangeForWaitCollectionNode() -> ASSizeRange {
        let height = pendingView.layer.frame.height
        let width = pendingView.layer.frame.width
        let size = CGSize(width: width, height: height)
        return ASSizeRangeMake(size, size)
    }
}


extension PendingVC: ASCollectionDataSource {
    
    // MARK: - Collection Node Section Configuration

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        switch collectionNode {
        case myCollectionNode:
            return handleEmptyState(for: myCollectionNode, with: myPost, emptyMessage: "No post found")
        case waitCollectionNode:
            return handleEmptyState(for: waitCollectionNode, with: waitPost, emptyMessage: "No stitch found")
        default:
            return 0
        }
    }
    
    // MARK: - Cell Node Configuration

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        if collectionNode == myCollectionNode {
            let post = myPost[indexPath.row]
            return { StitchControlNode(with: post) }
        } else {
            let post = waitPost[indexPath.row]
            return {
                let node = PendingNode(with: post)
                // Node setup for PendingNode, if needed.
                node.neverShowPlaceholders = true // Example of setup
                // Add more setup code here if required.
                return node
            }
        }
    }

    // MARK: - Batch Fetching

    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        if collectionNode == myCollectionNode {
            retrieveNextPageForMyPost(context: context)
        } else if collectionNode == waitCollectionNode {
            retrieveNextPageForWaitList(context: context)
        }
    }

    // MARK: - Private Helper Methods

    /// Handles the empty state for a collection node and returns the item count.
    private func handleEmptyState(for collectionNode: ASCollectionNode, with posts: [PostModel], emptyMessage: String) -> Int {
        if posts.isEmpty {
            collectionNode.view.setEmptyMessage(emptyMessage, color: .black)
            return 0
        } else {
            collectionNode.view.restore()
            return posts.count
        }
    }

    /// Retrieves the next page for 'My Post' collection node and updates the context.
    private func retrieveNextPageForMyPost(context: ASBatchContext) {
        retrieveNextPageForMyPostWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNodeForMyPost(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }

    /// Retrieves the next page for 'Wait List' collection node and updates the context.
    private func retrieveNextPageForWaitList(context: ASBatchContext) {
        if !refresh_request {
            retrieveNextPageForWaitListWithCompletion { [weak self] newPosts in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
                context.completeBatchFetching(true)
            }
        } else {
            context.completeBatchFetching(true)
        }
    }
}

extension PendingVC {
    
    // MARK: - Collection Node Setup

    /// Sets up the collection nodes with their respective layouts and styles.
    func setupCollectionNodes() {
        setupMyCollectionNode()
        setupWaitCollectionNode()
        applyStyleToCollectionNodes()
        myCollectionNode.reloadData()
    }

    // MARK: - Private Setup Methods

    /// Sets up 'My Collection Node' with specific layout and constraints.
    private func setupMyCollectionNode() {
        let layout = createFlowLayout(horizontalScroll: true, lineSpacing: 10, interitemSpacing: 10)
        myCollectionNode = ASCollectionNode(collectionViewLayout: layout)
        configureCollectionNode(myCollectionNode, in: contentView)
    }

    /// Sets up 'Wait Collection Node' with specific layout and constraints.
    private func setupWaitCollectionNode() {
        let layout = createFlowLayout(horizontalScroll: true, lineSpacing: 0, interitemSpacing: 0)
        waitCollectionNode = ASCollectionNode(collectionViewLayout: layout)
        configureCollectionNode(waitCollectionNode, in: pendingView)
    }

    /// Creates a flow layout with specified parameters.
    private func createFlowLayout(horizontalScroll: Bool, lineSpacing: CGFloat, interitemSpacing: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = horizontalScroll ? .horizontal : .vertical
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interitemSpacing
        return layout
    }

    /// Configures a collection node with data source, delegate, and constraints.
    private func configureCollectionNode(_ node: ASCollectionNode, in superview: UIView) {
        node.automaticallyRelayoutOnLayoutMarginsChanges = true
        node.leadingScreensForBatching = 2.0
        node.view.contentInsetAdjustmentBehavior = .never
        node.dataSource = self
        node.delegate = self

        superview.addSubview(node.view)
        node.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            node.view.topAnchor.constraint(equalTo: superview.topAnchor),
            node.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            node.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            node.view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }

    /// Applies styling to collection nodes.
    private func applyStyleToCollectionNodes() {
        styleCollectionNode(myCollectionNode, isPagingEnabled: false)
        styleCollectionNode(waitCollectionNode, isPagingEnabled: true)
    }

    /// Styles a given collection node.
    private func styleCollectionNode(_ node: ASCollectionNode, isPagingEnabled: Bool) {
        node.view.isPagingEnabled = isPagingEnabled
        node.view.backgroundColor = .clear
        node.view.showsVerticalScrollIndicator = false
        node.view.allowsSelection = true
        node.view.contentInsetAdjustmentBehavior = .never
    }

    // MARK: - Collection Node Delegate Methods

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode else { return }
        handleMyCollectionNodeSelection(at: indexPath)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode else { return }
        if let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
    }

    // MARK: - Selection Handling

    /// Handles selection for 'My Collection Node'.
    private func handleMyCollectionNodeSelection(at indexPath: IndexPath) {
        rootPost = myPost[indexPath.row]
        
        guard prevIndexPath != indexPath else { return }
        prevIndexPath = indexPath
        allowLoadingWaitList = true
        
        myCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        styleSelectedCellInMyCollectionNode(at: indexPath)

        if !waitPost.isEmpty {
            resetWaitCollectionNode()
        } else {
            waitCollectionNode.reloadData()
        }
    }

    /// Styles the selected cell in 'My Collection Node'.
    private func styleSelectedCellInMyCollectionNode(at indexPath: IndexPath) {
        if let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.secondary.cgColor
        }
    }

    /// Resets 'Wait Collection Node' upon selection in 'My Collection Node'.
    private func resetWaitCollectionNode() {
        waitPost.removeAll()
        waitPage = 1
        firstWaitReload = true
        waitCollectionNode.performBatchUpdates({
            waitCollectionNode.reloadData()
        }, completion: nil)
    }

    // MARK: - Other methods
    // ...
}



extension PendingVC {

    /// Retrieves the next page for 'My Post' and executes the completion block with the results.
    /// - Parameter block: A completion block that receives an array of dictionaries representing posts.
    func retrieveNextPageForMyPostWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getMyWaitlist(page: myPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                self.handleMyPostApiResponse(apiResponse, completion: block)
            case .failure(let error):
                self.handleMyPostApiError(error, completion: block)
            }
        }
    }

    // MARK: - Private Methods

    /// Handles the API response for 'My Post'.
    /// - Parameters:
    ///   - apiResponse: The response from the API.
    ///   - completion: The completion block to execute with the result.
    private func handleMyPostApiResponse(_ apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            executeCompletionWithEmptyResult(completion)
            return
        }

        print("Successfully retrieved \(data.count) posts.")
        myPage += 1
        DispatchQueue.main.async {
            completion(data)
        }
    }

    /// Handles API error scenarios for 'My Post'.
    /// - Parameters:
    ///   - error: The error encountered.
    ///   - completion: The completion block to execute with the result.
    private func handleMyPostApiError(_ error: Error, completion: @escaping ([[String: Any]]) -> Void) {
        print(error)
        executeCompletionWithEmptyResult(completion)
    }

    /// Executes the completion block with an empty result.
    /// - Parameter completion: The completion block to execute.
    private func executeCompletionWithEmptyResult(_ completion: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            completion([[String: Any]]())
        }
    }

    // MARK: - Other methods
    // ...
}


extension PendingVC {

    /// Retrieves the next page for the waitlist and executes the completion block with the results.
    /// - Parameter block: A completion block that receives an array of dictionaries representing posts.
    func retrieveNextPageForWaitListWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getStitchWaitList(rootId: rootPost.id, page: waitPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                self.handleApiResponse(apiResponse, completion: block)
            case .failure(let error):
                self.handleApiError(error, completion: block)
            }
        }
    }

    // MARK: - Private Methods

    /// Handles the API response.
    /// - Parameters:
    ///   - apiResponse: The response from the API.
    ///   - completion: The completion block to execute with the result.
    private func handleApiResponse(_ apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            executeCompletionWithEmptyResult(completion)
            return
        }

        print("Successfully retrieved \(data.count) posts.")
        waitPage += 1
        DispatchQueue.main.async {
            completion(data)
        }
    }

    /// Handles API error scenarios.
    /// - Parameters:
    ///   - error: The error encountered.
    ///   - completion: The completion block to execute with the result.
    private func handleApiError(_ error: Error, completion: @escaping ([[String: Any]]) -> Void) {
        print(error)
        executeCompletionWithEmptyResult(completion)
    }

}


extension PendingVC {

    /// Inserts new rows in the collection node for 'My Post'.
    /// - Parameter newPosts: Array of new posts to be inserted, represented as dictionaries.
    func insertNewRowsInCollectionNodeForMyPost(newPosts: [[String: Any]]) {
        // Early exit if there are no new posts.
        guard !newPosts.isEmpty else { return }

        // Process and append new posts.
        let newItems = processNewMyPosts(newPosts)

        // Insert new items into the collection node.
        insertNewItemsInMyCollectionNode(newItems)

        // Handle additional setup on the first load.
        handleFirstLoadForMyPosts()
    }

    // MARK: - Private Methods

    /// Processes new posts for 'My Post' and appends them to the current posts.
    /// - Parameter newPosts: Array of new posts.
    /// - Returns: Array of processed `PostModel`.
    private func processNewMyPosts(_ newPosts: [[String: Any]]) -> [PostModel] {
        var items = [PostModel]()
        for postData in newPosts {
            if let item = PostModel(JSON: postData), !myPost.contains(item) {
                myPost.append(item)
                items.append(item)
            }
        }
        return items
    }

    /// Inserts new items into 'My Collection' node.
    /// - Parameter items: Array of `PostModel` to be inserted.
    private func insertNewItemsInMyCollectionNode(_ items: [PostModel]) {
        guard !items.isEmpty else { return }

        let startIndex = myPost.count - items.count
        let indexPaths = (startIndex..<(startIndex + items.count)).map { IndexPath(row: $0, section: 0) }
        
        myCollectionNode.insertItems(at: indexPaths)
    }

    /// Handles first load setup for 'My Post'.
    private func handleFirstLoadForMyPosts() {
        guard firstLoad, !myPost.isEmpty else { return }

        firstLoad = false
        let firstIndexPath = IndexPath(item: 0, section: 0)
        setupInitialCellAppearance(at: firstIndexPath)
        rootPost = myPost[0]

        allowLoadingWaitList = true
        waitCollectionNode.reloadData()
    }

    /// Sets up the appearance of the initial cell.
    /// - Parameter indexPath: IndexPath of the initial cell.
    private func setupInitialCellAppearance(at indexPath: IndexPath) {
        guard let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode else {
            print("Couldn't cast cell as StitchControlNode")
            return
        }

        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.secondary.cgColor
        cell.isSelected = true

        myCollectionNode.selectItem(at: indexPath, animated: false, scrollPosition: [])
        myCollectionNode.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    // MARK: - Other methods
    // ...
}


extension PendingVC {

    /// Inserts new rows in the collection node for wait list.
    /// - Parameter newPosts: Array of new posts to be inserted, represented as dictionaries.
    func insertNewRowsInCollectionNodeForWaitList(newPosts: [[String: Any]]) {
        // Early exit if there are no new posts.
        guard !newPosts.isEmpty else { return }

        // Refresh logic.
        refreshCollectionNodeIfNeeded()

        // Process and append new posts.
        let newItems = processNewPosts(newPosts)

        // Insert new items into the collection node.
        insertNewItemsInCollectionNode(newItems)

        // Play video for the first item if this is the first reload and posts are available.
        handleFirstWaitReload()
    }

    // MARK: - Private Methods

    /// Refreshes the collection node if needed.
    private func refreshCollectionNodeIfNeeded() {
        guard refresh_request else { return }
        
        refresh_request = false
        waitPost.removeAll()
        waitCollectionNode.reloadData()
    }

    /// Processes new posts and appends them to the current posts.
    /// - Parameter newPosts: Array of new posts.
    /// - Returns: Array of processed `PostModel`.
    private func processNewPosts(_ newPosts: [[String: Any]]) -> [PostModel] {
        var items = [PostModel]()
        for postData in newPosts {
            if let item = PostModel(JSON: postData), !waitPost.contains(item) {
                waitPost.append(item)
                items.append(item)
            }
        }
        return items
    }

    /// Inserts new items into the collection node.
    /// - Parameter items: Array of `PostModel` to be inserted.
    private func insertNewItemsInCollectionNode(_ items: [PostModel]) {
        guard !items.isEmpty else { return }

        let startIndex = waitPost.count - items.count
        let indexPaths = (startIndex..<(startIndex + items.count)).map { IndexPath(row: $0, section: 0) }
        
        waitCollectionNode.insertItems(at: indexPaths)
    }

    /// Handles video playback for the first wait reload.
    private func handleFirstWaitReload() {
        if firstWaitReload && !waitPost.isEmpty {
            firstWaitReload = false
            currentIndex = 0
            playVideo(atIndex: 0)
        }
    }

    // MARK: - Video Playback Methods
    // ...
}


extension PendingVC {

    // MARK: - ScrollView Delegate

    /// Handles logic when the scroll view did scroll.
    /// - Parameter scrollView: The scrollView instance that scrolled.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Early exit if there are no posts or if it's not the targeted collection view.
        guard !waitPost.isEmpty, scrollView == waitCollectionNode.view else { return }

        // Handling horizontal scrolling.
        guard lastContentOffset != scrollView.contentOffset.x else { return }
        lastContentOffset = scrollView.contentOffset.x

        // Compute the visible area of the collection view.
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visibleCells = getVisibleCells(from: visibleRect)

        // Determine the closest visible video to the center.
        if let closestIndex = findClosestVisibleVideoIndex(in: visibleCells, with: visibleRect) {
            handleVideoPlayback(for: closestIndex)
        } else {
            // If no video is found, pause the currently playing video.
            if let currentIndex = currentIndex {
                pauseVideo(atIndex: currentIndex)
                self.currentIndex = nil
            }
        }
    }

    // MARK: - Private Methods

    /// Retrieves visible cells from the collection node.
    /// - Parameter visibleRect: The visible rectangle in the collection view.
    /// - Returns: Array of visible `PendingNode`.
    private func getVisibleCells(from visibleRect: CGRect) -> [PendingNode] {
        return waitCollectionNode.visibleNodes.compactMap { $0 as? PendingNode }
    }

    /// Finds the index of the visible video closest to the center of the screen.
    /// - Parameters:
    ///   - cells: An array of visible `PendingNode`.
    ///   - visibleRect: The visible rectangle in the collection view.
    /// - Returns: The index of the closest video or nil if none found.
    private func findClosestVisibleVideoIndex(in cells: [PendingNode], with visibleRect: CGRect) -> Int? {
        var minDistanceFromCenter: CGFloat = .infinity
        var closestIndex: Int?

        for cell in cells {
            let distanceFromCenter = computeDistanceFromCenter(for: cell, in: visibleRect)
            if distanceFromCenter < minDistanceFromCenter {
                closestIndex = cell.indexPath?.row
                minDistanceFromCenter = distanceFromCenter
            }
        }

        return closestIndex
    }

    /// Computes the distance of a cell from the center of the visible rect.
    /// - Parameters:
    ///   - cell: The cell to compute distance for.
    ///   - visibleRect: The visible rectangle in the collection view.
    /// - Returns: The distance from the center.
    private func computeDistanceFromCenter(for cell: PendingNode, in visibleRect: CGRect) -> CGFloat {
        let cellRect = cell.view.convert(cell.bounds, to: waitCollectionNode.view)
        let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
        return abs(cellCenter.x - visibleRect.midX) // X-coordinate for horizontal scroll
    }

    /// Handles video playback logic for a given index.
    /// - Parameter index: The index of the cell to play video for.
    private func handleVideoPlayback(for index: Int) {
        guard index < waitPost.count else { return }

        let post = waitPost[index]
        if !post.muxPlaybackId.isEmpty {
            // Logic for playing a video.
            if currentIndex != index {
                if let currentIndex = currentIndex {
                    pauseVideo(atIndex: currentIndex)
                }
                currentIndex = index
                playVideo(atIndex: index)
                isVideoPlaying = true
            }
        } else {
            // Logic for handling non-video content.
            imageIndex = index
        }
    }


}


extension PendingVC {

    // MARK: - Video Control Methods

    /// Pauses the video at the specified index.
    /// - Parameter index: The index of the video to be paused.
    func pauseVideo(atIndex index: Int) {
        guard let cell = getPendingNodeCell(at: index) else { return }
        cell.pauseVideo()
    }

    /// Plays the video at the specified index.
    /// - Parameter index: The index of the video to be played.
    func playVideo(atIndex index: Int) {
        guard let cell = getPendingNodeCell(at: index) else { return }
        cell.playVideo()
    }

    // MARK: - Private Helpers

    /// Retrieves the PendingNode cell for the given index.
    /// - Parameter index: The index of the cell to retrieve.
    /// - Returns: An optional PendingNode instance.
    private func getPendingNodeCell(at index: Int) -> PendingNode? {
        let indexPath = IndexPath(row: index, section: 0)
        return self.waitCollectionNode.nodeForItem(at: indexPath) as? PendingNode
    }
}


extension PendingVC {

    // MARK: - Public Methods

    /// Approves a post and updates the UI accordingly.
    /// - Parameters:
    ///   - node: The node representing the post to be approved.
    ///   - post: The post model to be approved.
    func approvePost(node: PendingNode, post: PostModel) {
        print("approvePost")

        guard let rootId = rootPost?.id else {
            showErrorAlert("Error", msg: "Root post not found.")
            return
        }

        presentSwiftLoader()

        APIManager.shared.acceptStitch(rootId: rootId, memberId: post.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleStitchApprovalResult(result, for: post)
            }
        }
    }

    // MARK: - Private Helpers

    /// Handles the result of the stitch approval request.
    /// - Parameters:
    ///   - result: The result of the stitch approval request.
    ///   - post: The post model associated with the request.
    private func handleStitchApprovalResult(_ result: Result, for post: PostModel) {
        SwiftLoader.hide()

        switch result {
        case .success:
            updateUIAfterStitchApproval(for: post)

        case .failure(let error):
            showErrorAlert("Oops!", msg: "Couldn't approve stitch at this time, please try again. \(error.localizedDescription)")
        }
    }

    /// Updates the UI after a stitch has been successfully approved.
    /// - Parameter post: The post model that was approved.
    private func updateUIAfterStitchApproval(for post: PostModel) {
        guard let indexPath = waitPost.firstIndex(of: post) else { return }

        waitPost.removeObject(post)
        waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])

        // Play next video if it exists.
        if indexPath < waitPost.count {
            playVideo(atIndex: indexPath)
        } else if waitPost.count == 1 {
            playVideo(atIndex: 0)
        }
    }
}



extension PendingVC {

    // MARK: - Public Methods

    /// Declines a post and updates the UI accordingly.
    /// - Parameters:
    ///   - node: The node representing the post to be declined.
    ///   - post: The post model to be declined.
    func declinePost(node: PendingNode, post: PostModel) {
        print("declinePost")

        guard let rootId = rootPost?.id else {
            showErrorAlert("Error", msg: "Root post not found.")
            return
        }

        presentSwiftLoader()

        APIManager.shared.deniedStitch(rootId: rootId, memberId: post.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleStitchDenialResult(result, for: post)
            }
        }
    }

    // MARK: - Private Helpers

    /// Handles the result of the stitch denial request.
    /// - Parameters:
    ///   - result: The result of the stitch denial request.
    ///   - post: The post model associated with the request.
    private func handleStitchDenialResult(_ result: Result, for post: PostModel) {
        SwiftLoader.hide()

        switch result {
        case .success:
            updateUIAfterStitchDenial(for: post)

        case .failure(let error):
            showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again. \(error.localizedDescription)")
        }
    }

    /// Updates the UI after a stitch has been successfully denied.
    /// - Parameter post: The post model that was declined.
    private func updateUIAfterStitchDenial(for post: PostModel) {
        guard let indexPath = waitPost.firstIndex(of: post) else { return }

        waitPost.removeObject(post)
        waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])

        // Play next video or first video if only one remains.
        let nextIndex = min(indexPath, waitPost.count - 1)
        playVideo(atIndex: nextIndex)
    }
}



extension PendingVC {

    /// Displays an error alert with a given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The message of the alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = createAlertController(withTitle: title, message: msg)
        present(alert, animated: true)
    }

    // MARK: - Private Helper Methods

    /// Creates and returns a UIAlertController with specified title and message.
    /// - Parameters:
    ///   - title: The title for the alert.
    ///   - message: The message for the alert.
    /// - Returns: A configured UIAlertController instance.
    private func createAlertController(withTitle title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        return alert
    }
}
