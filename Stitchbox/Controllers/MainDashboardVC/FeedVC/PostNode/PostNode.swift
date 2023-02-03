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

class PostNode: ASCellNode, ASVideoNodeDelegate {
    
    weak var post: PostModel!
    
    var imageNode: ASImageNode
    //var copyImageNode: ASNetworkImageNode
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASNetworkImageNode()
        super.init()
        
        automaticallyManagesSubnodes = true
        self.imageNode.contentMode = .scaleAspectFit
        print(post.setting)
        
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: post.imageUrl) {
            DispatchQueue.main.async {
              self.imageNode.image = UIImage(data: data)
            }
          }
        }
    
    }
    
    
    override func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        // Lays out a component at a fixed aspect ratio which can scale
        let ratioSpec = ASRatioLayoutSpec(ratio: ratio, child: imageNode)
       
        return ratioSpec
    }
}
