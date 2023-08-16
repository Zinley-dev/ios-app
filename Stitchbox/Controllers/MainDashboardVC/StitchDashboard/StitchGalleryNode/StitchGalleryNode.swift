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
    
    deinit {
        print("StitchGalleryNode is being deallocated.")
    }
    
    var post: PostModel!
    private var imageNode: ASNetworkImageNode!
    
    private var infoNode: ASTextNode!
    private var videoSignNode: ASImageNode!
    private var stitchSignNode: ASImageNode!
    private var countNode: ASTextNode!
    private var stitchCountNode: ASTextNode!
    
    init(with post: PostModel) {
        
        self.post = post
        self.imageNode = ASNetworkImageNode()
        self.stitchCountNode = ASTextNode()
        self.countNode = ASTextNode()
        self.infoNode = ASTextNode()
        self.videoSignNode = ASImageNode()
        self.stitchSignNode = ASImageNode()
        
        super.init()
        
        self.backgroundColor = .clear // set background to clear
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15

      
    }
    
    override func didLoad() {
        super.didLoad()
        
        setupnode()
        setupUsername()
        setupStitchCount()
        setupViewCount()
        
    }
    
    func setupnode() {
        
        stitchSignNode.image = UIImage(named: "partner white")
        stitchSignNode.contentMode = .scaleAspectFill
        stitchSignNode.style.preferredSize = CGSize(width: 15, height: 15) // set the size here
        stitchSignNode.clipsToBounds = true

        // Add shadow to layer
        stitchSignNode.shadowColor = UIColor.black.cgColor
        stitchSignNode.shadowOpacity = 0.5
        stitchSignNode.shadowOffset = CGSize(width: 0, height: 2)
        stitchSignNode.shadowRadius = 2
        
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //textNode.style.preferredSize = CGSize(width: 100, height: 25) // set the size here
        paragraphStyle.alignment = .center
        stitchCountNode.maximumNumberOfLines = 1
        
        videoSignNode.image = UIImage(named: "play")
        videoSignNode.contentMode = .scaleAspectFill
        videoSignNode.style.preferredSize = CGSize(width: 15, height: 15) // set the size here
        videoSignNode.clipsToBounds = true

        // Add shadow to layer
        videoSignNode.shadowColor = UIColor.black.cgColor
        videoSignNode.shadowOpacity = 0.5
        videoSignNode.shadowOffset = CGSize(width: 0, height: 2)
        videoSignNode.shadowRadius = 2
        
    
        countNode.maximumNumberOfLines = 1
       
        infoNode.backgroundColor = .black // set the background color to dark gray
        infoNode.maximumNumberOfLines = 1

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.infoNode.view.cornerRadius = 3
        }
        
    }
    

    
    func setupUsername() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        infoNode.attributedText = NSAttributedString(
            string: "@\(post.owner?.username ?? "")",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize - 3), // Using the Roboto Bold style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
    }
    
    func setupStitchCount() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.stitchCountNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.totalStitchTo + post.totalMemberStitch)))",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
    }
    
    func setupViewCount() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.countNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.estimatedCount?.sizeViews ?? 0)))",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageNodeMinHeight: CGFloat = constrainedSize.max.height - 43 // Adjusted for missing nameNode and its spacing
        imageNode.style.minHeight = ASDimension(unit: .points, value: imageNodeMinHeight)
        imageNode.style.flexGrow = 1.0 // Allows imageNode to fill remaining space

        let videoCountStack = ASStackLayoutSpec.horizontal()
        videoCountStack.spacing = 2.0
        videoCountStack.children = [videoSignNode, countNode]
        videoCountStack.justifyContent = .center
        videoCountStack.alignItems = .center // This centers the nodes vertically

        let stitchCountStack = ASStackLayoutSpec.horizontal()
        stitchCountStack.spacing = 4.0
        stitchCountStack.children = [stitchSignNode, stitchCountNode]
        stitchCountStack.justifyContent = .center
        stitchCountStack.alignItems = .center // This centers the nodes vertically

        let videoCountInsets = UIEdgeInsets(top: .infinity, left: 4, bottom: 4, right: .infinity)
        let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)

        let stitchCountInsets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: 4, right: 8)
        let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: stitchCountStack)

        let infoNodeMaxWidth: CGFloat = constrainedSize.max.width // Set the max width based on your main view's width
        infoNode.style.maxWidth = ASDimension(unit: .points, value: infoNodeMaxWidth) // Limit the width of infoNode

        let infoInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
        let infoInsetSpec = ASInsetLayoutSpec(insets: infoInsets, child: infoNode)

        let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
        let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: infoInsetSpec)
        let overlayLayoutSpec3 = ASOverlayLayoutSpec(child: overlayLayoutSpec2, overlay: stitchCountInsetSpec)

        // Now, since we don't have nameNode, we'll directly return overlayLayoutSpec3 wrapped in an ASInsetLayoutSpec for cleanliness
        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: overlayLayoutSpec3)

        return insetLayoutSpec
    }



}

