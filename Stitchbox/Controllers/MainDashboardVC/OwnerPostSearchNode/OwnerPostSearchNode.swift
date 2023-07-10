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
    
    weak var post: PostModel!

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
    
    
    private lazy var stitchNode: ASTextNode = {
        let textNode = ASTextNode()
        //textNode.style.preferredSize.width = 70
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "10 Stitches",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
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
        self.imageNode = ASNetworkImageNode()
        
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
                stitchNode.attributedText = NSAttributedString(
                    string: "\(username)",
                    attributes: [
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                )
                
            } else {
                
            }
            
        } else {
            
        }
        
        countView(with: post)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
       
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
    
        
        let stitchCountInsets = UIEdgeInsets(top: 8, left: 4, bottom: .infinity, right: .infinity)
        let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: stitchNode)

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
