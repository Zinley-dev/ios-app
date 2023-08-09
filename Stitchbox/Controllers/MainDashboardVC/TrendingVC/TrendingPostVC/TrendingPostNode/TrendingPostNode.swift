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
    
    var post: PostModel!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var rankingNode: ASTextNode!

    let paragraphStyles = NSMutableParagraphStyle()
    
    
    var stitchCountNode: ASTextNode!
    var infoNode: ASTextNode!
    var videoSignNode: ASImageNode!
    var stitchSignNode: ASImageNode!
    var countNode: ASTextNode!

    init(with post: PostModel, ranking: Int) {
        
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
        
        self.backgroundColor = .clear // set background to clear

      
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        
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
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        rankingNode.backgroundColor = .black
        rankingNode.attributedText = NSAttributedString(
            string: "#\(ranking)",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Medium style,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        rankingNode.maximumNumberOfLines = 1
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.countView()
            self?.countViewStitch()
        }
    
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
            self.infoNode.view.cornerRadius = 3
        }
        
    }


    func countView() {
        
        APIManager.shared.getPostStats(postId: post.id) { [weak self] result in
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
                    
                    DispatchQueue.main.async { [weak self]  in
                        guard let self = self else { return }
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        self.countNode.attributedText = NSAttributedString(
                            string: "\(formatPoints(num: Double(stats.view.total)))",
                            attributes: [
                                NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
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
    
    func countViewStitch() {
        
        APIManager.shared.countPostStitch(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)

                guard let total = apiResponse.body?["total"] as? Int else {
                    print("Couldn't find the 'total' key")
                    return
                }

                DispatchQueue.main.async { [weak self]  in
                    guard let self = self else { return }
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    self.stitchCountNode.attributedText = NSAttributedString(
                        string: "\(formatPoints(num: Double(total)))",
                        attributes: [
                            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize - 3), // Using the Roboto Regular style
                            NSAttributedString.Key.foregroundColor: UIColor.white,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    )

                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }

}
