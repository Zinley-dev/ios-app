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

fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class RootNode: ASCellNode, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    var rootPost: PostModel!
    var posts = [PostModel]()
    var page = 1
    var galleryCollectionNode: ASCollectionNode!
    var mainCollectionNode: ASCollectionNode!
    var saveMin = CGSize(width: 0, height: 0)
    var saveMax = CGSize(width: 0, height: 0)
    
    init(with post: PostModel) {
        self.rootPost = post
        
        // Configure mainCollectionNode with a horizontal flow layout and no spacing between items
        let mainFlowLayout = UICollectionViewFlowLayout()
        mainFlowLayout.minimumLineSpacing = 0.0
        mainFlowLayout.scrollDirection = .horizontal
        mainCollectionNode = ASCollectionNode(collectionViewLayout: mainFlowLayout)
        
        // Configure galleryCollectionNode with a horizontal flow layout and spacing between items
        let galleryFlowLayout = UICollectionViewFlowLayout()
        galleryFlowLayout.scrollDirection = .horizontal
        galleryFlowLayout.minimumLineSpacing = 12
        galleryFlowLayout.minimumInteritemSpacing = 12
        galleryCollectionNode = ASCollectionNode(collectionViewLayout: galleryFlowLayout)
        
        super.init()
        
        // Add the post to the posts array if it's not already included
        if !posts.contains(post) {
            posts.append(post)
        }
        
        // Set the delegate and data source for mainCollectionNode
        self.mainCollectionNode.delegate = self
        self.mainCollectionNode.dataSource = self
    }

    
    // Called when the node has loaded
    override func didLoad() {
        super.didLoad()
        
        // Apply styling to the node
        self.applyStyle()
    }

    // Defines the layout specification for the node
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // Define insets for the layout
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Apply the insets to the mainCollectionNode
        return ASInsetLayoutSpec(insets: insets, child: mainCollectionNode)
    }

    
    
}

extension RootNode {
    
    func applyStyle() {
        
        // Set the background color for the main collection node and its view
        self.mainCollectionNode.backgroundColor = .black
        self.mainCollectionNode.view.backgroundColor = .black

        // Control layout changes and preloading behavior for smoother scrolling
        self.mainCollectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.mainCollectionNode.leadingScreensForBatching = 2.0

        // Enable paging for horizontal scrolling and disable vertical scroll indicators
        self.mainCollectionNode.view.isPagingEnabled = true
        self.mainCollectionNode.view.showsVerticalScrollIndicator = false

        // Ensure the layout does not adjust for safe area insets
        self.mainCollectionNode.view.contentInsetAdjustmentBehavior = .never

        // Redraw layout when bounds change, useful for dynamic content
        self.mainCollectionNode.needsDisplayOnBoundsChange = true

        // Set the background color of the view and the style of the scroll indicator
        self.backgroundColor = .black
        self.mainCollectionNode.view.indicatorStyle = .white
    }


}


extension RootNode: ASCollectionDelegate, ASCollectionDataSource {
    
    
    // Return the number of sections in the collection node
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    // Return the number of items in a given section of the collection node
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    // Provide a node block for each item in the collection node
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]

        // Check which collection node is being referenced to determine the node type
        if collectionNode == galleryCollectionNode {
            
            return {
                // Create and configure a StitchControlNode for the gallery collection node
                let node = StitchControlNode(with: post)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                node.automaticallyManagesSubnodes = true
                return node
            }
            
        } else {
            
            return { [weak self] in
                guard self != nil else {
                    // Return an empty ASCellNode if self is nil
                    return ASCellNode()
                }
                
                // Create and configure a VideoNode for the main collection node
                let node = VideoNode(with: post, isPreview: false)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                node.automaticallyManagesSubnodes = true
                return node
            }
        }
    }

}


extension RootNode {

    // Define the size of items in the collection node
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {

        if collectionNode == galleryCollectionNode {
            // Calculate size for galleryCollectionNode items
            let height = UIScreen.main.bounds.height * 1 / 4 - 70
            let width = height * 9 / 13.5
            let size = CGSize(width: width, height: height)
            return ASSizeRangeMake(size, size)
        } else {
            // Calculate size for mainCollectionNode items
            let min = CGSize(width: self.mainCollectionNode.layer.frame.width, height: 50)
            let max = CGSize(width: self.mainCollectionNode.layer.frame.width, height: mainCollectionNode.frame.height)
           
            // Store the minimum and maximum sizes if the collection node has a valid frame
            if collectionNode.frame.width != 0.0 && collectionNode.frame.height != 0.0 {
                return ASSizeRangeMake(min, max)
            } else {
                // Use saved minimum and maximum sizes if the frame is not valid
                return ASSizeRangeMake(saveMin, saveMax)
            }
        }
    }

    // Determine if batch fetching should be performed for the collection node
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return collectionNode != galleryCollectionNode
    }
}


extension RootNode {

    // Retrieve the next page of data
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getSuggestStitch(rootId: rootPost.id, page: page) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let apiResponse):
                // Handle successful response
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    DispatchQueue.main.async { block([]) }
                    return
                }
                print("Successfully retrieved \(data.count) posts.")
                DispatchQueue.main.async { block(data) }
            case .failure(let error):
                // Handle failure
                print(error)
                DispatchQueue.main.async { block([]) }
            }
        }
    }

    // Insert new rows into the collection node
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }
        
        // Convert data to PostModel objects and append them to posts
        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !posts.contains($0) }
        posts.append(contentsOf: items)

        // Insert new items into collection nodes
        if !items.isEmpty {
            let startIndex = posts.count - items.count
            let indexPaths = (startIndex..<(startIndex + items.count)).map { IndexPath(row: $0, section: 0) }
            self.mainCollectionNode.insertItems(at: indexPaths)
            self.galleryCollectionNode.insertItems(at: indexPaths)
        }
    }
    
    
}


extension RootNode {

    // Handle batch fetching for the collection node
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            
            // Check the current view controller before updating collection nodes
            if let vc = UIViewController.currentViewController(), vc is FeedViewController {
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                context.completeBatchFetching(true)
            } else {
                context.completeBatchFetching(true)
            }
        }
    }
}

