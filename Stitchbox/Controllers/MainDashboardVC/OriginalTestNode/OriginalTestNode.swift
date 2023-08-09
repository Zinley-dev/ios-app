//
//  OriginalTestNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/8/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit
import MarqueeLabel

fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class OriginalTestNode: ASCellNode, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    weak var delegate: OriginalTestNodeDelegate?
    private let yourDelegateInstance: YourDelegateClass
   
    var page = 1
    var posts = [PostModel]()
    var animatedLabel: MarqueeLabel!
    var mainCollectionNode: ASCollectionNode

    private let post: PostModel!
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var at: Int?

    init(with post: PostModel, at: Int) {
        self.post = post
        self.at = at
        
        if !posts.contains(post) {
            posts.append(post)
        }
    
        print("OriginalTestNode \(at) is loading post: \(post.id)")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        mainCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        self.yourDelegateInstance = YourDelegateClass(posts: [post, post]) // initialize with the posts data
        
        super.init()
        
        self.addSubnode(mainCollectionNode)
    }
    
    override func didLoad() {
        super.didLoad()
        
        //self.addAnimatedLabelToTop()
        self.mainCollectionNode.backgroundColor = .black
        self.mainCollectionNode.leadingScreensForBatching = 2.0
        self.applyStyle()
        self.backgroundColor = .black
        self.mainCollectionNode.view.indicatorStyle = .white
        
        // Setting the delegate and data source
        mainCollectionNode.delegate = yourDelegateInstance
        mainCollectionNode.dataSource = yourDelegateInstance
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let ratioSpec = ASRatioLayoutSpec(ratio:ratio, child:self.mainCollectionNode);
           
        return ratioSpec
    }
    
    
}

extension OriginalTestNode {
    func applyStyle() {
        self.mainCollectionNode.view.isPagingEnabled = true
        self.mainCollectionNode.view.backgroundColor = UIColor.black
        self.mainCollectionNode.view.showsVerticalScrollIndicator = false
        self.mainCollectionNode.view.allowsSelection = false
        self.mainCollectionNode.view.contentInsetAdjustmentBehavior = .never
        self.mainCollectionNode.needsDisplayOnBoundsChange = true
    }
}

protocol OriginalTestNodeDelegate: AnyObject {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock
}

class YourDelegateClass: NSObject, OriginalTestNodeDelegate, ASCollectionDelegate, ASCollectionDataSource {
    
    var posts: [PostModel]

    init(posts: [PostModel]) {
        self.posts = posts
    }

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]
        return {
            let startTime = Date()
            
            let node = VideoNode(with: post, at: indexPath.row) // Make sure TestNode is defined
            node.automaticallyManagesSubnodes = true
            
            print("Time taken to load TestNode: \(Date().timeIntervalSince(startTime)) seconds")

            return node
        }
    }
}
