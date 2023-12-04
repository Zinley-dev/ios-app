//
//  ApprovedStitchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/22/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class ApprovedStitchVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
   
    @IBOutlet weak var stitchedView: UIView!
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
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionNodes()
        configureRefreshControl()
    }

    // MARK: - Refresh Control Setup

    /// Configures the refresh control for collection nodes.
    private func configureRefreshControl() {
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)

        if #available(iOS 10.0, *) {
            waitCollectionNode.view.refreshControl = pullControl
        } else {
            myCollectionNode.view.addSubview(pullControl)
        }
    }

    // MARK: - Refresh Actions

    /// Called when the list data needs to be refreshed.
    /// - Parameter sender: The control that initiated the refresh.
    @objc private func refreshListData(_ sender: Any) {
        clearAllData()
    }

    /// Clears all data and initiates data update.
    @objc private func clearAllData() {
        guard rootPost != nil else {
            endRefreshingIfNeeded()
            return
        }

        refresh_request = true
        waitPage = 1
        currentIndex = 0
        updateData()
    }

    // MARK: - Private Helpers

    /// Ends the refreshing process if applicable.
    private func endRefreshingIfNeeded() {
        if pullControl.isRefreshing {
            pullControl.endRefreshing()
        }
    }

}

extension ApprovedStitchVC {

    // MARK: - Data Update

    /// Updates the data by retrieving the next page for the wait list.
    func updateData() {
        retrieveNextPageForWaitListWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            
            self.processNewPosts(newPosts)
            self.updateWaitCollectionNode()
            self.endRefreshingIfNeeded()
        }
    }

    // MARK: - Private Helpers

    /// Processes new posts and updates the wait list.
    /// - Parameter newPosts: The array of new posts retrieved.
    private func processNewPosts(_ newPosts: [[String: Any]]) {
        if !newPosts.isEmpty {
            insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
        } else {
            refresh_request = false
            waitPost.removeAll()
            waitCollectionNode.reloadData()
        }
    }

    /// Updates the wait collection node's view based on the data.
    private func updateWaitCollectionNode() {
        if waitPost.isEmpty {
            waitCollectionNode.view.setEmptyMessage("No stitch found", color: .black)
        } else {
            waitCollectionNode.view.restore()
        }
    }

}

extension ApprovedStitchVC: ASCollectionDelegate {

    // MARK: - Collection Delegate

    /// Returns the size range for an item at the specified index path.
    /// - Parameters:
    ///   - collectionNode: The collection node.
    ///   - indexPath: The index path of the item.
    /// - Returns: The size range for the item.
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        if collectionNode == myCollectionNode {
            return sizeRangeForMyCollectionNode()
        } else {
            return sizeRangeForWaitCollectionNode()
        }
    }

    /// Indicates whether batch fetching should be initiated for the collection node.
    /// - Parameter collectionNode: The collection node.
    /// - Returns: A Boolean value indicating whether batch fetching should occur.
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        if collectionNode == myCollectionNode {
            return true
        } else {
            return allowLoadingWaitList
        }
    }

    // MARK: - Private Helpers

    /// Returns the size range for items in 'My Collection' node.
    /// - Returns: The size range for the items.
    private func sizeRangeForMyCollectionNode() -> ASSizeRange {
        let height = contentView.layer.frame.height
        let width = height * 9 / 13.5
        let size = CGSize(width: width, height: height)
        return ASSizeRangeMake(size, size)
    }

    /// Returns the size range for items in 'Wait Collection' node.
    /// - Returns: The size range for the items.
    private func sizeRangeForWaitCollectionNode() -> ASSizeRange {
        let size = stitchedView.layer.frame.size
        return ASSizeRangeMake(size, size)
    }
}



extension ApprovedStitchVC: ASCollectionDataSource {

    // MARK: - Collection Data Source

    /// Returns the number of sections in the collection node.
    /// - Parameter collectionNode: The collection node.
    /// - Returns: The number of sections.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    /// Returns the number of items in a given section of the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node.
    ///   - section: The index of the section.
    /// - Returns: The number of items in the section.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        switch collectionNode {
        case myCollectionNode:
            return updateEmptyMessageIfNeeded(for: myCollectionNode, withCount: myPost.count, emptyMessage: "No post found")
        case waitCollectionNode:
            return updateEmptyMessageIfNeeded(for: waitCollectionNode, withCount: waitPost.count, emptyMessage: "No stitch found")
        default:
            return 0
        }
    }

    // MARK: - Private Helpers

    /// Updates the empty message for a collection node if needed and returns the item count.
    /// - Parameters:
    ///   - node: The collection node to update.
    ///   - count: The number of items.
    ///   - emptyMessage: The message to display when the count is zero.
    /// - Returns: The count of items.
    private func updateEmptyMessageIfNeeded(for node: ASCollectionNode, withCount count: Int, emptyMessage: String) -> Int {
        if count == 0 {
            node.view.setEmptyMessage(emptyMessage, color: .black)
        } else {
            node.view.restore()
        }
        return count
    }
}

extension ApprovedStitchVC {

    // MARK: - Collection Node Data Source

    /// Provides a block that returns an ASCellNode for the given item at an index path.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting the node.
    ///   - indexPath: The index path of the item.
    /// - Returns: A block that returns an ASCellNode.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        if collectionNode == myCollectionNode {
            return myCollectionNodeCellBlock(forItemAt: indexPath)
        } else {
            return waitCollectionNodeCellBlock(forItemAt: indexPath)
        }
    }

    // MARK: - Private Helpers

    /// Creates a cell block for 'My Collection' node.
    /// - Parameter indexPath: The index path of the item.
    /// - Returns: A block that returns an ASCellNode for 'My Collection' node.
    private func myCollectionNodeCellBlock(forItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.myPost[indexPath.row]
        return {
            let node = StitchControlNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            return node
        }
    }

    /// Creates a cell block for 'Wait Collection' node.
    /// - Parameter indexPath: The index path of the item.
    /// - Returns: A block that returns an ASCellNode for 'Wait Collection' node.
    private func waitCollectionNodeCellBlock(forItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.waitPost[indexPath.row]
        return { [weak self] in
            let node = StitchControlForRemoveNode(with: post, stitchTo: false)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.unstitchBtn = { [weak self] node in
                guard let strongSelf = self, let removeNode = node as? StitchControlForRemoveNode else { return }
                strongSelf.unstitchPost(node: removeNode, post: post)
            }
            return node
        }
    }
}

extension ApprovedStitchVC {

    // MARK: - Batch Fetching Delegate

    /// Called when the collection node begins batch fetching.
    /// - Parameters:
    ///   - collectionNode: The collection node initiating the batch fetch.
    ///   - context: The batch fetching context.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        switch collectionNode {
        case myCollectionNode:
            fetchNextPageForMyCollectionNode(context: context)
        case waitCollectionNode:
            fetchNextPageForWaitCollectionNode(context: context)
        default:
            context.completeBatchFetching(true)
        }
    }

    // MARK: - Private Helpers

    /// Fetches the next page for 'My Collection' node.
    /// - Parameter context: The batch fetching context.
    private func fetchNextPageForMyCollectionNode(context: ASBatchContext) {
        retrieveNextPageForMyPostWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNodeForMyPost(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }

    /// Fetches the next page for 'Wait Collection' node.
    /// - Parameter context: The batch fetching context.
    private func fetchNextPageForWaitCollectionNode(context: ASBatchContext) {
        guard !refresh_request else {
            context.completeBatchFetching(true)
            return
        }

        retrieveNextPageForWaitListWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }
}


extension ApprovedStitchVC {

    // MARK: - Setup Methods

    /// Sets up the collection nodes.
    func setupCollectionNodes() {
        setupMyCollectionNode()
        setupWaitCollectionNode()
        applyStylesToCollectionNodes()
        myCollectionNode.reloadData()
    }

    // MARK: - Private Helpers

    /// Sets up 'My Collection' node.
    private func setupMyCollectionNode() {
        let layout = createFlowLayout(horizontalScroll: true, lineSpacing: 10, interitemSpacing: 10)
        myCollectionNode = ASCollectionNode(collectionViewLayout: layout)
        configureCollectionNode(myCollectionNode, in: contentView)
    }

    /// Sets up 'Wait Collection' node.
    private func setupWaitCollectionNode() {
        let layout = createFlowLayout(horizontalScroll: false, lineSpacing: 0, interitemSpacing: 0)
        waitCollectionNode = ASCollectionNode(collectionViewLayout: layout)
        configureCollectionNode(waitCollectionNode, in: stitchedView)
    }

    /// Creates a flow layout with specified properties.
    /// - Parameters:
    ///   - horizontalScroll: A Boolean indicating if the scroll direction is horizontal.
    ///   - lineSpacing: The minimum line spacing.
    ///   - interitemSpacing: The minimum inter-item spacing.
    /// - Returns: A configured UICollectionViewFlowLayout.
    private func createFlowLayout(horizontalScroll: Bool, lineSpacing: CGFloat, interitemSpacing: CGFloat) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = horizontalScroll ? .horizontal : .vertical
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.minimumInteritemSpacing = interitemSpacing
        return flowLayout
    }

    /// Configures a collection node and adds it to a specified view.
    /// - Parameters:
    ///   - node: The collection node to configure.
    ///   - view: The view in which to add the collection node.
    private func configureCollectionNode(_ node: ASCollectionNode, in view: UIView) {
        node.automaticallyRelayoutOnLayoutMarginsChanges = true
        node.leadingScreensForBatching = 2.0
        node.view.contentInsetAdjustmentBehavior = .never
        node.dataSource = self
        node.delegate = self

        addCollectionNodeView(node.view, to: view)
    }

    /// Adds the collection node's view to a specified view and sets constraints.
    /// - Parameters:
    ///   - nodeView: The view of the collection node.
    ///   - parentView: The parent view to which the node view is added.
    private func addCollectionNodeView(_ nodeView: UIView, to parentView: UIView) {
        parentView.addSubview(nodeView)
        nodeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nodeView.topAnchor.constraint(equalTo: parentView.topAnchor),
            nodeView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            nodeView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            nodeView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    /// Applies styles to the collection nodes.
    private func applyStylesToCollectionNodes() {
        styleCollectionNode(myCollectionNode, pagingEnabled: false)
        styleCollectionNode(waitCollectionNode, pagingEnabled: true)
    }

    /// Styles a collection node.
    /// - Parameters:
    ///   - node: The collection node to style.
    ///   - pagingEnabled: A Boolean indicating if paging should be enabled.
    private func styleCollectionNode(_ node: ASCollectionNode, pagingEnabled: Bool) {
        node.view.isPagingEnabled = pagingEnabled
        node.view.backgroundColor = .clear
        node.view.showsVerticalScrollIndicator = false
        node.view.allowsSelection = true
        node.view.contentInsetAdjustmentBehavior = .never
    }
}

extension ApprovedStitchVC {

    // MARK: - Collection Node Delegate

    /// Called when an item in the collection node is selected.
    /// - Parameters:
    ///   - collectionNode: The collection node where selection occurred.
    ///   - indexPath: The index path of the selected item.
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode else { return }

        rootPost = myPost[indexPath.row]
        if shouldReloadWaitList(for: indexPath) {
            configureSelectedCell(at: indexPath)
            resetWaitListAndReloadData()
        }
    }

    /// Called when an item in the collection node is deselected.
    /// - Parameters:
    ///   - collectionNode: The collection node where deselection occurred.
    ///   - indexPath: The index path of the deselected item.
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        guard collectionNode == myCollectionNode, let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode else { return }

        cell.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Private Helpers

    /// Determines if the wait list should be reloaded for a given index path.
    /// - Parameter indexPath: The index path to check.
    /// - Returns: A Boolean value indicating if the wait list should be reloaded.
    private func shouldReloadWaitList(for indexPath: IndexPath) -> Bool {
        if prevIndexPath == nil || prevIndexPath != indexPath {
            prevIndexPath = indexPath
            allowLoadingWaitList = true
            myCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            return true
        }
        return false
    }

    /// Configures the appearance of the selected cell.
    /// - Parameter indexPath: The index path of the selected cell.
    private func configureSelectedCell(at indexPath: IndexPath) {
        guard let cell = myCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode else { return }

        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.secondary.cgColor
    }

    /// Resets the wait list and reloads the collection node data.
    private func resetWaitListAndReloadData() {
        if !waitPost.isEmpty {
            waitPost.removeAll()
            waitPage = 1
            firstWaitReload = true
            waitCollectionNode.performBatchUpdates({
                waitCollectionNode.reloadData()
            }, completion: nil)
        } else {
            waitCollectionNode.reloadData()
        }
    }
}



extension ApprovedStitchVC {

    // MARK: - Data Retrieval

    /// Retrieves the next page of 'My Post' with a completion block.
    /// - Parameter block: A completion block that receives an array of dictionaries representing posts.
    func retrieveNextPageForMyPostWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getMyPostHasStitched(page: myPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                self.handleSuccessResponseForMyPost(apiResponse, completion: block)
            case .failure(let error):
                print("Error retrieving My Posts: \(error)")
                self.invokeCompletionBlockWithEmptyData(block)
            }
        }
    }

    // MARK: - Private Helpers

    /// Handles the success response for 'My Post' from the API call.
    /// - Parameters:
    ///   - apiResponse: The successful response from the API.
    ///   - completion: The completion block to invoke with the retrieved data.
    private func handleSuccessResponseForMyPost(_ apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            print("No data received or data is empty for My Posts")
            invokeCompletionBlockWithEmptyData(completion)
            return
        }
        
        print("Successfully retrieved \(data.count) My Posts.")
        myPage += 1
        DispatchQueue.main.async {
            completion(data)
        }
    }

    /// Invokes the completion block with empty data.
    /// - Parameter completion: The completion block to invoke.
    private func invokeCompletionBlockWithEmptyData(_ completion: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            completion([])
        }
    }
}


extension ApprovedStitchVC {

    // MARK: - Data Retrieval

    /// Retrieves the next page of posts for the wait list and returns them through a completion block.
    /// - Parameter block: A completion block that receives an array of dictionaries representing posts.
    func retrieveNextPageForWaitListWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getStitchPost(rootId: rootPost.id, page: waitPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                self.handleSuccessResponse(apiResponse, completion: block)
            case .failure(let error):
                print("Error retrieving posts: \(error)")
                self.invokeCompletionBlockWithEmptyData(block)
            }
        }
    }

    // MARK: - Private Helpers

    /// Handles the success response from the API call.
    /// - Parameters:
    ///   - apiResponse: The successful response from the API.
    ///   - completion: The completion block to invoke with the retrieved data.
    private func handleSuccessResponse(_ apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            print("No data received or data is empty")
            invokeCompletionBlockWithEmptyData(completion)
            return
        }
        
        print("Successfully retrieved \(data.count) posts.")
        waitPage += 1
        DispatchQueue.main.async {
            completion(data)
        }
    }

}


extension ApprovedStitchVC {

    // MARK: - Collection Node Update

    /// Inserts new rows in the collection node for 'My Post'.
    /// - Parameter newPosts: An array of new posts represented as dictionaries.
    func insertNewRowsInCollectionNodeForMyPost(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        resetMyPostListIfRefreshRequested()
        let newItems = createAndFilterPostModelsForMyPost(from: newPosts)
        insertNewItemsInMyCollectionNode(newItems)
        setInitialAppearanceForFirstLoad()
    }

    // MARK: - Private Helpers

    /// Resets the 'My Post' list if a refresh is requested.
    private func resetMyPostListIfRefreshRequested() {
        guard refresh_request else { return }

        refresh_request = false
        let deleteIndexPaths = (0..<self.myPost.count).map { IndexPath(row: $0, section: 0) }
        self.myPost.removeAll()
        self.myCollectionNode.deleteItems(at: deleteIndexPaths)
    }

    /// Creates and filters PostModel objects for 'My Post' from dictionaries.
    /// - Parameter newPosts: An array of new posts represented as dictionaries.
    /// - Returns: An array of PostModel objects.
    private func createAndFilterPostModelsForMyPost(from newPosts: [[String: Any]]) -> [PostModel] {
        return newPosts.compactMap { dict -> PostModel? in
            guard let item = PostModel(JSON: dict), !myPost.contains(item) else { return nil }
            myPost.append(item)
            return item
        }
    }

    /// Inserts new items in the 'My Post' collection node.
    /// - Parameter items: An array of new PostModel objects to insert.
    private func insertNewItemsInMyCollectionNode(_ items: [PostModel]) {
        guard !items.isEmpty else { return }

        let startIndex = self.myPost.count - items.count
        let endIndex = startIndex + items.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        self.myCollectionNode.insertItems(at: indexPaths)
    }

    /// Sets the initial appearance and selection for the first load.
    private func setInitialAppearanceForFirstLoad() {
        guard firstLoad, !myPost.isEmpty else { return }

        firstLoad = false
        configureFirstCellAppearance()
        rootPost = myPost[0]
        allowLoadingWaitList = true
        waitCollectionNode.reloadData()
    }

    /// Configures the appearance of the first cell in the 'My Post' collection node.
    private func configureFirstCellAppearance() {
        guard let cell = myCollectionNode.nodeForItem(at: IndexPath(item: 0, section: 0)) as? StitchControlNode else {
            print("Couldn't cast cell to StitchControlNode")
            return
        }

        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.secondary.cgColor
        cell.isSelected = true

        myCollectionNode.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
        myCollectionNode.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
    }
}


extension ApprovedStitchVC {

    // MARK: - Collection Node Update

    /// Inserts new rows in the collection node for the wait list.
    /// - Parameter newPosts: An array of new posts represented as dictionaries.
    func insertNewRowsInCollectionNodeForWaitList(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        resetWaitListIfRefreshRequested()
        let newItems = createAndFilterPostModels(from: newPosts)
        insertNewItemsInWaitCollectionNode(newItems)
        setInitialCurrentIndexIfNeeded()
    }

    // MARK: - Private Helpers

    /// Resets the wait list if a refresh is requested.
    private func resetWaitListIfRefreshRequested() {
        guard refresh_request else { return }
        refresh_request = false
        waitPost.removeAll()
        waitCollectionNode.reloadData()
    }

    /// Creates and filters PostModel objects from dictionaries.
    /// - Parameter newPosts: An array of new posts represented as dictionaries.
    /// - Returns: An array of PostModel objects.
    private func createAndFilterPostModels(from newPosts: [[String: Any]]) -> [PostModel] {
        return newPosts.compactMap { dict -> PostModel? in
            guard let item = PostModel(JSON: dict), !waitPost.contains(item) else { return nil }
            waitPost.append(item)
            return item
        }
    }

    /// Inserts new items in the wait collection node.
    /// - Parameter items: An array of new PostModel objects to insert.
    private func insertNewItemsInWaitCollectionNode(_ items: [PostModel]) {
        guard !items.isEmpty else { return }

        let startIndex = waitPost.count - items.count
        let endIndex = startIndex + items.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        waitCollectionNode.insertItems(at: indexPaths)
    }

    /// Sets the initial current index for the wait list if needed.
    private func setInitialCurrentIndexIfNeeded() {
        if firstWaitReload, !waitPost.isEmpty {
            firstWaitReload = false
            currentIndex = 0
        }
    }
}


extension ApprovedStitchVC {

    // MARK: - ScrollView Delegate

    /// Called when the scroll view has scrolled.
    /// - Parameter scrollView: The scroll view that scrolled.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !waitPost.isEmpty, scrollView == waitCollectionNode.view, isHorizontalScroll(scrollView) else {
            return
        }
        
        let visibleRect = calculateVisibleRect(in: scrollView)
        let visibleCells = calculateVisibleCells()
        let newVisibleIndex = findClosestVisibleVideoIndex(from: visibleCells, in: visibleRect)

        if let newVisibleIndex = newVisibleIndex, newVisibleIndex < waitPost.count {
            handleVideoPlaybackChange(for: newVisibleIndex)
        } else {
            pauseCurrentVideoIfNeeded()
        }
    }

    // MARK: - Video Playback

    /// Pauses the video at the specified index.
    /// - Parameter index: The index of the video to pause.
    func pauseVideo(atIndex: Int) {
        if let cell = waitCollectionNode.nodeForItem(at: IndexPath(row: atIndex, section: 0)) as? StitchControlForRemoveNode {
            cell.pauseVideo()
        }
    }

    /// Plays the video at the specified index.
    /// - Parameter index: The index of the video to play.
    func playVideo(atIndex: Int) {
        if let cell = waitCollectionNode.nodeForItem(at: IndexPath(row: atIndex, section: 0)) as? StitchControlForRemoveNode {
            cell.playVideo()
        }
    }

    // MARK: - Private Helpers

    /// Determines if the scroll view scroll was horizontal.
    /// - Parameter scrollView: The scroll view to check.
    /// - Returns: Boolean indicating if the scroll was horizontal.
    private func isHorizontalScroll(_ scrollView: UIScrollView) -> Bool {
        if lastContentOffset != scrollView.contentOffset.x {
            lastContentOffset = scrollView.contentOffset.x
            return true
        }
        return false
    }

    /// Calculates the visible rectangle of the scroll view.
    /// - Parameter scrollView: The scroll view.
    /// - Returns: The visible rectangle.
    private func calculateVisibleRect(in scrollView: UIScrollView) -> CGRect {
        return CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
    }

    /// Calculates the visible cells in the collection node.
    /// - Returns: An array of visible cells.
    private func calculateVisibleCells() -> [StitchControlForRemoveNode] {
        return waitCollectionNode.visibleNodes.compactMap { $0 as? StitchControlForRemoveNode }
    }

    /// Finds the index of the closest visible video to the center of the visible area.
    /// - Parameters:
    ///   - cells: The visible cells.
    ///   - visibleRect: The visible rectangle.
    /// - Returns: The index of the closest video, if any.
    private func findClosestVisibleVideoIndex(from cells: [StitchControlForRemoveNode], in visibleRect: CGRect) -> Int? {
        var minDistanceFromCenter = CGFloat.infinity
        var closestIndex: Int?

        for cell in cells {
            let distanceFromCenter = distanceFromCenterOf(visibleRect, for: cell)
            if distanceFromCenter < minDistanceFromCenter {
                closestIndex = cell.indexPath?.row
                minDistanceFromCenter = distanceFromCenter
            }
        }

        return closestIndex
    }

    /// Calculates the distance of a cell from the center of a given rectangle.
    /// - Parameters:
    ///   - rect: The rectangle.
    ///   - cell: The cell.
    /// - Returns: The distance from the center.
    private func distanceFromCenterOf(_ rect: CGRect, for cell: StitchControlForRemoveNode) -> CGFloat {
        let cellRect = cell.view.convert(cell.bounds, to: waitCollectionNode.view)
        let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
        return abs(cellCenter.x - rect.midX) // Horizontal scroll distance
    }

    /// Handles the logic for changing video playback based on the new visible index.
    /// - Parameter newIndex: The new index of the visible video.
    private func handleVideoPlaybackChange(for newIndex: Int) {
        let muxPlaybackId = waitPost[newIndex].muxPlaybackId
        let isVideo = !muxPlaybackId.isEmpty

        if isVideo, currentIndex != newIndex {
            pauseCurrentVideoIfNeeded()
            currentIndex = newIndex
            playVideo(atIndex: newIndex)
            isVideoPlaying = true
        }
    }

    /// Pauses the current playing video if needed.
    private func pauseCurrentVideoIfNeeded() {
        guard let currentIndex = currentIndex, !isVideoPlaying else { return }
        pauseVideo(atIndex: currentIndex)
        self.currentIndex = nil
    }
}


extension ApprovedStitchVC {

    // MARK: - Public Methods

    /// Unstitches a post from a stitched thread.
    /// - Parameters:
    ///   - node: The StitchControlForRemoveNode instance.
    ///   - post: The post model to be unstitched.
    func unstitchPost(node: StitchControlForRemoveNode, post: PostModel) {
        guard let rootPostId = rootPost?.id else {
            showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again")
            return
        }

        presentSwiftLoader()
        performUnstitchOperation(rootId: rootPostId, memberId: post.id, post: post)
    }

    // MARK: - Private Helpers

    /// Performs the unstitch operation and handles the response.
    /// - Parameters:
    ///   - rootId: The ID of the root post.
    ///   - memberId: The ID of the member post to be unstitched.
    private func performUnstitchOperation(rootId: String, memberId: String, post: PostModel) {
        APIManager.shared.unstitch(rootId: rootId, memberId: memberId) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.handleUnstitchResult(result, forPostWithId: memberId, post: post)
            }
        }
    }

    /// Handles the result of an unstitch operation.
    /// - Parameters:
    ///   - result: The result of the unstitch operation.
    ///   - postId: The ID of the post involved in the unstitch operation.
    private func handleUnstitchResult(_ result: Result, forPostWithId postId: String, post: PostModel) {
        SwiftLoader.hide()

        switch result {
        case .success:
            updateUIAfterSuccessfulUnstitch(forPostWithId: postId, post: post)
        case .failure(let error):
            showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again. \(error.localizedDescription)")
        }
    }

    /// Updates the UI after a successful unstitch operation.
    /// - Parameter postId: The ID of the post that was unstitched.
    private func updateUIAfterSuccessfulUnstitch(forPostWithId postId: String, post: PostModel) {
        if let indexPath = waitPost.firstIndex(of: post) {
            waitPost.removeObject(post)
            waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            handleVideoPlaybackPostUnstitch(at: indexPath)
        }
    }

    /// Handles video playback logic after an unstitch operation.
    /// - Parameter indexPath: The index path of the unstitched post.
    private func handleVideoPlaybackPostUnstitch(at indexPath: Int) {
        if indexPath < waitPost.count {
            playVideo(atIndex: indexPath)
        } else if waitPost.count == 1 {
            playVideo(atIndex: 0)
        }
    }
}

extension ApprovedStitchVC {

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
