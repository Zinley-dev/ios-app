//
//  PostNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/27/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class PostNode: ASCellNode, ASVideoNodeDelegate {
    
    weak var post: PostModel!
    
    var imageNode: ASImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonsNode: ASDisplayNode
    
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    let demoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas auctor eu enim in lacinia. Nulla at felis sodales, congue purus eget, tincidunt tortor."
    
    //var copyImageNode: ASNetworkImageNode
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonsNode = ASDisplayNode()
        
        super.init()
        
        
        DispatchQueue.main.async {
            
            self.headerView = PostHeader()
            
            self.headerNode.view.addSubview(self.headerView)
            self.headerView.settingBtn.setTitle("", for: .normal)
            
            self.headerView.translatesAutoresizingMaskIntoConstraints = false
            self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            
            
            
            /*
             ButtonsHeader
             */
            
            
            self.buttonsView = ButtonsHeader()
            
            self.buttonsNode.view.addSubview(self.buttonsView)
            self.buttonsView.likeBtn.setTitle("", for: .normal)
            self.buttonsView.commentBtn.setTitle("", for: .normal)
            self.buttonsView.shareBtn.setTitle("", for: .normal)
            self.buttonsView.streamlinkBtn.setTitle("", for: .normal)
            
            self.buttonsView.translatesAutoresizingMaskIntoConstraints = false
            self.buttonsView.topAnchor.constraint(equalTo: self.buttonsNode.view.topAnchor, constant: 0).isActive = true
            self.buttonsView.bottomAnchor.constraint(equalTo: self.buttonsNode.view.bottomAnchor, constant: 0).isActive = true
            self.buttonsView.leadingAnchor.constraint(equalTo: self.buttonsNode.view.leadingAnchor, constant: 0).isActive = true
            self.buttonsView.trailingAnchor.constraint(equalTo: self.buttonsNode.view.trailingAnchor, constant: 0).isActive = true
              
        }
       
        
        automaticallyManagesSubnodes = true
        self.imageNode.contentMode = .scaleAspectFill
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        headerNode.backgroundColor = UIColor.clear
        buttonsNode.backgroundColor = UIColor.clear
        
        self.contentNode.attributedText = NSAttributedString(string: demoText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: post.imageUrl) {
            DispatchQueue.main.async {
              self.imageNode.image = UIImage(data: data)
            }
          }
        }
    
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
    
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
        //contentNode.style.contentInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        let headerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)
        
        
        var children: [ASLayoutElement] = [headerInsetSpec]
        
        
       
        let imageSize: CGSize
        
        if demoText != "" {
            
            let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
            let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
            children.append(contentInsetSpec)
        }
        
        if isHorizontal() {
            imageSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width / 1.91)
        } else {
    
            if post.metadata?.width == post.metadata?.height {
                imageSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width)
            } else {
                imageSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width * 0.8)
            }

        }
        

        imageNode.style.preferredSize = imageSize
        children.append(imageNode)
        
       
        buttonsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        let buttonsInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let buttonsInsetSpec = ASInsetLayoutSpec(insets: buttonsInset, child: buttonsNode)
        
        children.append(buttonsInsetSpec)
            
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = children
       
        return verticalStack
    }
    
    func isHorizontal() -> Bool {
        
        if let width = post.metadata?.width, let height = post.metadata?.height {
            
            if (width/height) >= 1.5 {
                
                return true
            }
            
        }
        
        return false
        
    }

}
