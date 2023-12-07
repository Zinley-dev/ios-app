//
//  OwnerPostSearchNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/4/23.
//

import Foundation
import UIKit
import AsyncDisplayKit


class OwnerPostSearchNode: ASCellNode {
    
    var post: PostModel!
    var isSave: Bool!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var fontSize: CGFloat = 13
    let paragraphStyles = NSMutableParagraphStyle()
    
    private lazy var stitchSignNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.image = UIImage(named: "partner white")
        imageNode.contentMode = .scaleAspectFill
        imageNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
        imageNode.clipsToBounds = true

        // Add shadow to layer
        imageNode.shadowColor = UIColor.black.cgColor
        imageNode.shadowOpacity = 0.5
        imageNode.shadowOffset = CGSize(width: 0, height: 2)
        imageNode.shadowRadius = 2
        
        return imageNode
    }()


    private lazy var stitchCountNode: ASTextNode = {
        let textNode = ASTextNode()
        let paragraphStyle = NSMutableParagraphStyle()
        //textNode.style.preferredSize = CGSize(width: 100, height: 25) // set the size here
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "0",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: fontSize - 3), // Using the Roboto Regular style as an example
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        textNode.maximumNumberOfLines = 1
        return textNode
    }()
    
    private lazy var videoSignNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.image = UIImage(named: "play")
        imageNode.contentMode = .scaleAspectFill
        imageNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
        imageNode.clipsToBounds = true

        // Add shadow to layer
        imageNode.shadowColor = UIColor.black.cgColor
        imageNode.shadowOpacity = 0.5
        imageNode.shadowOffset = CGSize(width: 0, height: 2)
        imageNode.shadowRadius = 2
        
        return imageNode
    }()


    private lazy var countNode: ASTextNode = {
        let textNode = ASTextNode()
        let paragraphStyle = NSMutableParagraphStyle()
        //textNode.style.preferredSize = CGSize(width: 100, height: 25) // set the size here
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "0",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: fontSize), // Using the Roboto Regular style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        textNode.maximumNumberOfLines = 1
        return textNode
    }()
    
    
    private lazy var infoNode: ASTextNode = {
        let textNode = ASTextNode()
        //textNode.style.preferredSize.width = 70
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: fontSize), // Using the Roboto Bold style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        textNode.backgroundColor = .black // set the background color to dark gray
        textNode.maximumNumberOfLines = 1

       
        return textNode
    }()

    init(with post: PostModel, isSave: Bool) {
        
        self.post = post
        self.isSave = isSave
        self.imageNode = ASNetworkImageNode()
        self.nameNode = ASTextNode()
        super.init()
        
        stitchSignNode.isLayerBacked = true
        stitchCountNode.isLayerBacked = true
        videoSignNode.isLayerBacked = true
        countNode.isLayerBacked = true
        infoNode.isLayerBacked = true
        nameNode.isLayerBacked = true
        imageNode.isLayerBacked = true
        imageNode.shouldRenderProgressImages = true
     
        automaticallyManagesSubnodes = true
        
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        setupLayout()
        
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        cleanupLayout()
    }
    
    
    /// Resets the layout elements to their default states.
    func cleanupLayout() {
        // Clear the background color
        self.backgroundColor = nil

        // Reset imageNode properties
        imageNode.backgroundColor = nil
        imageNode.contentMode = .scaleToFill // Or any default contentMode you prefer
        imageNode.cornerRadius = 0
        imageNode.url = nil // Resetting the image

        // Clear the attributed text in infoNode, nameNode, stitchCountNode, and countNode
        infoNode.attributedText = nil
        nameNode.attributedText = nil
        stitchCountNode.attributedText = nil
        countNode.attributedText = nil

       
    }

   
    
    func setupLayout() {
        self.backgroundColor = .clear // set background to clear
        imageNode.url = post.imageUrl
      
        self.imageNode.backgroundColor = .clear
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        
        if isSave {
            if let username = post.owner?.username {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                infoNode.attributedText = NSAttributedString(
                    string: "@\(username)",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: fontSize), // Using the Roboto Bold style
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                )

                
            }
            
            paragraphStyles.alignment = .center
            
            let title = post.content
            let hashtags = post.hashtags?.joined(separator: " ")
            let combinedString = "\(title) \(hashtags ?? "")"
            let textToDisplay = String(combinedString.prefix(60))

            let textAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: fontSize), // Using the Roboto Medium style
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyles
            ]


            let attributedString = NSMutableAttributedString(string: textToDisplay, attributes: textAttributes)

            // Hashtag color
            let hashtagColor = UIColor(red: 208/255, green: 223/255, blue: 252/255, alpha: 1)

            // Iterate over all words in the string
            for word in textToDisplay.split(separator: " ") {
                // Check if the word is a hashtag
                if word.hasPrefix("#") {
                    // Find the range of the hashtag
                    if let range = textToDisplay.range(of: String(word)) {
                        // Apply the color to the hashtag
                        attributedString.addAttribute(.foregroundColor, value: hashtagColor, range: NSRange(range, in: textToDisplay))
                    }
                }
            }

            self.nameNode.attributedText = attributedString


            
        }
        
        
        setupUsername()
        setupStitchCount()
        setupViewCount()
        
    }
    
    func setupUsername() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        infoNode.attributedText = NSAttributedString(
            string: "@\(post.owner?.username ?? "")",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: fontSize), // Using the Roboto Bold style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
    }
    
    func setupStitchCount() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.stitchCountNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(post.totalOnChain)))",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: fontSize - 3), // Using the Roboto Regular style
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
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: fontSize - 3), // Using the Roboto Regular style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
       
        if isSave {
            
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

            let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
            let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)
        
            let infoNodeMaxWidth: CGFloat = constrainedSize.max.width // Set the max width based on your main view's width
            infoNode.style.maxWidth = ASDimension(unit: .points, value: infoNodeMaxWidth) // Limit the width of infoNode
            
            let stitchCountInsets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: 4, right: 8)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: stitchCountStack)
            
            
            let infoInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
            let infoInsetSpec = ASInsetLayoutSpec(insets: infoInsets, child: infoNode)

            let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
            
            let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: infoInsetSpec)
            
            let overlayLayoutSpec3 = ASOverlayLayoutSpec(child: overlayLayoutSpec2, overlay: stitchCountInsetSpec)

            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 8.0
            stack.justifyContent = .start // align items to start
            stack.alignItems = .stretch // stretch items to fill the width
            stack.children = [overlayLayoutSpec3, nameNode]

            let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

            return insetLayoutSpec
            
        } else {
            
            let imageNodeMinHeight: CGFloat = constrainedSize.max.height
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

            let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
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

            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 8.0
            stack.justifyContent = .start // align items to start
            stack.alignItems = .stretch // stretch items to fill the width
            stack.children = [overlayLayoutSpec3]

            let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

            return insetLayoutSpec
            
        }
    }



}
