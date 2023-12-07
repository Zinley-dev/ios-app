//
//  TrendingPostNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/21/23.
//

import Foundation
import UIKit
import AsyncDisplayKit

fileprivate let FontSize: CGFloat = 13

class TrendingPostNode: ASCellNode {
    
    
    deinit {
        print("TrendingPostNode is being deallocated.")
      
    }
    
    private weak var post: PostModel!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var rankingNode: ASTextNode!

    let paragraphStyles = NSMutableParagraphStyle()
    
    
    var stitchCountNode: ASTextNode!
    var infoNode: ASTextNode!
    var videoSignNode: ASImageNode!
    var stitchSignNode: ASImageNode!
    var countNode: ASTextNode!
    var ranking = 0
    
    init(with post: PostModel, ranking: Int) {
        self.ranking = ranking
        self.post = post
        self.imageNode = ASNetworkImageNode()
        self.nameNode = ASTextNode()
        self.rankingNode = ASTextNode() // initialize the ranking node
        self.stitchCountNode = ASTextNode()
        self.countNode = ASTextNode()
        self.infoNode = ASTextNode()
        self.videoSignNode = ASImageNode()
        self.stitchSignNode = ASImageNode()
        
        
        super.init()
        
        videoSignNode.isLayerBacked = true
        stitchSignNode.isLayerBacked = true
        stitchCountNode.isLayerBacked = true
        countNode.isLayerBacked = true
        imageNode.isLayerBacked = true
        imageNode.shouldRenderProgressImages = true
        imageNode.url = post.imageUrl
        automaticallyManagesSubnodes = true
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        
        
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        setupLayout()
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        cleanupnode()
    }

    
    func setupLayout() {
        // Basic setup
        self.backgroundColor = .clear
        self.imageNode.backgroundColor = .clear
        imageNode.cornerRadius = 10
        imageNode.contentMode = .scaleAspectFill

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Setup for the owner's username
        if let username = post.owner?.username {
            infoNode.attributedText = NSAttributedString(
                string: "@\(username)",
                attributes: [
                    .font: FontManager.shared.roboto(.Bold, size: FontSize),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
            )
        }

        // Setup for the post content and hashtags
        let title = post.content
        let hashtags = post.hashtags?.joined(separator: " ") ?? ""
        let combinedString = "\(title) \(hashtags)".prefix(60)
        let attributedString = NSMutableAttributedString(string: String(combinedString), attributes: [
            .font: FontManager.shared.roboto(.Medium, size: FontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ])

        // Color for hashtags
        let hashtagColor = UIColor(red: 208/255, green: 223/255, blue: 252/255, alpha: 1)
        for word in combinedString.split(separator: " ") {
            if word.hasPrefix("#"), let range = String(combinedString).range(of: String(word)) {
                attributedString.addAttribute(.foregroundColor, value: hashtagColor, range: NSRange(range, in: combinedString))
            }
        }
        self.nameNode.attributedText = attributedString

        // Setup for the ranking node
        rankingNode.backgroundColor = .black
        rankingNode.attributedText = NSAttributedString(
            string: "#\(ranking)",
            attributes: [
                .font: FontManager.shared.roboto(.Bold, size: FontSize),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
        rankingNode.maximumNumberOfLines = 1

        // Additional setup
        setupnode()

        self.countNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.estimatedCount?.sizeViews ?? 0)))",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
        self.stitchCountNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.totalOnChain)))",
            attributes: [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
        )
        
    }
    

    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
           
        rankingNode.style.width = ASDimension(unit: .points, value: 40)
        let nameNodeHeight: CGFloat = 35.0 // Set your desired height
        nameNode.style.height = ASDimension(unit: .points, value: nameNodeHeight)
        nameNode.style.flexGrow = 0.0 // Prevents nameNode from occupying more space

        let imageNodeMinHeight: CGFloat = constrainedSize.max.height - 35 - 8 // Set a minimum height for the image node
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
        
        let allStack = ASStackLayoutSpec.horizontal()
        allStack.spacing = 8.0
        allStack.children = [videoCountStack, stitchCountStack]
        allStack.justifyContent = .center
        allStack.alignItems = .center // This centers the nodes vertically
        
        let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
        let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: allStack)

        let infoInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
        let infoInsetSpec = ASInsetLayoutSpec(insets: infoInsets, child: infoNode)

        // Inset the rankingNode at the right-bottom corner
        let rankingInsets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: 6 , right: 0)
        let rankingInsetSpec = ASInsetLayoutSpec(insets: rankingInsets, child: rankingNode)

        let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
        let overlayWithRankingSpec = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: rankingInsetSpec)
        let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayWithRankingSpec, overlay: infoInsetSpec)

        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 8.0
        stack.justifyContent = .start // align items to start
        stack.alignItems = .stretch // stretch items to fill the width
        stack.children = [overlayLayoutSpec2, nameNode] // removed rankingNode from here

        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

        return insetLayoutSpec
    }


    func setupnode() {
        
        stitchSignNode.image = UIImage(named: "partner white")
        stitchSignNode.contentMode = .scaleAspectFill
        stitchSignNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
        stitchSignNode.clipsToBounds = true

     
        let paragraphStyle = NSMutableParagraphStyle()
        //textNode.style.preferredSize = CGSize(width: 100, height: 25) // set the size here
        paragraphStyle.alignment = .center
        stitchCountNode.maximumNumberOfLines = 1
        
        videoSignNode.image = UIImage(named: "play")
        videoSignNode.contentMode = .scaleAspectFill
        videoSignNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
        videoSignNode.clipsToBounds = true

        countNode.maximumNumberOfLines = 1
       
        infoNode.backgroundColor = .black // set the background color to dark gray
        infoNode.maximumNumberOfLines = 1

        
    }
    
    /// Resets the nodes to their default states after being set up by setupnode().
    func cleanupnode() {
        // Reset stitchSignNode properties
        stitchSignNode.image = nil
        stitchSignNode.contentMode = .scaleToFill // Or any default contentMode you prefer
        stitchSignNode.style.preferredSize = CGSize.zero
        stitchSignNode.clipsToBounds = false

        // Reset stitchCountNode properties
        stitchCountNode.attributedText = nil
        stitchCountNode.maximumNumberOfLines = 0

        // Reset videoSignNode properties
        videoSignNode.image = nil
        videoSignNode.contentMode = .scaleToFill // Or any default contentMode you prefer
        videoSignNode.style.preferredSize = CGSize.zero
        videoSignNode.clipsToBounds = false

        // Reset countNode properties
        countNode.attributedText = nil
        countNode.maximumNumberOfLines = 0

        // Reset infoNode properties
        infoNode.backgroundColor = nil // Clear any specific background color
        infoNode.attributedText = nil
        infoNode.maximumNumberOfLines = 0

        // Additional properties that were set in setupnode() should also be reset here.
        // ...
        
        self.backgroundColor = nil
        imageNode.backgroundColor = nil
        rankingNode.backgroundColor = nil

        // Reset imageNode properties
        imageNode.cornerRadius = 0
        imageNode.contentMode = .scaleToFill // Or any default contentMode you prefer
        imageNode.image = nil // Resetting the image

        // Clear attributed text in nodes
        infoNode.attributedText = nil
        nameNode.attributedText = nil
        rankingNode.attributedText = nil
        countNode.attributedText = nil
        stitchCountNode.attributedText = nil

        // Reset maximumNumberOfLines for rankingNode
        rankingNode.maximumNumberOfLines = 0
    }

}
