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


class TestNode: ASCellNode {
    
    deinit {
        print("TestNode is being deallocated.")
        self.videoNode.asset = nil
    }
    
    var post: PostModel
    var backgroundImageNode: ASNetworkImageNode
    var videoNode: ASVideoNode
    var gradientNode: GradienView
    
    //------------------------------------------//
    
    var allowProcess = true
    var isFollowingUser = false
    var isSave = false
    var previousTimeStamp: TimeInterval = 0.0
    var totalWatchedTime: TimeInterval = 0.0
    var isStitched = false
    var collectionNode: ASCollectionNode?
   
    var last_view_timestamp =  NSDate().timeIntervalSince1970
   
    var allowStitch = false
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonNode: ASDisplayNode
    
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var sideButtonsView: ButtonSideList!
   
    var time = 0
    var likeCount = 0
    var saveCount = 0
    var isLike = false
    var isSelectedPost = false
    var settingBtn : ((ASCellNode) -> Void)?
    var viewStitchBtn : ((ASCellNode) -> Void)?
    var soundBtn : ((ASCellNode) -> Void)?
    var isViewed = false
    var currentTimeStamp: TimeInterval!
    var originalCenter: CGPoint?
    var label: ActiveLabel!
    
    
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
 
    
    init(with post: PostModel) {
        self.post = post
        self.backgroundImageNode = ASNetworkImageNode()
        self.gradientNode = GradienView()
        self.videoNode = ASVideoNode()
        
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonNode = ASDisplayNode()
        
        super.init()
        
        self.backgroundImageNode.url = self.getThumbnailURL(post: post)
        self.backgroundImageNode.contentMode = .scaleAspectFill
        
        self.gradientNode.isLayerBacked = true;
        self.gradientNode.isOpaque = false;
        
        self.videoNode.url = self.getThumbnailURL(post: post)
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue;
    
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: (self.getVideoURL(post: post))!)
        }

        self.addSubnode(self.videoNode)
        self.addSubnode(self.gradientNode)
        
        DispatchQueue.main.async() {  [weak self] in
            guard let self = self else { return }
            
            /*
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
            view.addGestureRecognizer(pinchGestureRecognizer)
            
            
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
            panGestureRecognizer.delegate = self
            panGestureRecognizer.minimumNumberOfTouches = 2
            view.addGestureRecognizer(self.panGestureRecognizer)
            
           
            headerView = PostHeader()
            headerNode.view.addSubview(self.headerView)

            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            
            if post.setting?.allowStitch == false {
                headerView.createStitchView.isHidden = true
                headerView.createStitchStack.isHidden = true
                headerView.stichBtn.isHidden = true
            } else {
                
                if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
                    headerView.createStitchView.isHidden = true
                    headerView.createStitchStack.isHidden = true
                    headerView.stichBtn.isHidden = true
                } else {
                    headerView.createStitchView.isHidden = false
                    headerView.stichBtn.isHidden = false
                    headerView.createStitchStack.isHidden = false
                }
            }
            
            if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
                
                self.headerView.followBtn.isHidden = true
                
            } else {
                
                //checkIfFollow()
                //checkIfFollowedMe()
                
                // check
                
            }
            
            buttonsView = ButtonsHeader()
            buttonNode.view.addSubview(self.buttonsView)
            buttonsView.translatesAutoresizingMaskIntoConstraints = false
            buttonsView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
            buttonsView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
            buttonsView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
            buttonsView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true

            buttonsView.likeBtn.setTitle("", for: .normal)
            buttonsView.commentBtn.setTitle("", for: .normal)
            buttonsView.commentBtn.setImage(cmtImage, for: .normal)
            buttonsView.shareBtn.setTitle("", for: .normal)
            buttonsView.shareBtn.setImage(shareImage, for: .normal)
            buttonsView.saveBtn.setImage(unsaveImage, for: .normal)
               
            //-------------------------------------//
            
            
            headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"
            
            //checkIfLike()
            //totalLikeCount()
            //totalCmtCount()
            //shareCount()
            //getSaveCount()
            //checkIfSave()
            
            
            let avatarTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            avatarTap.numberOfTapsRequired = 1
          
            let usernameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            usernameTap.numberOfTapsRequired = 1
            headerView.usernameLbl.isUserInteractionEnabled = true
            headerView.usernameLbl.addGestureRecognizer(usernameTap)
            
            
            let username2Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            username2Tap.numberOfTapsRequired = 1
           

            let shareTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.shareTapped))
            shareTap.numberOfTapsRequired = 1
            buttonsView.shareBtn.addGestureRecognizer(shareTap)
            
            
            let likeTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeTapped))
            likeTap.numberOfTapsRequired = 1
            buttonsView.likeBtn.addGestureRecognizer(likeTap)
            
            let stitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.stitchTapped))
            stitchTap.numberOfTapsRequired = 1
            headerView.stichBtn.addGestureRecognizer(stitchTap)
            
            
            let saveTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.onClickSave))
            saveTap.numberOfTapsRequired = 1
            buttonsView.saveBtn.addGestureRecognizer(saveTap)
            
            
            let commentTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.cmtTapped))
            commentTap.numberOfTapsRequired = 1
            buttonsView.commentBtn.addGestureRecognizer(commentTap)
            
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeHandle))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
            
            doubleTap.delaysTouchesBegan = true
            
            
            let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ReelNode.settingTapped))
            longPress.minimumPressDuration = 0.65
            view.addGestureRecognizer(longPress)
            
            longPress.delaysTouchesBegan = true
            
            sideButtonsView = ButtonSideList()
            sideButtonsView.backgroundColor = .clear
            sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.sideButtonsView)
            originalCenter = self.view.center

            NSLayoutConstraint.activate([
               sideButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                sideButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
                sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
                sideButtonsView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])

            let viewStitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.viewStitchTapped))
            viewStitchTap.numberOfTapsRequired = 1
            sideButtonsView.viewStitchBtn.addGestureRecognizer(viewStitchTap)
            */
            
        }
       
        //automaticallyManagesSubnodes = true
    }
    
    
    @objc private func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        //guard let view = videoNode.view else { return }
    
        if recognizer.state == .began {
            disableSroll()
        }

        if recognizer.state == .changed {
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
          
            
            if post.muxPlaybackId != "" {
                let tempTransform = videoNode.view.transform.concatenating(scaleTransform)
                videoNode.view.transform = tempTransform
            }
            
        
            recognizer.scale = 1
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            
            if post.muxPlaybackId != "" {
                let tempTransform = videoNode.view.transform.concatenating(scaleTransform)
                
                UIView.animate(withDuration: 0.2, animations: {
                    if tempTransform.a < 1.0 {
                        self.videoNode.view.transform = CGAffineTransform.identity
                        //self.videoNode.view.center = self.originalCenter!
                    }
                        }, completion: { _ in
                            self.enableScroll()
                })
            }
  
        
        }
        
    }
    
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        //guard let view = recognizer.view else { return }

        if recognizer.state == .began {
            disableSroll()
           
        }

        if recognizer.state == .changed {
            
            if post.muxPlaybackId != "" {
                
                let translation = recognizer.translation(in: videoNode.view)
                videoNode.view.center = CGPoint(x: videoNode.view.center.x + translation.x, y: videoNode.view.center.y + translation.y)
                recognizer.setTranslation(.zero, in: videoNode.view)
                
            }
            
            
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
           
            UIView.animate(withDuration: 0.2, animations: {
                        
                    }, completion: { _ in
                        self.enableScroll()
                    })
            
        }
    }

    
    func getThumbnailURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=1"
            
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
    
    func mute() {
        self.videoNode.muted = true
    }
    
    func unmute() {
           self.videoNode.muted = false
    }
}


extension TestNode {

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
            let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
            let ratioSpec = ASRatioLayoutSpec(ratio:ratio, child:self.videoNode);
            let gradientOverlaySpec = ASOverlayLayoutSpec(child:ratioSpec, overlay:self.gradientNode)
            return gradientOverlaySpec
        }




    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
        let buttonsInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }

    private func setupSpace(constrainedSize: ASSizeRange) {
        delay(0.25) { [weak self] in
            guard let self = self else { return }
            if let buttonsView = self.buttonsView {
             
                let leftAndRightPadding: CGFloat = 16 * 2 // Padding for both sides
                let itemWidth: CGFloat = 60
                let numberOfItems: CGFloat = 4 // Number of items in the stack view
                let superViewWidth: CGFloat = constrainedSize.min.width // Assuming this is the superview's width
                
                // Calculate the total width of items
                let totalItemWidth: CGFloat = numberOfItems * itemWidth
                
                // Calculate the total space we have left for spacing after subtracting the item widths and paddings
                let totalSpacingWidth: CGFloat = superViewWidth - totalItemWidth - leftAndRightPadding
                
                // Calculate the spacing by dividing the total space by the number of spaces (which is 3, for 4 items)
                let spacing: CGFloat = totalSpacingWidth / (numberOfItems - 1)
                
                // Set the calculated spacing
                print(spacing)
                buttonsView.stackView.spacing = spacing
            }
        }
    }



}

extension TestNode: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || otherGestureRecognizer is UIPinchGestureRecognizer {
            return true
        }
        
        // Check for the collectionNode's panGestureRecognizer
        if let collectionNodePanGestureRecognizer = collectionNode?.view.panGestureRecognizer, otherGestureRecognizer == collectionNodePanGestureRecognizer {
            return true
        }
        
        if gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        
        return false
    }
    
    func disableSroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController || vc is SelectedPostVC {
                
                if let update1 = vc as? FeedViewController {
                    
                    update1.collectionNode.view.isScrollEnabled = false
                    
                } else if let update1 = vc as? SelectedPostVC {
                    
                    update1.collectionNode.view.isScrollEnabled = false
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func enableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController || vc is SelectedPostVC {
                
                if let update1 = vc as? FeedViewController {
                    
                    update1.collectionNode.view.isScrollEnabled = true
                    
                } else if let update1 = vc as? SelectedPostVC {
                    
                    update1.collectionNode.view.isScrollEnabled = true
                    
                }
                
            }
            
            
        }
        
    }
    
}


