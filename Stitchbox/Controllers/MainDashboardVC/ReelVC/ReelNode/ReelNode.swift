//
//  ReelNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/2/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class ReelNode: ASCellNode, ASVideoNodeDelegate {
    
    var previousTimeStamp: TimeInterval = 0.0
    var totalWatchedTime: TimeInterval = 0.0
    weak var collectionNode: ASCollectionNode?
    weak var post: PostModel!
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: RoundedCornerVideoNode
    var imageNode: RoundedCornerImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonNode: ASDisplayNode
    var hashtagsNode: ASDisplayNode
    var backgroundImage: GradientImageNode
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var hashtagView: HashtagView!
    var gradientNode: GradienView
    var time = 0
    var likeCount = 0
    var isLike = false
    var isSelectedPost = false
    var settingBtn : ((ASCellNode) -> Void)?
    var isViewed = false
    var currentTimeStamp: TimeInterval!
    var originalCenter: CGPoint?
 
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!

    //var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = RoundedCornerImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.hashtagsNode = ASDisplayNode()
        self.videoNode = RoundedCornerVideoNode()
        self.gradientNode = GradienView()
        self.backgroundImage = GradientImageNode()
        self.buttonNode = ASDisplayNode()
       
        super.init()
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false
        
        
        DispatchQueue.main.async {
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
            self.view.addGestureRecognizer(pinchGestureRecognizer)
            
            
            self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
            self.panGestureRecognizer.delegate = self
            self.panGestureRecognizer.minimumNumberOfTouches = 2
            self.view.addGestureRecognizer(self.panGestureRecognizer)
            
            self.headerView = PostHeader()
            self.headerNode.view.addSubview(self.headerView)

            self.headerView.translatesAutoresizingMaskIntoConstraints = false
            self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            


            self.buttonsView = ButtonsHeader()
            self.buttonNode.view.addSubview(self.buttonsView)
            self.buttonsView.translatesAutoresizingMaskIntoConstraints = false
            self.buttonsView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
            self.buttonsView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
            self.buttonsView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
            self.buttonsView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true

            self.buttonsView.likeBtn.setTitle("", for: .normal)
            self.buttonsView.commentBtn.setTitle("", for: .normal)
            self.buttonsView.commentBtn.setImage(cmtImage, for: .normal)
            self.buttonsView.shareBtn.setTitle("", for: .normal)
            
            
            self.hashtagView = HashtagView()
            self.hashtagsNode.view.addSubview(self.hashtagView)
            
            self.hashtagView.translatesAutoresizingMaskIntoConstraints = false
            self.hashtagView.topAnchor.constraint(equalTo: self.hashtagsNode.view.topAnchor, constant: 0).isActive = true
            self.hashtagView.bottomAnchor.constraint(equalTo: self.hashtagsNode.view.bottomAnchor, constant: 0).isActive = true
            self.hashtagView.leadingAnchor.constraint(equalTo: self.hashtagsNode.view.leadingAnchor, constant: 0).isActive = true
            self.hashtagView.trailingAnchor.constraint(equalTo: self.hashtagsNode.view.trailingAnchor, constant: 0).isActive = true

            
            let avatarTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            avatarTap.numberOfTapsRequired = 1
          
            let usernameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            usernameTap.numberOfTapsRequired = 1
            self.headerView.usernameLbl.isUserInteractionEnabled = true
            self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
            
            
            let username2Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            username2Tap.numberOfTapsRequired = 1
           

            let shareTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.shareTapped))
            shareTap.numberOfTapsRequired = 1
            self.buttonsView.shareBtn.addGestureRecognizer(shareTap)
            
            
            let likeTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeTapped))
            likeTap.numberOfTapsRequired = 1
            self.buttonsView.likeBtn.addGestureRecognizer(likeTap)
            
            let commentTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.cmtTapped))
            commentTap.numberOfTapsRequired = 1
            self.buttonsView.commentBtn.addGestureRecognizer(commentTap)
            
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeHandle))
            doubleTap.numberOfTapsRequired = 2
            self.view.addGestureRecognizer(doubleTap)
            
            doubleTap.delaysTouchesBegan = true
            
            
            let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ReelNode.settingTapped))
            longPress.minimumPressDuration = 0.65
            self.view.addGestureRecognizer(longPress)
            
            longPress.delaysTouchesBegan = true
            
            //-------------------------------------//
            
            
            self.headerView.usernameLbl.text = post.owner?.username ?? ""
            
            self.checkIfLike()
            self.totalLikeCount()
            self.totalCmtCount()
            
           
        }
       
        
        automaticallyManagesSubnodes = true
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        headerNode.backgroundColor = UIColor.clear
       
        
        self.contentNode.attributedText = NSAttributedString(string: post.content, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        
        if post.muxPlaybackId != "" {
            self.videoNode.url = self.getThumbnailBackgroundVideoNodeURL(post: post)
            self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
            self.videoNode.shouldAutoplay = false
            self.videoNode.shouldAutorepeat = true
            
            self.videoNode.muted = false
            self.videoNode.delegate = self
            
            
            if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
                let aspectRatio = Float(width) / Float(height)
             
                // Set contentMode based on aspect ratio
                if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                    self.videoNode.contentMode = .scaleAspectFill
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                    self.videoNode.contentMode = .scaleAspectFit
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                    self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                } else {
                    // Default contentMode, adjust as needed
                    self.videoNode.contentMode = .scaleAspectFit
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                    self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                }
            } else {
                // Default contentMode, adjust as needed
                self.videoNode.contentMode = .scaleAspectFit
                self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
            }

            
            DispatchQueue.main.async {
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
            }
            
            
            
        } else {
            
            if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
                let aspectRatio = Float(width) / Float(height)

                // Set contentMode based on aspect ratio
                if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                    self.imageNode.contentMode = .scaleAspectFill
                } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                    self.imageNode.contentMode = .scaleAspectFit
                    self.backgroundImage.setGradientImage(with: post.imageUrl)
                } else {
                    // Default contentMode, adjust as needed
                    self.imageNode.contentMode = .scaleAspectFit
                    self.backgroundImage.setGradientImage(with: post.imageUrl)
                }
            } else {
                // Default contentMode, adjust as needed
                self.imageNode.contentMode = .scaleAspectFit
                self.backgroundImage.setGradientImage(with: post.imageUrl)
            }
            
            Dispatch.main.async {
                
                self.imageNode.view.isUserInteractionEnabled = true

            }
            
        
            imageStorage.async.object(forKey: post.imageUrl.absoluteString) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async {
                        self.imageNode.image = image
                    }
                   
                    
                } else {
                    
                    AF.request(post.imageUrl).responseImage { response in
                                          
                       switch response.result {
                        case let .success(value):
                           self.imageNode.image = value
                           try? imageStorage.setObject(value, forKey: post.imageUrl.absoluteString, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                              
                               case let .failure(error):
                                   print(error)
                            }
                                          
                      }
                    
                }
            }
            
        }
  
    }
    
    
    @objc private func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        //guard let view = videoNode.view else { return }
    
        if recognizer.state == .began {
            disableScroll()
        }

        if recognizer.state == .changed {
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
          
            
            if post.muxPlaybackId != "" {
                let tempTransform = videoNode.view.transform.concatenating(scaleTransform)
                videoNode.view.transform = tempTransform
            } else {
                let tempTransform = imageNode.view.transform.concatenating(scaleTransform)
                imageNode.view.transform = tempTransform
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
            } else {
                let tempTransform = imageNode.view.transform.concatenating(scaleTransform)
                
                UIView.animate(withDuration: 0.2, animations: {
                    if tempTransform.a < 1.0 {
                        self.imageNode.view.transform = CGAffineTransform.identity
                        //self.imageNode.view.center = self.originalCenter!
                    }
                        }, completion: { _ in
                            self.enableScroll()
                })
            }
  
        
        }
    }


    func walkthroughPanAndZoom() {
        // Store original center for later use
        let originalCenter = videoNode.view.center
        
        // Disable scrolling during walkthrough
        disableScroll()

        // Simulate pan by translating center
        let simulatedTranslation = CGPoint(x: 30, y: 30)
        videoNode.view.center = CGPoint(x: videoNode.view.center.x + simulatedTranslation.x, y: videoNode.view.center.y + simulatedTranslation.y)
        
        // Animate zoom in and pan back to original center with spring effect
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            self.videoNode.view.transform = CGAffineTransform(scaleX: 1.6, y: 1.6) // Increased zoom
            self.videoNode.view.center = originalCenter
        }) { _ in
            // Animate zoom out with spring effect
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
                self.videoNode.view.transform = CGAffineTransform.identity
            }) { _ in
                // Re-enable scrolling once walkthrough is complete
                self.enableScroll()
            }
        }
    }




    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        //guard let view = recognizer.view else { return }

        if recognizer.state == .began {
            disableScroll()
           
        }

        if recognizer.state == .changed {
            
            if post.muxPlaybackId != "" {
                
                let translation = recognizer.translation(in: videoNode.view)
                videoNode.view.center = CGPoint(x: videoNode.view.center.x + translation.x, y: videoNode.view.center.y + translation.y)
                recognizer.setTranslation(.zero, in: videoNode.view)
                
            } else {
                
                let translation = recognizer.translation(in: imageNode.view)
                imageNode.view.center = CGPoint(x: imageNode.view.center.x + translation.x, y: imageNode.view.center.y + translation.y)
                recognizer.setTranslation(.zero, in: imageNode.view)
                
            }
            
            
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
           
            UIView.animate(withDuration: 0.2, animations: {
                        
                    }, completion: { _ in
                        self.enableScroll()
                    })
            
        }
    }


    
    
    func getThumbnailBackgroundVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=0.025"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }

    func getThumbnailVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=1"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }
    
    func getVideoURLForRedundant_stream(post: PostModel) -> URL? {
        
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }

       
    }
    
    func setVideoProgress(rate: Float, currentTime: TimeInterval, maxDuration: CMTime) {
        
        
        if let vc = UIViewController.currentViewController() {
            
            
            if let update1 = vc as? FeedViewController {
                
                if update1.playTimeBar != nil {
                    update1.playTimeBar.maximumValue = Float(CMTimeGetSeconds(maxDuration))
                    update1.playTimeBar.setValue(Float(currentTime), animated: true)
                }
                
            } else if let update1 = vc as? SelectedPostVC {
                
                if update1.playTimeBar != nil {
                    update1.playTimeBar.maximumValue = Float(CMTimeGetSeconds(maxDuration))
                    update1.playTimeBar.setValue(Float(currentTime), animated: true)
                }
                
            }
            
        }
        
        
        
    }
    

}

extension ReelNode {
    
    func didTap(_ videoNode: ASVideoNode) {
        soundProcess()
    }
    
    
    @objc func soundProcess() {
        
        if videoNode.muted == true {
            videoNode.muted = false
            shouldMute = false
            animateUnmute()
    
        } else {
            videoNode.muted = true
            shouldMute = true
            animateMute()
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
        
        // Optionally, add another condition to check if user is actively engaging with the video
        // if shouldCountView && userIsEngagingWithVideo {
        //     endVideo(watchTime: Double(totalWatchedTime))
        // }
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
            
                APIManager.shared.createView(post: post.id, watchTime: watchTime) { [weak self] result in
                    guard let self = self else { return }
                    
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
    
    func endImage(id: String) {
        
        if _AppCoreData.userDataSource.value != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
            
                APIManager.shared.createView(post: id, watchTime: 0) { [weak self] result in
                    guard let self = self else { return }
                    
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
    
    
    @objc func zoomAnimation() {
        
        let imgView = UIImageView()
        imgView.frame.size = CGSize(width: 170, height: 120)
        
        imgView.center = self.view.center
        self.view.addSubview(imgView)
        
        let tapImages: [UIImage] = [
            UIImage(named: "zoom1")!,
            UIImage(named: "zoom2")!,
            UIImage(named: "zoom3")!
        ]
        
        imgView.animationImages = tapImages
        imgView.animationDuration = 1.5 // time duration for complete animation cycle
        imgView.animationRepeatCount = 1 // number of times the animation repeats, set to 1 to play once
        imgView.startAnimating()
        
        // Optional: clear images after animation ends
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            imgView.animationImages = nil
            imgView.removeFromSuperview()
        }
        
    }
    
}


extension ReelNode {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        hashtagView.collectionView.delegate = dataSourceDelegate
        hashtagView.collectionView.dataSource = dataSourceDelegate
        hashtagView.collectionView.tag = row

        // Retrieve the current contentOffset
        let contentOffset = hashtagView.collectionView.contentOffset

        // Check if the contentSize is greater than the collectionView's frame size
        if hashtagView.collectionView.contentSize.height > hashtagView.collectionView.frame.size.height {
            // Check whether the desired contentOffset.y is within valid range
            if contentOffset.y >= 0 && contentOffset.y <= hashtagView.collectionView.contentSize.height - hashtagView.collectionView.frame.size.height {
                // If yes, stop the collectionView if it was scrolling
                hashtagView.collectionView.setContentOffset(contentOffset, animated:true)
            } else {
                print("Invalid content offset: \(contentOffset.y). It should be between 0 and \(hashtagView.collectionView.contentSize.height - hashtagView.collectionView.frame.size.height).")
                // You can replace this with your own error handling code
            }
        }

        hashtagView.collectionView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
        hashtagView.collectionView.reloadData()
        
    }

}


extension ReelNode {
    
    
    @objc func userTapped() {
        
        if let userId = post.owner?.id, let username = post.owner?.username, userId != "", username != "" {
            
            if userId != _AppCoreData.userDataSource.value?.userID  {
                
                if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                    
                    if let vc = UIViewController.currentViewController() {
                        
                        let nav = UINavigationController(rootViewController: UPVC)

                        // Set the user ID, nickname, and onPresent properties of UPVC
                        UPVC.userId = userId
                        UPVC.nickname = username
                        UPVC.onPresent = true

                        // Customize the navigation bar appearance
                        nav.navigationBar.barTintColor = .background
                        nav.navigationBar.tintColor = .white
                        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                        nav.modalPresentationStyle = .fullScreen
                        vc.present(nav, animated: true, completion: nil)

               
                    }
                }
                
            }
            
            
        }
 
        
    }
    
    @objc func shareTapped() {
        
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        let loadUsername = userDataSource.userName
        
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        
        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                
                update1.present(ac, animated: true, completion: nil)
                
            } else if let update1 = vc as? SelectedPostVC {
                
                update1.present(ac, animated: true, completion: nil)
                
            } else if let update1 = vc as? PostListWithHashtagVC {
                
                update1.present(ac, animated: true, completion: nil)
                
            }
            
            
        }
        
        
    }
    
    
    @objc func cmtTapped() {
        
        
        if let vc = UIViewController.currentViewController() {
            
            general_vc = vc
            
            let slideVC = CommentVC()
            
            slideVC.post = self.post
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = vc.self
            global_presetingRate = Double(0.75)
            global_cornerRadius = 35
            vc.present(slideVC, animated: true, completion: nil)
            
        }
        
    }
    
    @objc func likeTapped() {
        
        if isLike == false {
            performLike()
        } else {
            performUnLike()
        }
         
    }
    
    
    @objc func settingTapped() {
        
        settingBtn?(self)
        
    }
    
    @objc func likeHandle() {
        
        
        let imgView = UIImageView()
        imgView.image = popupLikeImage
        imgView.frame.size = CGSize(width: 120, height: 120)
        imgView.contentMode = .scaleAspectFit
        imgView.center = self.view.center
        self.view.addSubview(imgView)
        
        
        self.fireworkController.addFirework(sparks: 10, above: imgView)
        self.fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
        
        imgView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.5) {
            
            imgView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            if imgView.alpha == 0 {
                
                imgView.removeFromSuperview()
                
            }
            
        }
        
        if isLike == false {
            performLike()
        }
        
    }
    
    func animateMute() {
        let imgView = UIImageView(image: muteImage)
        imgView.frame.size = CGSize(width: 45, height: 45)
        imgView.center = self.view.center
        self.view.addSubview(imgView)

        UIView.animate(withDuration: 0.5, animations: {
            imgView.alpha = 0
            imgView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            imgView.removeFromSuperview()
        }
    }

    func animateUnmute() {
        let imgView = UIImageView(image: unmuteImage)
        imgView.frame.size = CGSize(width: 45, height: 45)

        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                                
                imgView.center = update1.view.center
                update1.view.addSubview(imgView)
                                
            } else if let update1 = vc as? SelectedPostVC {
                                
                imgView.center = update1.view.center
                update1.view.addSubview(imgView)
                                
            } else if let update1 = vc as? PostListWithHashtagVC {
                                
                imgView.center = update1.view.center
                update1.view.addSubview(imgView)
                                
            }
            
            
           
        }

        UIView.animate(withDuration: 0.5, animations: {
            imgView.alpha = 0
            imgView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            imgView.removeFromSuperview()
        }
    }


    
    func checkIfLike() {
        
        APIManager.shared.hasLikedPost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let checkIsLike = apiResponse.body?["islike"] as? Bool  else {
                        return
                }
                
                self.isLike = checkIsLike
                if self.isLike {
                    DispatchQueue.main.async {
                        self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        
        }
    }
    
    func performLike() {

        self.likeCount += 1
        DispatchQueue.main.async {
            self.likeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = true
        }
        
        APIManager.shared.likePost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
               print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func performUnLike() {
        
        
        self.likeCount -= 1
        DispatchQueue.main.async {
            self.unlikeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = false
        }
        
        APIManager.shared.unlikePost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func likeAnimation() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = self.buttonsView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
            
            
            
            
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func unlikeAnimation() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = self.buttonsView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
        })
    }

}

extension ReelNode {
    
    func totalLikeCountFromLocal() {
        
        DispatchQueue.main.async {
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.post.estimatedCount?.sizeLikes ?? 0)))"
        }
        
    }
    
    func totalCmtCountFromLocal() {
        
        DispatchQueue.main.async {
            self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(self.post.estimatedCount?.sizeComments ?? 0)))"
        }
        
    }
    
    func totalLikeCount() {
        
        APIManager.shared.countLikedPost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let likeCountFromQuery = apiResponse.body?["likes"] as? Int  else {
                        return
                }
                
                self.likeCount = likeCountFromQuery
                
                DispatchQueue.main.async {
                    self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(likeCountFromQuery)))"
                }
               
            case .failure(let error):
                print("LikeCount: \(error)")
            }
        }
        
    }
    
    func totalCmtCount() {
        
        APIManager.shared.countComment(post: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
             
                guard apiResponse.body?["message"] as? String == "success",
                      let commentsCountFromQuery = apiResponse.body?["comments"] as? Int  else {
                        return
                }
                
                DispatchQueue.main.async {
                    self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(commentsCountFromQuery)))"
                }
                
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
        
    }
    
}

extension ReelNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
         
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 70)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1

        let headerInset = UIEdgeInsets(top: 0, left: 4, bottom: 2, right: 8)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)

        hashtagsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 35)
        let hashtagsInset = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        let hashtagsInsetSpec = ASInsetLayoutSpec(insets: hashtagsInset, child: hashtagsNode)
        
        let contentInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 170)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
        let verticalStack = ASStackLayoutSpec.vertical()
        

        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)
        
        verticalStack.children = [headerInsetSpec]
        
        if post.content != "" {
            verticalStack.children?.append(contentInsetSpec)
        }
        
        verticalStack.children?.append(contentsOf: [hashtagsInsetSpec])
        verticalStack.children?.append(buttonsInsetSpec)

                
        let verticalStackInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)

        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let imageInsetSpec = ASInsetLayoutSpec(insets: inset, child: imageNode)
        let textInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)
        let textInsetSpec1 = ASInsetLayoutSpec(insets: inset, child: gradientNode)
        let textInsetSpec2 = ASInsetLayoutSpec(insets: inset, child: backgroundImage)
     
        let roundedCornerNode = RoundedCornerNode()

        if post.muxPlaybackId != "" {
            let textInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)
            
            let backgroundSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: roundedCornerNode)
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: backgroundSpec)

            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        } else {
            let imageInsetSpec = ASInsetLayoutSpec(insets: inset, child: imageNode)
            
            let backgroundSpec = ASBackgroundLayoutSpec(child: imageInsetSpec, background: roundedCornerNode)
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: backgroundSpec)
            
            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        }
    }

    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
        let buttonsInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }
}


extension ReelNode {
    
    func disableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            

            if let update1 = vc as? FeedViewController {
                            
                update1.collectionNode.view.isScrollEnabled = false
                            
                        } else if let update1 = vc as? SelectedPostVC {
                            
                            update1.collectionNode.view.isScrollEnabled = false
                            
                        } else if let update1 = vc as? PostListWithHashtagVC {
                            
                            update1.collectionNode.view.isScrollEnabled = false
                            
                        }
            
            
        }
        
        
    }
    
    func enableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                            
                update1.collectionNode.view.isScrollEnabled = true
                            
                        } else if let update1 = vc as? SelectedPostVC {
                            
                            update1.collectionNode.view.isScrollEnabled = true
                            
                        } else if let update1 = vc as? PostListWithHashtagVC {
                            
                            update1.collectionNode.view.isScrollEnabled = true
                            
                        }
            
            
        }
        
    }
    
}

extension ReelNode: UIGestureRecognizerDelegate {
    
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


class RoundedCornerNode: ASDisplayNode {
    override func didLoad() {
        super.didLoad()
        self.clipsToBounds = true
        self.cornerRadius = 25
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
    }
}

class RoundedCornerImageNode: ASNetworkImageNode {
    override func didLoad() {
        super.didLoad()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
        view.clipsToBounds = true
    }
}

class RoundedCornerVideoNode: ASVideoNode {
    override func didLoad() {
        super.didLoad()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
        view.clipsToBounds = true
    }
}
