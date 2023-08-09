//
//  TestNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/6/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import AVFoundation
import AVKit
import ActiveLabel


class VideoNode: ASCellNode {
    
    deinit {
        print("TestNode is being deallocated.")
    }
    
    var post: PostModel
    
    
    var videoNode: ASVideoNode
    var gradientNode: GradienView
    
    //------------------------------------------//
    
    
 
    
    init(with post: PostModel, at: Int) {
        //print("TestNode \(at) is loading post: \(post.id)")
        self.post = post
        self.gradientNode = GradienView()
        self.videoNode = ASVideoNode()

        super.init()
        
        self.gradientNode.isLayerBacked = true;
        self.gradientNode.isOpaque = false;
        
        self.videoNode.url = self.getThumbnailURL(post: post)
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue;
    
        DispatchQueue.main.async() {
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
        }
        
        self.addSubnode(self.videoNode)
        self.addSubnode(self.gradientNode)
        
        self.gradientNode.isHidden = true
    }

    
    func getThumbnailURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=0.1"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
    }
    
    func getVideoURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
            let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
            let ratioSpec = ASRatioLayoutSpec(ratio:ratio, child:self.videoNode);
            let gradientOverlaySpec = ASOverlayLayoutSpec(child:ratioSpec, overlay:self.gradientNode)
            return gradientOverlaySpec
        }
    
 
}
