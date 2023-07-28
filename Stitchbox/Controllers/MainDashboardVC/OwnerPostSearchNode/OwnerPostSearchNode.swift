//
//  OwnerPostSearchNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/4/23.
//

import Foundation

import UIKit
import AsyncDisplayKit

fileprivate let FontSize: CGFloat = 13

class OwnerPostSearchNode: ASCellNode {
    
    var post: PostModel!
    var isSave: Bool!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    private lazy var videoSignNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.image = UIImage(named: "play")
        imageNode.contentMode = .scaleAspectFill
        imageNode.style.preferredSize = CGSize(width: 30, height: 30) // set the size here
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
                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style
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
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        textNode.backgroundColor = .black // set the background color to dark gray
        textNode.maximumNumberOfLines = 1

        DispatchQueue.main.async {
            textNode.view.cornerRadius = 3
        }
        
        return textNode
    }()

    init(with post: PostModel, isSave: Bool) {
        
        self.post = post
        self.isSave = isSave
        self.imageNode = ASNetworkImageNode()
        self.nameNode = ASTextNode()
        super.init()
        
        self.backgroundColor = .clear // set background to clear

      
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        
        if isSave {
            if let username = post.owner?.username {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                infoNode.attributedText = NSAttributedString(
                    string: "@\(username)",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                )

                
            }
            
            paragraphStyles.alignment = .center
            
            let title = post.content
            let hashtags = post.hashtags.joined(separator: " ")
            let combinedString = "\(title) \(hashtags)"
            let textToDisplay = String(combinedString.prefix(60))

            let textAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Using the Roboto Medium style
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyles
            ]


            let attributedString = NSMutableAttributedString(string: textToDisplay, attributes: textAttributes)

            // Hashtag color
            let hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)

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


            
        } else {
            
        }
        
        countView(with: post)
        automaticallyManagesSubnodes = true
        
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

            let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
            let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)
        
            let infoNodeMaxWidth: CGFloat = constrainedSize.max.width // Set the max width based on your main view's width
            infoNode.style.maxWidth = ASDimension(unit: .points, value: infoNodeMaxWidth) // Limit the width of infoNode
            
            let stitchCountInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: infoNode)

            let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
            
            
            let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: stitchCountInsetSpec)

            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 8.0
            stack.justifyContent = .start // align items to start
            stack.alignItems = .stretch // stretch items to fill the width
            stack.children = [overlayLayoutSpec2, nameNode]

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

            let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
            let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)
        
            let infoNodeMaxWidth: CGFloat = constrainedSize.max.width // Set the max width based on your main view's width
            infoNode.style.maxWidth = ASDimension(unit: .points, value: infoNodeMaxWidth) // Limit the width of infoNode
            
            let stitchCountInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: infoNode)

            let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageNode, overlay: videoCountInsetSpec)
            
            
            let overlayLayoutSpec2 = ASOverlayLayoutSpec(child: overlayLayoutSpec, overlay: stitchCountInsetSpec)

            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 8.0
            stack.justifyContent = .start // align items to start
            stack.alignItems = .stretch // stretch items to fill the width
            stack.children = [overlayLayoutSpec2]

            let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

            return insetLayoutSpec
            
        }
    }


    func countView(with data: PostModel) {
        
        APIManager.shared.getPostStats(postId: data.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):

                guard let dataDictionary = apiResponse.body?["data"] as? [String: Any] else {
                    print("Couldn't cast")
                    return
                }
            
                do {
                    let data = try JSONSerialization.data(withJSONObject: dataDictionary, options: .fragmentsAllowed)
                    let decoder = JSONDecoder()
                    let stats = try decoder.decode(Stats.self, from: data)
                    
                    DispatchQueue.main.async {
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        self.countNode.attributedText = NSAttributedString(
                            string: "\(stats.view.total)",
                            attributes: [
                                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style
                                NSAttributedString.Key.foregroundColor: UIColor.white,
                                NSAttributedString.Key.paragraphStyle: paragraphStyle
                            ]
                        )

                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }



}
