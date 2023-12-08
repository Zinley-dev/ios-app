//
//  StitchToVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/22/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class StitchToVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
   
    @IBOutlet weak var stitchToView: UIView!
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

        setupCollectionNode()
        setupPullControl()
    }

    @objc private func refreshListData(_ sender: Any) {
        clearAllData()
    }
    
    @objc private func clearAllData() {
        guard rootPost != nil else {
            endRefreshingIfNecessary()
            return
        }

        prepareForDataRefresh()
        updateData()
    }

    // MARK: - Private Helper Methods

    /// Sets up the pull-to-refresh control.
    private func setupPullControl() {
        if #available(iOS 10.0, *) {
            waitCollectionNode.view.refreshControl = pullControl
        } else {
            myCollectionNode.view.addSubview(pullControl)
        }

        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
    }

    /// Prepares the view controller for data refresh.
    private func prepareForDataRefresh() {
        refresh_request = true
        waitPage = 1
        currentIndex = 0
    }

}

extension StitchToVC {

    /// Updates the data by fetching the next page of posts and refreshing the collection node.
    func updateData() {
        retrieveNextPageForStitchtWithCompletion { [weak self] newPosts in
            guard let self = self else { return }

            if newPosts.isEmpty {
                self.handleEmptyNewPosts()
            } else {
                self.insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
            }

            self.endRefreshingIfNecessary()
        }
    }

    // MARK: - Private Helper Methods

    /// Handles the scenario when the new posts array is empty.
    private func handleEmptyNewPosts() {
        refresh_request = false
        waitPost.removeAll()
        updateWaitCollectionNodeForEmptyPosts()
    }

    /// Updates the wait collection node based on whether there are posts available.
    private func updateWaitCollectionNodeForEmptyPosts() {
        if waitPost.isEmpty {
            waitCollectionNode.view.setEmptyMessage("No stitch found", color: .black)
        } else {
            waitCollectionNode.view.restore()
        }

        waitCollectionNode.reloadData()
    }

    /// Ends the refreshing animation on the pull control, if applicable.
    private func endRefreshingIfNecessary() {
        if pullControl.isRefreshing {
            pullControl.endRefreshing()
        }
    }
}


extension StitchToVC: ASCollectionDelegate {

    // MARK: - ASCollectionDelegate

    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return sizeRangeForItemInCollectionNode(collectionNode)
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return shouldPerformBatchFetch(in: collectionNode)
    }

    // MARK: - Private Helper Methods

    /// Calculates the size range for an item in a given collection node.
    /// - Parameter collectionNode: The collection node containing the item.
    /// - Returns: The size range (minimum and maximum size) for the item.
    private func sizeRangeForItemInCollectionNode(_ collectionNode: ASCollectionNode) -> ASSizeRange {
        let (width, height) = dimensionsForCollectionNode(collectionNode)

        let size = CGSize(width: width, height: height)
        return ASSizeRangeMake(size, size)
    }

    /// Determines the dimensions for a collection node based on its type.
    /// - Parameter collectionNode: The collection node to determine dimensions for.
    /// - Returns: A tuple containing the width and height.
    private func dimensionsForCollectionNode(_ collectionNode: ASCollectionNode) -> (CGFloat, CGFloat) {
        if collectionNode == myCollectionNode {
            let height = contentView.layer.frame.height
            return (height * 9 / 13.5, height)
        } else {
            let view = stitchToView.layer.frame
            return (view.width, view.height)
        }
    }

    /// Determines whether batch fetching should be performed for a given collection node.
    /// - Parameter collectionNode: The collection node in question.
    /// - Returns: A Boolean value indicating whether batch fetching should be performed.
    private func shouldPerformBatchFetch(in collectionNode: ASCollectionNode) -> Bool {
        if collectionNode == myCollectionNode {
            return true
        } else {
            return allowLoadingWaitList
        }
    }
}

extension StitchToVC: ASCollectionDataSource {

    // MARK: - ASCollectionDataSource

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return itemCountForCollectionNode(collectionNode)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return cellNodeBlockForCollectionNode(collectionNode, atIndexPath: indexPath)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        handleBatchFetchForCollectionNode(collectionNode, withContext: context)
    }

    // MARK: - Private Helper Methods

    private func itemCountForCollectionNode(_ collectionNode: ASCollectionNode) -> Int {
        if collectionNode == myCollectionNode {
            updateEmptyMessageIfNeeded(for: myCollectionNode, isEmpty: myPost.isEmpty, message: "No post found")
            return myPost.count
        } else {
            updateEmptyMessageIfNeeded(for: waitCollectionNode, isEmpty: waitPost.isEmpty, message: "No stitch found")
            return waitPost.count
        }
    }

    private func updateEmptyMessageIfNeeded(for collectionNode: ASCollectionNode, isEmpty: Bool, message: String) {
        if isEmpty {
            collectionNode.view.setEmptyMessage(message, color: .black)
        } else {
            collectionNode.view.restore()
        }
    }

    private func cellNodeBlockForCollectionNode(_ collectionNode: ASCollectionNode, atIndexPath indexPath: IndexPath) -> ASCellNodeBlock {
        let post = collectionNode == myCollectionNode ? myPost[indexPath.row] : waitPost[indexPath.row]

        return { [weak self] in
            let node = collectionNode == self?.myCollectionNode ? StitchControlNode(with: post) : StitchControlForRemoveNode(with: post, stitchTo: true)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"

            if collectionNode != self?.myCollectionNode {
                (node as? StitchControlForRemoveNode)?.unstitchBtn = { [weak self] node in
                    self?.unstitchPost(node: node as! StitchControlForRemoveNode, post: post)
                }
            }

            return node
        }
    }

}

extension StitchToVC {

    private func handleBatchFetchForCollectionNode(_ collectionNode: ASCollectionNode, withContext context: ASBatchContext) {
        // Early exit if the collection node is not one of the expected nodes or if refresh is requested for waitCollectionNode.
        guard collectionNode == myCollectionNode || (collectionNode == waitCollectionNode && !refresh_request) else {
            context.completeBatchFetching(true)
            return
        }

        if collectionNode == myCollectionNode {
            retrieveAndInsertForMyCollectionNode(context)
        } else if collectionNode == waitCollectionNode {
            retrieveAndInsertForWaitCollectionNode(context)
        }
    }

    // MARK: - Private Helper Methods

    private func retrieveAndInsertForMyCollectionNode(_ context: ASBatchContext) {
        retrieveNextPageForMyPostWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNodeForMyPost(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }

    private func retrieveAndInsertForWaitCollectionNode(_ context: ASBatchContext) {
        retrieveNextPageForStitchtWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }
}



extension StitchToVC {

    // MARK: - Setup Methods

    /// Sets up collection nodes with their respective layouts and styles.
    func setupCollectionNode() {
        setupMyCollectionNode()
        setupWaitCollectionNode()
    }

    // MARK: - Private Helper Methods

    /// Sets up 'myCollectionNode' with its layout and style.
    private func setupMyCollectionNode() {
        let flowLayout = createFlowLayout(horizontalSpacing: 10)
        myCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

        configureCollectionNode(myCollectionNode, in: contentView)
        applyStyle(to: myCollectionNode, isPagingEnabled: false)
    }

    /// Sets up 'waitCollectionNode' with its layout and style.
    private func setupWaitCollectionNode() {
        let flowLayout = createFlowLayout(horizontalSpacing: 0)
        waitCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

        configureCollectionNode(waitCollectionNode, in: stitchToView)
        applyStyle(to: waitCollectionNode, isPagingEnabled: true)
    }

    /// Creates a flow layout with specified horizontal spacing.
    /// - Parameter horizontalSpacing: The spacing between items in the flow layout.
    /// - Returns: A configured UICollectionViewFlowLayout instance.
    private func createFlowLayout(horizontalSpacing: CGFloat) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = horizontalSpacing
        flowLayout.minimumInteritemSpacing = horizontalSpacing
        return flowLayout
    }

    /// Configures a collection node and adds it to the specified view.
    /// - Parameters:
    ///   - node: The collection node to configure.
    ///   - view: The view to add the collection node's view.
    private func configureCollectionNode(_ node: ASCollectionNode, in view: UIView) {
        node.automaticallyRelayoutOnLayoutMarginsChanges = true
        node.leadingScreensForBatching = 2.0
        node.view.contentInsetAdjustmentBehavior = .never
        node.dataSource = self
        node.delegate = self

        addCollectionNodeView(node.view, to: view)
    }

    /// Adds a collection node's view as a subview to the specified view and sets constraints.
    /// - Parameters:
    ///   - view: The collection node's view to add.
    ///   - parentView: The parent view to add the collection node's view.
    private func addCollectionNodeView(_ view: UIView, to parentView: UIView) {
        parentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: parentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    /// Applies style settings to a collection node.
    /// - Parameters:
    ///   - node: The collection node to style.
    ///   - isPagingEnabled: A boolean value indicating whether paging is enabled.
    private func applyStyle(to node: ASCollectionNode, isPagingEnabled: Bool) {
        node.view.isPagingEnabled = isPagingEnabled
        node.view.backgroundColor = .clear
        node.view.showsVerticalScrollIndicator = false
        node.view.allowsSelection = true
        node.view.contentInsetAdjustmentBehavior = .never
    }
}


extension StitchToVC {

    // MARK: - ASCollectionNodeDelegate

    /// Handles the selection event of an item in the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node containing the item.
    ///   - indexPath: The index path of the selected item.
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode else { return }

        rootPost = myPost[indexPath.row]
        processSelectionChangeForItem(at: indexPath)
    }

    /// Handles the deselection event of an item in the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node containing the item.
    ///   - indexPath: The index path of the deselected item.
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode else { return }

        updateCellAppearanceAfterDeselection(at: indexPath)
    }

    // MARK: - Private Helper Methods

    /// Processes changes when a new item is selected in the collection node.
    /// - Parameter indexPath: The index path of the selected item.
    private func processSelectionChangeForItem(at indexPath: IndexPath) {
        guard prevIndexPath == nil || prevIndexPath != indexPath else { return }

        prevIndexPath = indexPath
        allowLoadingWaitList = true
        scrollToItemAndHighlight(at: indexPath)

        resetWaitPostsIfNeeded()
    }

    /// Scrolls to the specified item and updates its appearance to highlight it.
    /// - Parameter indexPath: The index path of the item to scroll to and highlight.
    private func scrollToItemAndHighlight(at indexPath: IndexPath) {
        myCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

        if let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
            styleSelectedCell(cell)
        }
    }


    /// Resets the wait posts if needed.
    private func resetWaitPostsIfNeeded() {
        guard !waitPost.isEmpty else {
            waitCollectionNode.reloadData()
            return
        }

        waitPost.removeAll()
        waitPage = 1
        firstWaitReload = true
        waitCollectionNode.performBatchUpdates({
            waitCollectionNode.reloadData()
        }, completion: nil)
    }

    /// Updates the appearance of the cell after it is deselected.
    /// - Parameter indexPath: The index path of the deselected item.
    private func updateCellAppearanceAfterDeselection(at indexPath: IndexPath) {
        if let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

extension StitchToVC {

    func retrieveNextPageForMyPostWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getMyStitch(page: myPage) { [weak self] result in
            guard let self = self else { return }
            self.handleApiResponse(result, updatePage: &self.myPage, completion: block)
        }
    }
    
    func retrieveNextPageForStitchtWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        print("rootPost.id: \(rootPost.id)")
        APIManager.shared.getStitchTo(pid: rootPost.id) { result in
            switch result {
            case .success(let apiResponse):
                self.handleStitchApiResponse(apiResponse, completion: block)
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    block([])
                }
            }
        }
    }

    // MARK: - Private Helper Methods

    private func handleApiResponse(_ result: Result, updatePage page: inout Int, completion: @escaping ([[String: Any]]) -> Void) {
        switch result {
        case .success(let apiResponse):
            guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            print("Successfully retrieved \(data.count) posts.")
            page += 1
            DispatchQueue.main.async {
                completion(data)
            }
        case .failure(let error):
            print(error)
            DispatchQueue.main.async {
                completion([])
            }
        }
    }

    private func handleStitchApiResponse(_ apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        DispatchQueue.main.async {
            completion(data)
        }
    }
}


extension StitchToVC {

    // MARK: - Private Helper Methods

    /// Handles the successful response from the API.
    /// - Parameters:
    ///   - apiResponse: The successful API response.
    ///   - completion: The completion block to be executed.
    private func handleSuccess(apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [String: Any], !data.isEmpty else {
            completionOnMainThread(with: [], completion: completion)
            return
        }

        completionOnMainThread(with: [data], completion: completion)
    }

    /// Handles the failure case from the API.
    /// - Parameter completion: The completion block to be executed.
    private func handleFailure(completion: @escaping ([[String: Any]]) -> Void) {
        completionOnMainThread(with: [], completion: completion)
    }

    /// Executes the completion block on the main thread with the given items.
    /// - Parameters:
    ///   - items: The items to pass to the completion block.
    ///   - completion: The completion block to be executed.
    private func completionOnMainThread(with items: [[String: Any]], completion: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            completion(items)
        }
    }
    

    // MARK: - Private Helper Methods

    /// Handles a refresh request if needed.
    private func handleRefreshRequestIfNeeded() {
        guard refresh_request else { return }

        refresh_request = false
        waitPost.removeAll()
        waitCollectionNode.reloadData()
    }

    /// Appends new PostModel objects from a given array of dictionaries.
    /// - Parameter newPosts: The array of dictionaries to convert.
    /// - Returns: An array of new PostModel objects.
    private func appendNewPostModels(from newPosts: [[String: Any]]) -> [PostModel] {
        var newItems = [PostModel]()

        newPosts.forEach { postDict in
            if let item = PostModel(JSON: postDict), !waitPost.contains(item) {
                waitPost.append(item)
                newItems.append(item)
            }
        }

        return newItems
    }

    /// Inserts new items into the collection node.
    /// - Parameter newItems: The new items to be inserted.
    private func insertNewItemsInCollectionNode(_ newItems: [PostModel]) {
        guard !newItems.isEmpty else { return }

        let startIndex = waitPost.count - newItems.count
        let endIndex = startIndex + newItems.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        waitCollectionNode.insertItems(at: indexPaths)
    }

    /// Handles the first reload of the wait posts if needed.
    private func handleFirstWaitReloadIfNeeded() {
        guard firstWaitReload, !waitPost.isEmpty else { return }

        firstWaitReload = false
        currentIndex = 0
    }
    
}

extension StitchToVC {

    // MARK: - UIScrollViewDelegate

    /// Handles the scroll view's scrolling event.
    /// - Parameter scrollView: The UIScrollView that has scrolled.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !waitPost.isEmpty, scrollView == waitCollectionNode.view else { return }

        // Process only horizontal scroll events.
        guard lastContentOffset != scrollView.contentOffset.x else { return }
        lastContentOffset = scrollView.contentOffset.x

        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visibleCells = waitCollectionNode.visibleNodes.compactMap { $0 as? StitchControlForRemoveNode }
        var minDistanceFromCenter = CGFloat.infinity
        var foundVisibleVideo = false

        // Determine the closest video to the center.
        for cell in visibleCells {
            let cellRect = cell.view.convert(cell.bounds, to: waitCollectionNode.view)
            let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let distanceFromCenter = abs(cellCenter.x - visibleRect.midX)

            if distanceFromCenter < minDistanceFromCenter {
                newPlayingIndex = cell.indexPath!.row
                minDistanceFromCenter = distanceFromCenter
            }
        }

        // Handle video play and pause based on visibility and scroll position.
        handleVideoPlaybackChange(foundVisibleVideo: &foundVisibleVideo)
    }

    // MARK: - Video Control Methods

    /// Pauses the video at the given index.
    /// - Parameter index: The index of the video to pause.
    func pauseVideo(atIndex: Int) {
        if let cell = waitCollectionNode.nodeForItem(at: IndexPath(row: atIndex, section: 0)) as? StitchControlForRemoveNode {
            cell.pauseVideo(shouldSeekToStart: true)
        }
    }

    /// Plays the video at the given index.
    /// - Parameter index: The index of the video to play.
    func playVideo(atIndex: Int) {
        if let cell = waitCollectionNode.nodeForItem(at: IndexPath(row: atIndex, section: 0)) as? StitchControlForRemoveNode {
            cell.playVideo()
        }
    }

    // MARK: - Private Helper Methods

    /// Handles changes in video playback based on the scrolling of the collection view.
    /// - Parameter foundVisibleVideo: A reference to the boolean indicating whether a visible video was found.
    private func handleVideoPlaybackChange(foundVisibleVideo: inout Bool) {
        if let newPlayingIndex = newPlayingIndex, newPlayingIndex < waitPost.count {
            if !waitPost[newPlayingIndex].muxPlaybackId.isEmpty {
                foundVisibleVideo = true
                imageIndex = nil
            } else {
                imageIndex = newPlayingIndex
            }
        }

        if foundVisibleVideo {
            updateCurrentPlayingVideo()
        } else if !isVideoPlaying && currentIndex != nil {
            pauseVideo(atIndex: currentIndex!)
            currentIndex = nil
        }
    }

    /// Updates the currently playing video based on the new index.
    private func updateCurrentPlayingVideo() {
        guard let newPlayingIndex = newPlayingIndex, currentIndex != newPlayingIndex else { return }
        if let currentIndex = currentIndex {
            pauseVideo(atIndex: currentIndex)
        }
        currentIndex = newPlayingIndex
        playVideo(atIndex: newPlayingIndex)
        isVideoPlaying = true
    }
}


extension StitchToVC {
    
    /// Attempts to unstitch a post and updates the UI accordingly.
    /// - Parameters:
    ///   - node: The StitchControlForRemoveNode to be unstitched.
    ///   - post: The PostModel associated with the node.
    func unstitchPost(node: StitchControlForRemoveNode, post: PostModel) {
        guard rootPost != nil else {
            showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again")
            return
        }

        presentSwiftLoader()
        performUnstitchRequest(rootId: post.id, memberId: rootPost.id)
    }

    /// Performs the unstitch API request.
    /// - Parameters:
    ///   - rootId: The ID of the root post.
    ///   - memberId: The ID of the member post.
    private func performUnstitchRequest(rootId: String, memberId: String) {
        APIManager.shared.unstitch(rootId: rootId, memberId: memberId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.handleSuccessfulUnstitch(postId: rootId)
            case .failure(let error):
                self.handleUnstitchFailure(error: error)
            }
        }
    }

    /// Handles the successful unstitch operation.
    /// - Parameter postId: The ID of the post that was unstitched.
    private func handleSuccessfulUnstitch(postId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()

            self.updatePostsAndCollection(postId: postId)
        }
    }

    /// Updates the posts and collection view after a successful unstitch.
    /// - Parameter postId: The ID of the post that was unstitched.
    private func updatePostsAndCollection(postId: String) {
        if let indexPath = waitPost.firstIndex(where: { $0.id == postId }) {
            waitPost.remove(at: indexPath)
            waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            playVideoIfNeededAfterUnstitch(at: indexPath)
        }
    }

    /// Plays the video at a given index if conditions are met after unstitching.
    /// - Parameter index: The index at which to play the video.
    private func playVideoIfNeededAfterUnstitch(at index: Int) {
        if index < waitPost.count {
            playVideo(atIndex: index)
        } else if waitPost.isEmpty {
            playVideo(atIndex: 0)
        }
    }

    /// Handles failure during the unstitch operation.
    /// - Parameter error: The error encountered during unstitching.
    private func handleUnstitchFailure(error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again. \(error.localizedDescription)")
        }
    }
    
}

extension StitchToVC {

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

extension StitchToVC {

    func insertNewRowsInCollectionNodeForMyPost(newPosts: [[String: Any]]) {
        let newItems = processNewPosts(newPosts, for: &myPost)
        insertItems(newItems, into: myCollectionNode)
        handleFirstLoadForMyPost()
    }

    func insertNewRowsInCollectionNodeForWaitList(newPosts: [[String: Any]]) {
        if refresh_request {
            refresh_request = false
            waitPost.removeAll()
            waitCollectionNode.reloadData()
        }

        let newItems = processNewPosts(newPosts, for: &waitPost)
        insertItems(newItems, into: waitCollectionNode)
        handleFirstWaitReload()
    }

    // MARK: - Private Helper Methods

    private func processNewPosts(_ newPosts: [[String: Any]], for currentPosts: inout [PostModel]) -> [PostModel] {
        var newItems = [PostModel]()
        for postData in newPosts {
            if let item = PostModel(JSON: postData), !currentPosts.contains(item) {
                currentPosts.append(item)
                newItems.append(item)
            }
        }
        return newItems
    }

    private func insertItems(_ items: [PostModel], into collectionNode: ASCollectionNode) {
        guard !items.isEmpty else { return }

        let startIndex = collectionNode.numberOfItems(inSection: 0)
        let indexPaths = (startIndex..<(startIndex + items.count)).map { IndexPath(row: $0, section: 0) }
        collectionNode.insertItems(at: indexPaths)
    }

    private func handleFirstLoadForMyPost() {
        if firstLoad, !myPost.isEmpty {
            firstLoad = false
            selectFirstItemInCollectionNode(myCollectionNode)
            rootPost = myPost[0]
            allowLoadingWaitList = true
            waitCollectionNode.reloadData()
        }
    }

    private func handleFirstWaitReload() {
        if firstWaitReload, !waitPost.isEmpty {
            firstWaitReload = false
            currentIndex = 0
        }
    }

    private func selectFirstItemInCollectionNode(_ collectionNode: ASCollectionNode) {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        if let cell = collectionNode.nodeForItem(at: firstIndexPath) as? StitchControlNode {
            styleSelectedCell(cell)
            collectionNode.selectItem(at: firstIndexPath, animated: false, scrollPosition: [])
            collectionNode.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
        } else {
            print("Couldn't cast cell")
        }
    }

    private func styleSelectedCell(_ cell: StitchControlNode) {
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.secondary.cgColor
        cell.isSelected = true
    }
}
