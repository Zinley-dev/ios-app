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
    
    var videoNode: ASVideoNode
    var imageNode: ASImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonsNode: ASDisplayNode
    
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!

    
    //var copyImageNode: ASNetworkImageNode
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonsNode = ASDisplayNode()
        self.videoNode = ASVideoNode()
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
        
        self.contentNode.attributedText = NSAttributedString(string: post.content, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: post.imageUrl) {
            DispatchQueue.main.async {
              self.imageNode.image = UIImage(data: data)
            }
          }
        }
        
        
        if post.muxPlaybackId != "" {
            self.videoNode.url = self.getThumbnailVideoNodeURL(post: post)
            self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
            self.videoNode.shouldAutoplay = true
            self.videoNode.shouldAutorepeat = true
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            self.videoNode.contentMode = .scaleAspectFill
            self.videoNode.muted = false
            
            
            DispatchQueue.main.async {
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
 
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
        
        
       
        let mediaSize: CGSize
        
        if post.content != "" {
            
            let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
            let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
            children.append(contentInsetSpec)
        }
        
        if post.metadata?.width == post.metadata?.height {
            mediaSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width)
        } else {
            mediaSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width * (post.metadata?.height ?? constrainedSize.max.width) / (post.metadata?.width ?? constrainedSize.max.width) )
        }
        
        if post.muxPlaybackId != "" {
            
            videoNode.style.preferredSize = mediaSize
            children.append(videoNode)
            
        } else {
            
           
            imageNode.style.preferredSize = mediaSize
            children.append(imageNode)
            
            
        }
        
        
        
       
        buttonsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        let buttonsInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let buttonsInsetSpec = ASInsetLayoutSpec(insets: buttonsInset, child: buttonsNode)
        
        children.append(buttonsInsetSpec)
            
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = children
       
        return verticalStack
    }
    
    
    func getThumbnailVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=0.025"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }
    
    func getVideoURLForRedundant_stream(post: PostModel) -> URL? {
        
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8?redundant_streams=true"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }

       
    }
    

}
