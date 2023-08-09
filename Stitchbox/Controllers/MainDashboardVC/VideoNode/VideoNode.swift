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


class VideoNode: ASCellNode, ASVideoNodeDelegate {
    
    deinit {
        print("VideoNode is being deallocated.")
    }
    
    var post: PostModel
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var totalWatchedTime: TimeInterval = 0.0
    var previousTimeStamp: TimeInterval = 0.0
    var videoNode: ASVideoNode
    var gradientNode: GradienView
    var time = 0
    var shouldCountView = true
    var isViewed = false
    var isOriginal = false
    //------------------------------------------//

    var isFirstItem = false
    var collectionNode: ASCollectionNode?
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    init(with post: PostModel, at: Int) {
        print("VideoNode \(at) is loading post: \(post.id)")
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
    
        DispatchQueue.main.async() { [weak self]  in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
            if self.isFirstItem {
                if let muteStatus = shouldMute {
                    
                    
                    if muteStatus {
                        self.videoNode.muted = true
                    } else {
                        self.videoNode.muted = false
                    }
                    
                    self.videoNode.play()
                    
                } else {
                    
                    if globalIsSound {
                        self.videoNode.muted = false
                    } else {
                        self.videoNode.muted = true
                    }
                    
                    self.videoNode.play()
                    
                }
            }
        }
        
        self.addSubnode(self.videoNode)
        self.addSubnode(self.gradientNode)
        
        self.gradientNode.isHidden = true
        self.videoNode.delegate = self
        
        
    }

    override func didLoad() {
        super.didLoad()
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
                    
                    
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.minimumNumberOfTouches = 2
        view.addGestureRecognizer(panGestureRecognizer)
        
        
    }
    
    func getThumbnailURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.jpg?time=0"
            
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


extension VideoNode {

  
    func didTap(_ videoNode: ASVideoNode) {
        
       
        if let vc = UIViewController.currentViewController() {
            if vc is PreviewVC {
                
                if videoNode.isPlaying() {
                    videoNode.pause()
                } else {
                    videoNode.play()
                }
                
            } else {
                //soundBtn?(self)
            }
        }
        
        
    }


    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        
        let videoDuration = videoNode.currentItem?.duration.seconds ?? 0

        // Compute the time the user has spent actually watching the video
        if timeInterval >= previousTimeStamp {
            totalWatchedTime += timeInterval - previousTimeStamp
        }
        previousTimeStamp = timeInterval

        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.duration.seconds)!), currentTime: timeInterval, maxDuration: videoNode.currentItem!.duration)

        let watchedPercentage = totalWatchedTime/videoDuration
        let minimumWatchedPercentage: Double

        // Setting different thresholds based on video length
        switch videoDuration {
        case 0..<15:
            minimumWatchedPercentage = 0.8
        case 15..<30:
            minimumWatchedPercentage = 0.7
        case 30..<60:
            minimumWatchedPercentage = 0.6
        case 60..<90:
            minimumWatchedPercentage = 0.5
        case 90..<120:
            minimumWatchedPercentage = 0.4
        default:
            minimumWatchedPercentage = 0.5
        }
        
        // Check if user has watched a certain minimum amount of time (e.g. 5 seconds)
        let minimumWatchedTime = 5.0
        if shouldCountView && totalWatchedTime >= minimumWatchedTime && watchedPercentage >= minimumWatchedPercentage {
            shouldCountView = false
            endVideo(watchTime: Double(totalWatchedTime))
        }
     
    }
    
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
    
        shouldCountView = true
       
        
    }
    
    @objc func endVideo(watchTime: Double) {
        
        if _AppCoreData.userDataSource.value != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
            
                APIManager.shared.createView(post: post.id, watchTime: watchTime) { result in
                    
                    switch result {
                    case .success(let apiResponse):
            
                        print(apiResponse)
                        
                    case .failure(let error):
                        print(error)
                    }
                
                }
                
            }
            
        }
        
        
    }


    func setVideoProgress(rate: Float, currentTime: TimeInterval, maxDuration: CMTime) {
        if let vc = UIViewController.currentViewController() {
            if let update1 = vc as? ParentViewController {
                
                if update1.isFeed {
                    updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.feedViewController.playTimeBar)
                } else {
                    updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.stitchViewController.playTimeBar)
                }
                
            } else if let update1 = vc as? SelectedPostVC {
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
            } else if let update1 = vc as? PreviewVC {
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
            }
        }
    }
    
    func updateSlider(currentTime: TimeInterval, maxDuration: CMTime, playTimeBar: UISlider?) {
        guard let playTimeBar = playTimeBar else { return }

        let maxDurationSeconds = CMTimeGetSeconds(maxDuration)

        // Check if maxDurationSeconds is not NaN and more than 0
        if maxDurationSeconds.isNaN || maxDurationSeconds <= 0 {
            print("Invalid maxDurationSeconds: \(maxDurationSeconds)")
            return
        }

        playTimeBar.maximumValue = Float(maxDurationSeconds)
        playTimeBar.setValue(Float(currentTime), animated: true)
    }
    
}

extension VideoNode {
    
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
    
    func disableSroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is ParentViewController || vc is SelectedPostVC {
                
                if let update1 = vc as? ParentViewController {
                    
                    if update1.isFeed {
                        update1.feedViewController.collectionNode.view.isScrollEnabled = false
                    } else {
                        update1.stitchViewController.collectionNode.view.isScrollEnabled = false
                    }
                    
                } else if let update1 = vc as? SelectedPostVC {
                    
                    update1.collectionNode.view.isScrollEnabled = false
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func enableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is ParentViewController || vc is SelectedPostVC {
                
                if let update1 = vc as? ParentViewController {
                    
                    if update1.isFeed {
                        update1.feedViewController.collectionNode.view.isScrollEnabled = true
                    } else {
                        update1.stitchViewController.collectionNode.view.isScrollEnabled = true
                    }
                    
                } else if let update1 = vc as? SelectedPostVC {
                    
                    update1.collectionNode.view.isScrollEnabled = true
                    
                }
                
            }
            
            
        }
        
    }

    
}


extension VideoNode: UIGestureRecognizerDelegate {
    
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
    
    
}
