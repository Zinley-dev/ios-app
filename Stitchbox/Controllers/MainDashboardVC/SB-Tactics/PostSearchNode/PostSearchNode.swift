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
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "0",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        textNode.maximumNumberOfLines = 1
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
        
        let searchResults = [title, ownerName, hashtags].compactMap { searchString(in: $0, for: keyword, maxLength: 35) }
        let highlightedKeyword = searchResults.first ?? ""
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        let attributedString = NSMutableAttributedString(string: highlightedKeyword, attributes: textAttributes)
        if let range = highlightedKeyword.range(of: keyword, options: .caseInsensitive) {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondary, range: NSRange(range, in: highlightedKeyword)) // Change UIColor to your preferred highlight color
        }
        
        self.nameNode.attributedText = attributedString
        
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        
        DispatchQueue.main.async {
            self.videoSignNode.shadowColor = UIColor.black.cgColor
            self.videoSignNode.shadowOpacity = 0.5
            self.videoSignNode.shadowOffset = CGSize(width: 0, height: 2)
            self.videoSignNode.shadowRadius = 2
            self.videoSignNode.clipsToBounds = false
            self.videoSignNode.layer.masksToBounds = false

            self.countNode.shadowColor = UIColor.black.cgColor
            self.countNode.shadowOpacity = 0.5
            self.countNode.shadowOffset = CGSize(width: 0, height: 2)
            self.countNode.shadowRadius = 2
            self.countNode.clipsToBounds = false
            self.countNode.layer.masksToBounds = false
        }

        
        countView(with: post)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let nameNodeHeight: CGFloat = 35.0
        nameNode.style.height = ASDimension(unit: .points, value: nameNodeHeight)

        let imageNodeAspectRatio: CGFloat = 9.0 / 13.5
        let ratioLayoutSpec = ASRatioLayoutSpec(ratio: imageNodeAspectRatio, child: imageNode)
        ratioLayoutSpec.style.flexGrow = 1.0

        let videoCountStack = ASStackLayoutSpec.horizontal()
        videoCountStack.spacing = 8.0
        videoCountStack.children = [videoSignNode, countNode]
        videoCountStack.justifyContent = .center
        videoCountStack.alignItems = .center

        // Position videoCountStack at the bottom left of the image
        let videoCountInsets = UIEdgeInsets(top: .infinity, left: 0, bottom: 0, right: .infinity)
        let videoCountInsetSpec = ASInsetLayoutSpec(insets: videoCountInsets, child: videoCountStack)

        // Add the stack as an overlay to the image
        let overlayLayoutSpec = ASOverlayLayoutSpec(child: ratioLayoutSpec, overlay: videoCountInsetSpec)

        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 8.0
        stack.justifyContent = .start
        stack.alignItems = .stretch
        stack.children = [overlayLayoutSpec, nameNode]

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
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
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
