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
    
    weak var post: PostModel!
    
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
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
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
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: FontSize),
                NSAttributedString.Key.foregroundColor: UIColor.black,
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

    init(with post: PostModel, keyword: String) {
        
        self.post = post
        self.nameNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        
        super.init()
        
        self.backgroundColor = .clear // set background to clear
        
        paragraphStyles.alignment = .center
        
        let title = post.content
        let ownerName = post.owner?.username ?? ""
        let hashtags = post.hashtags.joined(separator: " ")
        
        let searchResults = [title, ownerName, hashtags].compactMap { searchString(in: $0, for: keyword, maxLength: 60) }
        let highlightedKeyword = searchResults.first ?? ""
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        let attributedString = NSMutableAttributedString(string: highlightedKeyword, attributes: textAttributes)
        if let range = highlightedKeyword.range(of: keyword, options: .caseInsensitive) {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondary, range: NSRange(range, in: highlightedKeyword)) // Change UIColor to your preferred highlight color
        }
        
        self.nameNode.attributedText = attributedString
        
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        infoNode.attributedText = NSAttributedString(
            string: "@\(post.owner?.username ?? "")",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: FontSize),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        
        countView(with: post)
        automaticallyManagesSubnodes = true
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

        let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 2, right: .infinity)
        let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)
    
        
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
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
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
