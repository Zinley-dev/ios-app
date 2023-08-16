//
//  TacticsGameNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import UIKit
import AsyncDisplayKit

fileprivate let FontSize: CGFloat = 13

class PostSearchNode: ASCellNode {
    
    deinit {
        print("PostSearchNode is being deallocated.")
    }
    
    private var post: PostModel!
    
    private var nameNode: ASTextNode!
    private var imageNode: ASNetworkImageNode!
    private var stitchCountNode: ASTextNode!
    private var infoNode: ASTextNode!
    private var videoSignNode: ASImageNode!
    private var stitchSignNode: ASImageNode!
    private var countNode: ASTextNode!
   
    let paragraphStyles = NSMutableParagraphStyle()
    var keyword = ""

    init(with post: PostModel, keyword: String) {
        self.keyword = keyword
        self.post = post
        self.nameNode = ASTextNode()
        self.stitchCountNode = ASTextNode()
        self.countNode = ASTextNode()
        self.infoNode = ASTextNode()
        
        self.imageNode = ASNetworkImageNode()
        self.videoSignNode = ASImageNode()
        self.stitchSignNode = ASImageNode()
       
        
        super.init()
        
        
        nameNode.isLayerBacked = true
        infoNode.isLayerBacked = true
        imageNode.isLayerBacked = true
        countNode.isLayerBacked = true
        imageNode.shouldRenderProgressImages = true
        imageNode.url = post.imageUrl
        
     
        
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = .clear // set background to clear
        paragraphStyles.alignment = .center
        
        let title = post.content
        let ownerName = post.owner?.username ?? ""
        let hashtags = post.hashtags?.joined(separator: " ")
        
        let searchResults = [title, ownerName, hashtags ?? ""].compactMap { searchString(in: $0, for: keyword, maxLength: 60) }
        let highlightedKeyword = searchResults.first ?? ""
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Using the Roboto Medium style
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]

        
        let attributedString = NSMutableAttributedString(string: highlightedKeyword, attributes: textAttributes)
        if let range = highlightedKeyword.range(of: keyword, options: .caseInsensitive) {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondary, range: NSRange(range, in: highlightedKeyword)) // Change UIColor to your preferred highlight color
        }
        
        self.nameNode.attributedText = attributedString
        
        self.imageNode.backgroundColor = .clear
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        imageNode.contentMode = .scaleAspectFill
        setupUsername()
        setupStitchCount()
        setupViewCount()
        setupnode()
        
    }
    
    func setupUsername() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        infoNode.attributedText = NSAttributedString(
            string: "@\(post.owner?.username ?? "")",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
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

        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 8.0
        stack.justifyContent = .start // align items to start
        stack.alignItems = .stretch // stretch items to fill the width
        stack.children = [overlayLayoutSpec3, nameNode]

        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

        return insetLayoutSpec
    }

    func setupnode() {
        
        stitchSignNode.image = UIImage(named: "partner white")
        stitchSignNode.contentMode = .scaleAspectFill
        stitchSignNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
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
        videoSignNode.style.preferredSize = CGSize(width: 25, height: 25) // set the size here
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
            //self.infoNode.view.cornerRadius = 3
        }
        
    }


    func searchString(in text: String, for keyword: String, maxLength: Int) -> String? {
        if let range = text.range(of: keyword, options: .caseInsensitive) {
            let lowerBoundOffset = min(text.distance(from: text.startIndex, to: range.lowerBound), maxLength / 2)
            let upperBoundOffset = min(text.distance(from: range.upperBound, to: text.endIndex), maxLength / 2)
            let start = text.index(range.lowerBound, offsetBy: -lowerBoundOffset)
            let end = text.index(range.upperBound, offsetBy: upperBoundOffset)
            return String(text[start..<end])
        }
        return nil
    }

}
