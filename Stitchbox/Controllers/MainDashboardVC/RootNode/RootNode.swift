//
//  RootNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 11/15/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit
import AnimatedCollectionViewLayout

fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class RootNode: ASCellNode, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    // MARK: - Properties

    var rootPost: PostModel! // The main post object for the view controller.
    var posts = [PostModel]() // Array to hold related posts.
    var page = 1 // Current page index for pagination or similar use.
    
    // UI elements
    var galleryCollectionNode: ASCollectionNode! // Collection node for displaying a gallery of items.
    var mainCollectionNode: ASCollectionNode! // Main collection node for primary content display.

    // Size properties
    var saveMin = CGSize(width: 0, height: 0) // Minimum size for some UI or layout purpose (context not clear from snippet).
    var saveMax = CGSize(width: 0, height: 0) // Maximum size for the same purpose as saveMin.

    // Data and State Management
    var currentIndex: Int? = 0
    var newPlayingIndex: Int? = 0
    var isVideoPlaying = false
    var isDraggingEnded: Bool = false
    var isfirstLoad = true
    var firstItem = false
    
    // MARK: - Initializer

    /// Initializes the view controller with a given post.
    /// This initializer sets up collection nodes and various properties required for the view controller.
    /// - Parameter post: The main post model around which this view controller is based.
    init(with post: PostModel, firstItem: Bool) {
        self.firstItem = firstItem
        // Assigning the passed post to rootPost, which acts as the primary data model for this controller.
        self.rootPost = post

        // Setting up the main collection node with a custom layout for page-like navigation.
        let layout = AnimatedCollectionViewLayout()
        layout.animator = PageAttributesAnimator() // Using a custom animator for page transitions.
        layout.minimumLineSpacing = 0.0           // Setting the spacing between lines to zero for a continuous layout.
        layout.scrollDirection = .horizontal      // Setting the scroll direction to horizontal.

        // Initializing mainCollectionNode with the custom layout.
        mainCollectionNode = ASCollectionNode(collectionViewLayout: layout)

        // Setting up galleryCollectionNode with a standard flow layout.
        let galleryFlowLayout = UICollectionViewFlowLayout()
        galleryFlowLayout.scrollDirection = .horizontal       // Horizontal scrolling for a gallery-like layout.
        galleryFlowLayout.minimumLineSpacing = 12             // Spacing between lines.
        galleryFlowLayout.minimumInteritemSpacing = 12        // Spacing between items.
        galleryCollectionNode = ASCollectionNode(collectionViewLayout: galleryFlowLayout)

        // Calling the superclass initializer.
        super.init()

        // Adding the root post to the posts array if it's not already present.
        if !posts.contains(post) {
            posts.append(post)
        }

        // Setting up delegates for the main collection node.
        // These delegates will handle events like cell selection, data provision, etc.
        self.mainCollectionNode.delegate = self
        self.mainCollectionNode.dataSource = self
    }
    
}

// MARK: - Lifecycle and Layout

extension RootNode {

    /// Called when the node has finished loading.
    /// This method is a good place to perform any additional setup that requires the node to be fully loaded.
    override func didLoad() {
        super.didLoad() // Always call the super implementation in lifecycle methods.

        // Applying styling configurations to the node.
        // This includes setting up visual aspects and layout behaviors.
        self.applyStyle()
    }

    /// Defines the layout specification for the node.
    /// This method calculates and provides a layout spec that ASCollectionNode will use.
    /// - Parameter constrainedSize: The size range within which the node must layout itself.
    /// - Returns: An ASLayoutSpec that describes the layout of the node.
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // Defining insets for the layout.
        // Insets can be adjusted to control the padding around the main collection node.
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Applying the insets to the mainCollectionNode.
        // ASInsetLayoutSpec wraps the mainCollectionNode with the defined insets.
        return ASInsetLayoutSpec(insets: insets, child: mainCollectionNode)
    }
}


// MARK: - Styling

extension RootNode {

    /// Applies styling and layout configurations to the node and its components.
    /// This function sets various visual and layout properties to enhance the user interface.
    func applyStyle() {
        // Setting the background color for the main collection node.
        // Both the node and its underlying view are given the same background color for consistency.
        self.mainCollectionNode.backgroundColor = .black
        self.mainCollectionNode.view.backgroundColor = .black

        // Controlling layout changes and preloading behavior.
        // This helps in optimizing performance and achieving smoother scrolling.
        self.mainCollectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.mainCollectionNode.leadingScreensForBatching = 2.0 // Number of screens to preload for better user experience.

        // Enabling paging for horizontal scrolling and disabling vertical scroll indicators.
        // Paging will snap the scrolling to each page of content.
        self.mainCollectionNode.view.isPagingEnabled = true
        self.mainCollectionNode.view.showsVerticalScrollIndicator = false

        // Setting the content inset adjustment behavior.
        // This ensures that the layout does not automatically adjust for safe area insets.
        self.mainCollectionNode.view.contentInsetAdjustmentBehavior = .never

        // Redrawing the layout when the bounds of the node change.
        // This is particularly useful for dynamic content where the size or layout might change.
        self.mainCollectionNode.needsDisplayOnBoundsChange = true

        // Setting the overall background color of the node and the scroll indicator style.
        // These visual properties enhance the user interface.
        self.backgroundColor = .black
        self.mainCollectionNode.view.showsVerticalScrollIndicator = false
        self.mainCollectionNode.view.showsHorizontalScrollIndicator = false

    }
}



// MARK: - ASCollectionDelegate & ASCollectionDataSource

extension RootNode: ASCollectionDelegate, ASCollectionDataSource {
    
    /// Returns the number of sections in the collection node.
    /// - Parameter collectionNode: The collection node in question.
    /// - Returns: The number of sections.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1 // This implementation supports only one section in the collection.
    }

    /// Returns the number of items in a given section of the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node in question.
    ///   - section: The section for which to return the number of items.
    /// - Returns: The number of items in the section.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count // The number of items is equal to the number of posts.
    }

    // MARK: - ASCollectionDataSource

    /// Provides a node block for each item in the collection node.
    /// Decides which type of node (e.g., VideoNode, StitchControlNode) to use based on the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting the node.
    ///   - indexPath: The index path of the item.
    /// - Returns: A block that creates and returns an `ASCellNode`.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]

        // Determine the type of collection node to handle.
        if collectionNode == galleryCollectionNode {
            // Handling gallery collection node.
            return {
                let node = StitchControlNode(with: post)
                self.configureNode(node, at: indexPath)
                return node
            }
        } else {
            // Handling main collection node.
            return { [weak self] in
                guard let strongSelf = self else { return ASCellNode() }
                let node = VideoNode(with: post, isPreview: false, firstItem: strongSelf.firstItem)
                strongSelf.configureNode(node, at: indexPath)

                if strongSelf.firstItem {
                    strongSelf.firstItem = false
                }

                return node
            }
        }
    }

    /// Configures properties of a cell node.
    /// - Parameters:
    ///   - node: The `ASCellNode` to configure.
    ///   - indexPath: The index path of the node.
    private func configureNode(_ node: ASCellNode, at indexPath: IndexPath) {
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        node.automaticallyManagesSubnodes = true
    }

}

extension RootNode {

    /// Defines the size of items in the collection node.
    /// This method calculates size differently for gallery and main collection nodes.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting the size.
    ///   - indexPath: The index path of the item.
    /// - Returns: A size range that the node should adhere to.
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        if collectionNode == galleryCollectionNode {
            // Size calculation for galleryCollectionNode items.
            let height = UIScreen.main.bounds.height * 1 / 4 - 70
            let width = height * 9 / 13.5
            let size = CGSize(width: width, height: height)
            return ASSizeRangeMake(size, size)
        } else {
            // Size calculation for mainCollectionNode items.
            let min = CGSize(width: mainCollectionNode.layer.frame.width, height: 50)
            let max = CGSize(width: mainCollectionNode.layer.frame.width, height: mainCollectionNode.frame.height)
            return collectionNode.frame.width != 0.0 && collectionNode.frame.height != 0.0 ? ASSizeRangeMake(min, max) : ASSizeRangeMake(saveMin, saveMax)
        }
    }

    /// Determines if batch fetching should be performed for the collection node.
    /// This method restricts batch fetching to certain collection nodes.
    /// - Parameter collectionNode: The collection node in question.
    /// - Returns: Boolean indicating whether batch fetching should be performed.
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return collectionNode != galleryCollectionNode // Enabling batch fetching only for the main collection node.
    }
}


// MARK: - Data Retrieval and Management

extension RootNode {
    
    /// Retrieves the next page of data from the API.
    /// The completion block returns an array of dictionaries representing new data.
    /// - Parameter block: A completion block that is executed when the data retrieval is complete.
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getSuggestStitch(rootId: rootPost.id, page: page) { [weak self] result in
            guard let _ = self else { return } // Ensuring the instance is still around when the API call completes.

            switch result {
            case .success(let apiResponse):
                // Handling successful API response.
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    DispatchQueue.main.async { block([]) }
                    return
                }
                print("Successfully retrieved \(data.count) posts.")
                DispatchQueue.main.async { block(data) }

            case .failure(let error):
                // Handling failure in API response.
                print(error)
                DispatchQueue.main.async { block([]) }
            }
        }
    }

    /// Inserts new rows into the collection node using the data received.
    /// - Parameter newPosts: An array of dictionaries representing the new posts to be added.
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }
        
        // Converting raw data to PostModel objects and appending them to the posts array.
        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !posts.contains($0) }
        posts.append(contentsOf: items)

        // Inserting new items into the collection nodes.
        if !items.isEmpty {
            let startIndex = posts.count - items.count
            let indexPaths = (startIndex..<(startIndex + items.count)).map { IndexPath(row: $0, section: 0) }
            mainCollectionNode.insertItems(at: indexPaths)
            galleryCollectionNode.insertItems(at: indexPaths)
        }
    }
}

// MARK: - ASCollectionNode Delegate Methods

extension RootNode {

    /// Handles batch fetching for the collection node.
    /// This method is triggered when the collection node is ready to fetch more data.
    /// - Parameters:
    ///   - collectionNode: The collection node requiring more data.
    ///   - context: The batch fetching context.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            
            // Updating collection nodes only if the current view controller is of a specific type.
            if let vc = UIViewController.currentViewController(), vc is FeedViewController {
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                context.completeBatchFetching(true)
            } else {
                context.completeBatchFetching(true)
            }
        }
    }
}


// MARK: - Video Playback Control Extension

// This extension provides methods to control video playback within the FeedViewController, including pausing and playing videos.

extension RootNode {
    
    // Pauses the video at a specific index and optionally seeks to the start.
    func pauseVideoOnScrolling(index: Int) {
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.pauseVideo(shouldSeekToStart: true)
        }
    }
    
    // Pauses the video at a specific index without seeking to the start.
    func pauseVideoOnAppStage(index: Int) {
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.pauseVideo(shouldSeekToStart: false)
        }
    }

    // Plays the video at a specified index and updates the root ID for notification.
    func playVideo(index: Int) {
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.isActive = true
            cell.playVideo()
        }
    }
    
    // Seeks the video at a specific index to the beginning (time zero).
    func seekToZero(index: Int) {
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            cell.seekToZero()
        }
    }
}

extension RootNode {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !posts.isEmpty, scrollView == mainCollectionNode.view {
            
            // Define the page width and calculate the new target offset
            let pageWidth: CGFloat = scrollView.bounds.width
            let currentOffset: CGFloat = scrollView.contentOffset.x
            let targetOffset: CGFloat = targetContentOffset.pointee.x
            var newTargetOffset: CGFloat = targetOffset > currentOffset ?
                ceil(currentOffset / pageWidth) * pageWidth :
                floor(currentOffset / pageWidth) * pageWidth

            // Bounds checking for the new target offset
            newTargetOffset = max(min(newTargetOffset, scrollView.contentSize.width - pageWidth), 0)

            // Adjust the target content offset
            targetContentOffset.pointee.x = newTargetOffset
            
            // Set the flag to indicate dragging has ended
            isDraggingEnded = true
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !posts.isEmpty, scrollView == mainCollectionNode.view {
            
            if isDraggingEnded {
                // Skip scrollViewDidScroll logic if we have just ended dragging
                isDraggingEnded = false
                return
            }

            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)

            // Calculate the visible cells.
            let visibleCells = mainCollectionNode.visibleNodes.compactMap { $0 as? VideoNode }

            // Find the index of the visible video that is closest to the center of the screen horizontally.
            var minDistanceFromCenter = CGFloat.infinity
            var foundVisibleVideo = false
            var newPlayingIndex: Int?

            for cell in visibleCells {
                if let indexPath = cell.indexPath {
                    let cellRect = cell.view.convert(cell.bounds, to: mainCollectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.x - visibleRect.midX)
                    
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
                        pauseVideoOnScrolling(index: currentIndex)
                    }
                    // Play the new video.
                    currentIndex = newPlayingIndex
                    playVideo(index: currentIndex!)
                    isVideoPlaying = true
                    
                    if let node = mainCollectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? VideoNode {
                        resetView(cell: node)
                    }
                }
            }

        }
    }

    
    
}
