//
//  StitchGalleryNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/7/23.
//
import Foundation
import UIKit
import AsyncDisplayKit

fileprivate let FontSize: CGFloat = 13

class StitchGalleryNode: ASCellNode {
    
    /// Deinitializer for the StitchGalleryNode.
    deinit {
        print("StitchGalleryNode is being deallocated.")
    }

    // Properties
    var post: PostModel!
    private var imageNode: ASNetworkImageNode!
    private var infoNode: ASTextNode!
    private var videoSignNode: ASImageNode!
    private var stitchSignNode: ASImageNode!
    private var countNode: ASTextNode!
    private var stitchCountNode: ASTextNode!
    private var didSetup = false

    /// Initializes a StitchGalleryNode with a given post.
    /// - Parameter post: The `PostModel` instance used to configure the node.
    init(with post: PostModel) {
        // Assigning the passed post model to the post property.
        self.post = post

        // Initializing various nodes.
        self.imageNode = ASNetworkImageNode()
        self.stitchCountNode = ASTextNode()
        self.countNode = ASTextNode()
        self.infoNode = ASTextNode()
        self.videoSignNode = ASImageNode()
        self.stitchSignNode = ASImageNode()

        // Calling the superclass initializer.
        super.init()

        // Configuring the nodes to be layer backed for improved performance.
        countNode.isLayerBacked = true
        stitchSignNode.isLayerBacked = true
        videoSignNode.isLayerBacked = true
        infoNode.isLayerBacked = true
        imageNode.isLayerBacked = true

        // Setting the URL for the imageNode to load the image from the post's imageUrl.
        imageNode.url = post.imageUrl
    }

    
    /// Called when the node becomes visible on the screen.
    override func didEnterVisibleState() {
        // Check if the setup has already been completed
        if !didSetup {
            // If not, perform the setup
            setupLayout()
        }
    }

    
    /// Configures the layout and appearance of the node.
    func setupLayout() {
        // Marking that setup is complete to prevent redundant calls
        didSetup = true

        // Set the background of the node to be clear
        self.backgroundColor = .clear
        // Also set the imageNode's background to clear
        self.imageNode.backgroundColor = .clear

        // Configure the imageNode
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // Rounded corners for the imageNode

        // Set up various subnodes
        setupnode()        // Setup for additional nodes
        setupUsername()    // Setup for username display
        setupStitchCount() // Setup for displaying stitch count
        setupViewCount()   // Setup for displaying view count
    }

    /// Configures the properties of various nodes used in the view.
    func setupnode() {
        // Configure stitchSignNode
        stitchSignNode.image = UIImage(named: "partner white")
        stitchSignNode.contentMode = .scaleAspectFill
        stitchSignNode.style.preferredSize = CGSize(width: 15, height: 15) // Set the size
        stitchSignNode.clipsToBounds = true

        // Add shadow to stitchSignNode
        stitchSignNode.shadowColor = UIColor.black.cgColor
        stitchSignNode.shadowOpacity = 0.5
        stitchSignNode.shadowOffset = CGSize(width: 0, height: 2)
        stitchSignNode.shadowRadius = 2

        // Configure stitchCountNode
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        stitchCountNode.maximumNumberOfLines = 1

        // Configure videoSignNode
        videoSignNode.image = UIImage(named: "play")
        videoSignNode.contentMode = .scaleAspectFill
        videoSignNode.style.preferredSize = CGSize(width: 15, height: 15) // Set the size
        videoSignNode.clipsToBounds = true

        // Add shadow to videoSignNode
        videoSignNode.shadowColor = UIColor.black.cgColor
        videoSignNode.shadowOpacity = 0.5
        videoSignNode.shadowOffset = CGSize(width: 0, height: 2)
        videoSignNode.shadowRadius = 2

        // Configure countNode
        countNode.maximumNumberOfLines = 1

        // Configure infoNode
        infoNode.backgroundColor = .black // Set the background color
        infoNode.maximumNumberOfLines = 1
    }

    
    /// Sets up the username display in the info node.
    func setupUsername() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Create an attributed string with specific font, color, and paragraph style.
        infoNode.attributedText = NSAttributedString(
            string: "@\(post.owner?.username ?? "")",
            attributes: [
                .font: FontManager.shared.roboto(.Bold, size: FontSize - 3),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    
    /// Sets up the stitch count display in the stitch count node.
    func setupStitchCount() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Create an attributed string for the stitch count.
        stitchCountNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.totalOnChain)))",
            attributes: [
                .font: FontManager.shared.roboto(.Regular, size: FontSize - 3),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    
    /// Sets up the view count display in the view count node.
    func setupViewCount() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Create an attributed string for the view count.
        countNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.estimatedCount?.sizeViews ?? 0)))",
            attributes: [
                .font: FontManager.shared.roboto(.Regular, size: FontSize - 3),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // Set the minimum height for the image node.
        let imageNodeMinHeight: CGFloat = constrainedSize.max.height - 43
        imageNode.style.minHeight = ASDimension(unit: .points, value: imageNodeMinHeight)
        imageNode.style.flexGrow = 1.0 // Allow imageNode to fill remaining space

        // Create a horizontal stack for video count.
        let videoCountStack = ASStackLayoutSpec.horizontal()
        videoCountStack.spacing = 2.0
        videoCountStack.children = [videoSignNode, countNode]
        videoCountStack.justifyContent = .center
        videoCountStack.alignItems = .center // Centers nodes vertically

        // Create a horizontal stack for stitch count.
        let stitchCountStack = ASStackLayoutSpec.horizontal()
        stitchCountStack.spacing = 4.0
        stitchCountStack.children = [stitchSignNode, stitchCountNode]
        stitchCountStack.justifyContent = .center
        stitchCountStack.alignItems = .center // Centers nodes vertically

        // Apply insets to the video count stack.
        let videoCountInsets = UIEdgeInsets(top: .infinity, left: 4, bottom: 4, right: .infinity)
        let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)

        // Apply insets to the stitch count stack.
        let stitchCountInsets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: 4, right: 8)
        let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: stitchCountStack)

        // Set the maximum width for the info node.
        let infoNodeMaxWidth: CGFloat = constrainedSize.max.width
        infoNode.style.maxWidth = ASDimension(unit: .points, value: infoNodeMaxWidth)

        // Apply insets to the info node.
        let infoInsets = UIEdgeInsets(top: 6, left: 4, bottom: .infinity, right: .infinity)
        let infoInsetSpec = ASInsetLayoutSpec(insets: infoInsets, child: infoNode)

        // Overlay layout specs to layer the info, video count, and stitch count stacks on the image node.
        let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
        let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: infoInsetSpec)
        let overlayLayoutSpec3 = ASOverlayLayoutSpec(child: overlayLayoutSpec2, overlay: stitchCountInsetSpec)

        // Return the final layout spec with insets applied.
        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: overlayLayoutSpec3)

        return insetLayoutSpec
    }




}

