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
    
    weak var post: PostModel!
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: ASVideoNode
    var imageNode: ASImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var hashtagsNode: ASDisplayNode
    var backgroundImage: GradientImageNode
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonSideList!
    var hashtagView: HashtagView!
    var gradientNode: GradienView
    var time = 0
    var likeCount = 0
    var isLike = false
    var isSelectedPost = false
    var settingBtn : ((ASCellNode) -> Void)?
    var isViewed = false
    var currentTimeStamp: TimeInterval!
    private var originalVideoTransform: CGAffineTransform = .identity
   
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        //self.scrollView = UIScrollView()
        self.hashtagsNode = ASDisplayNode()
        self.videoNode = ASVideoNode()
        self.gradientNode = GradienView()
        self.backgroundImage = GradientImageNode()
        super.init()
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false
        
        
        DispatchQueue.main.async {
            
            self.headerView = PostHeader()
            self.headerNode.view.addSubview(self.headerView)
            self.headerView.settingBtn.setTitle("", for: .normal)
            self.headerView.translatesAutoresizingMaskIntoConstraints = false
            self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            
            self.headerView.settingBtn.isHidden = true

            
            if self.isSelectedPost == false {
                
                if post.owner?.id == _AppCoreData.userDataSource.value?.userID {
                    
                    self.headerView.settingBtn.isHidden = true
                    
                }
                
            }
            
            self.buttonsView = ButtonSideList()
            self.buttonsView.likeBtn.setTitle("", for: .normal)
            self.buttonsView.commentBtn.setTitle("", for: .normal)
            self.buttonsView.shareBtn.setTitle("", for: .normal)
            self.buttonsView.streamlinkBtn.setTitle("", for: .normal)
            self.buttonsView.soundBtn.setTitle("", for: .normal)
            
            self.hashtagView = HashtagView()
            self.hashtagsNode.view.addSubview(self.hashtagView)
            
            self.hashtagView.translatesAutoresizingMaskIntoConstraints = false
            self.hashtagView.topAnchor.constraint(equalTo: self.hashtagsNode.view.topAnchor, constant: 0).isActive = true
            self.hashtagView.bottomAnchor.constraint(equalTo: self.hashtagsNode.view.bottomAnchor, constant: 0).isActive = true
            self.hashtagView.leadingAnchor.constraint(equalTo: self.hashtagsNode.view.leadingAnchor, constant: 0).isActive = true
            self.hashtagView.trailingAnchor.constraint(equalTo: self.hashtagsNode.view.trailingAnchor, constant: 0).isActive = true
              
            if post.muxPlaybackId != "" {
                
               
                self.buttonsView.soundBtn.setTitle("", for: .normal)
                
               
                
                if let muteStatus = shouldMute {
                    
                    if muteStatus {
                        self.buttonsView.soundBtn.setImage(muteImage, for: .normal)
                    } else {
                        self.buttonsView.soundBtn.setImage(unmuteImage, for: .normal)
                    }
                    
                } else {
                    
                    if globalIsSound {
                        self.buttonsView.soundBtn.setImage(unmuteImage, for: .normal)
                    } else {
                        self.buttonsView.soundBtn.setImage(muteImage, for: .normal)
                    }
                    
                    
                }
              
           
                let soundTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.soundProcess))
                soundTap.numberOfTapsRequired = 1
                self.buttonsView.soundBtn.addGestureRecognizer(soundTap)

            }
            
            let avatarTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            avatarTap.numberOfTapsRequired = 1
            self.headerView.avatarImage.isUserInteractionEnabled = true
            self.headerView.avatarImage.addGestureRecognizer(avatarTap)
            
            let usernameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            usernameTap.numberOfTapsRequired = 1
            self.headerView.usernameLbl.isUserInteractionEnabled = true
            self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
            
            
            let username2Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.userTapped))
            username2Tap.numberOfTapsRequired = 1
            self.headerView.timeLbl.isUserInteractionEnabled = true
            self.headerView.timeLbl.addGestureRecognizer(username2Tap)
            

            let shareTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.shareTapped))
            shareTap.numberOfTapsRequired = 1
            self.buttonsView.shareBtn.addGestureRecognizer(shareTap)
            
            
            let likeTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeTapped))
            likeTap.numberOfTapsRequired = 1
            self.buttonsView.likeBtn.addGestureRecognizer(likeTap)
            
            let commentTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.cmtTapped))
            commentTap.numberOfTapsRequired = 1
            self.buttonsView.commentBtn.addGestureRecognizer(commentTap)
            
            
            let settingTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.settingTapped))
            settingTap.numberOfTapsRequired = 1
            self.headerView.settingBtn.addGestureRecognizer(settingTap)
            
            
            let streamLinkTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.streamingLinkTapped))
            streamLinkTap.numberOfTapsRequired = 1
            self.buttonsView.streamlinkBtn.addGestureRecognizer(streamLinkTap)
            
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.likeHandle))
            doubleTap.numberOfTapsRequired = 2
            self.view.addGestureRecognizer(doubleTap)
            
            doubleTap.delaysTouchesBegan = true
            
            
            let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ReelNode.settingTapped))
            longPress.minimumPressDuration = 0.5
            self.view.addGestureRecognizer(longPress)
            
            longPress.delaysTouchesBegan = true
            
            //-------------------------------------//
            
            
            self.headerView.usernameLbl.text = post.owner?.username ?? ""
            
            if let url = post.owner?.avatar, url != "" {
                
                self.headerView.avatarImage.load(url: URL(string: url)!, str: url)
                
            }
            
        
            //-------------------------------------//
            
            if let time = post.createdAt {
                
                self.headerView.timeLbl.text = timeAgoSinceDate(time, numericDates: true)
                
            } else {
                self.headerView.timeLbl.text = ""
            }
            
            
            
            if let url = URL(string: post.streamLink), !post.streamLink.isEmpty {
                if let domain = url.host {
                    if check_Url(host: domain) {
                        self.buttonsView.hostLbl.text = "  \(domain)  "
                    } else {
                        self.buttonsView.hostLbl.text = "  \("stitchbox.gg")  "
                    }
                } else {
                    self.buttonsView.hostLbl.text = "  \("stitchbox.gg")  "
                }
            } else {
                self.buttonsView.hostLbl.text = "  \("stitchbox.gg")  "
            }

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
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
            self.videoNode.muted = false
            self.videoNode.delegate = self
            
            
            if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
                let aspectRatio = Float(width) / Float(height)

                // Set contentMode based on aspect ratio
                if aspectRatio >= 0.5 && aspectRatio <= 0.6 { // Close to 9:16 aspect ratio (vertical)
                    self.videoNode.contentMode = .scaleAspectFill
                } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                    self.videoNode.contentMode = .scaleAspectFit
                    self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                } else {
                    // Default contentMode, adjust as needed
                    self.videoNode.contentMode = .scaleAspectFit
                    self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                }
            } else {
                // Default contentMode, adjust as needed
                self.videoNode.contentMode = .scaleAspectFit
                self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
            }

            
            DispatchQueue.main.async {
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
                
                let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
                self.videoNode.view.addGestureRecognizer(pinchGestureRecognizer)

                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
                panGestureRecognizer.delegate = self
                panGestureRecognizer.minimumNumberOfTouches = 2
                self.videoNode.view.addGestureRecognizer(panGestureRecognizer)
              
            }
            
            
            
        } else {
            
            if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
                let aspectRatio = Float(width) / Float(height)

                // Set contentMode based on aspect ratio
                if aspectRatio >= 0.5 && aspectRatio <= 0.6 { // Close to 9:16 aspect ratio (vertical)
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
                let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
                self.imageNode.view.addGestureRecognizer(pinchGestureRecognizer)

                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
                panGestureRecognizer.delegate = self
                panGestureRecognizer.minimumNumberOfTouches = 2
                self.imageNode.view.addGestureRecognizer(panGestureRecognizer)
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
        
        DispatchQueue.main.async() {
            self.buttonsView.frame = CGRect(origin: CGPoint(x:UIScreen.main.bounds.width - 155, y: 0), size: CGSize(width: 150, height: UIScreen.main.bounds.height))
            self.view.addSubview(self.buttonsView)
        }
  
    }
    
    
    @objc private func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard let view = recognizer.view else { return }

        if recognizer.state == .began {
            disableSroll()
            originalVideoTransform = view.transform
        
        }

        if recognizer.state == .changed {
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            view.transform = view.transform.concatenating(scaleTransform)
            recognizer.scale = 1
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform.identity
            })
        }
    }

    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }

        if recognizer.state == .began {
            originalVideoTransform = view.transform
        }

        if recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
            view.transform = view.transform.concatenating(translationTransform)
            recognizer.setTranslation(.zero, in: view)
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            UIView.animate(withDuration: 0.2, animations: {
                        view.transform = CGAffineTransform.identity
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
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8?redundant_streams=true"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }

       
    }
    
    func setVideoProgress(rate: Float) {
        
        
        if let vc = UIViewController.currentViewController() {
            
            
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    if update1.playTimeBar != nil {
                        update1.playTimeBar.setProgress(rate, animated: true)
                    }
                    
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
        
        if videoNode.isPlaying() {
            
            if videoNode.muted == true {
                videoNode.muted = false
                shouldMute = false
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonsView.soundBtn.transform = self.buttonsView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                    self.buttonsView.soundBtn.setImage(unmuteImage, for: .normal)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                          self.buttonsView.soundBtn.transform = CGAffineTransform.identity
                      })
                    })
        
            } else {
                videoNode.muted = true
                shouldMute = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonsView.soundBtn.transform = self.buttonsView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                    self.buttonsView.soundBtn.setImage(muteImage, for: .normal)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                          self.buttonsView.soundBtn.transform = CGAffineTransform.identity
                      })
                    })
            }
            
        }
        
    }
    
    
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        
        currentTimeStamp = timeInterval
        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.asset.duration.seconds)!))
    
        
        if (videoNode.currentItem?.asset.duration.seconds)! <= 15 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.8 {
                
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
               
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 15, (videoNode.currentItem?.asset.duration.seconds)! <= 30 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.7 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 30, (videoNode.currentItem?.asset.duration.seconds)! <= 60 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.6 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 60 , (videoNode.currentItem?.asset.duration.seconds)! <= 90 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 90, (videoNode.currentItem?.asset.duration.seconds)! <= 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.4 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
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
            
                APIManager().createView(post: post.id, watchTime: watchTime) { result in
                    
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
            
                APIManager().createView(post: id, watchTime: 0) { result in
                    
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
    
}


extension ReelNode {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
    
        hashtagView.collectionView.delegate = dataSourceDelegate
        hashtagView.collectionView.dataSource = dataSourceDelegate
        hashtagView.collectionView.tag = row
        hashtagView.collectionView.setContentOffset(hashtagView.collectionView.contentOffset, animated:true) // Stops collection view if it was scrolling.
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
            
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    update1.present(ac, animated: true, completion: nil)
                    
                }
                
            }
            
            
        }
        
        
    }
    
    
    @objc func cmtTapped() {
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    let slideVC = CommentVC()
                    
                    slideVC.post = self.post
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    update1.present(slideVC, animated: true, completion: nil)
                    
                }
                
            }
            
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
    
    @objc func profileTapped() {
        
        print("profileTapped")
        
    }
    
    @objc func streamingLinkTapped() {
        guard let url = URL(string: post.streamLink), !post.streamLink.isEmpty else {
            presentStreamingIntro()
            return
            
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }


    @objc func likeHandle() {
        
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "likePopUp")
        imgView.frame.size = CGSize(width: 120, height: 120)
       
        if let vc = UIViewController.currentViewController() {
             
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    imgView.center = update1.view.center
                    update1.view.addSubview(imgView)
                    
                }
                
            }
                        
                        
                        
                   
        }
        
        
        imgView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 1) {
            
            imgView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if imgView.alpha == 0 {
                
                imgView.removeFromSuperview()
                
            }
            
        }
        
        if isLike == false {
            performLike()
        }
        
    }
    
    func checkIfLike() {
        
        APIManager().hasLikedPost(id: post.id) { result in
            
            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let checkIsLike = apiResponse.body?["islike"] as? Bool  else {
                        return
                }
                
                self.isLike = checkIsLike
                if self.isLike {
                    DispatchQueue.main.async {
                        self.buttonsView.likeBtn.setImage(UIImage(named: "liked")?.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.buttonsView.likeBtn.setImage(UIImage(named: "likeEmpty")?.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
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
        
        APIManager().likePost(id: post.id) { result in
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
        
        APIManager().unlikePost(id: post.id) { result in
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
            self.buttonsView.likeBtn.setImage(UIImage(named: "liked")?.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
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
            self.buttonsView.likeBtn.setImage(UIImage(named: "likeEmpty")?.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
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
        
        APIManager().countLikedPost(id: post.id) { result in
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
        
        APIManager().countComment(post: post.id) { result in
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


extension ReelNode
{

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1

        let headerInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)

        let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 200)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)

        hashtagsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 30)
        let hashtagsInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        let hashtagsInsetSpec = ASInsetLayoutSpec(insets: hashtagsInset, child: hashtagsNode)

        let verticalStack = ASStackLayoutSpec.vertical()
        
        verticalStack.children = [headerInsetSpec]
        
        if post.content != "" {
            verticalStack.children?.append(contentInsetSpec)
        }
        
        verticalStack.children?.append(contentsOf: [hashtagsInsetSpec])

        let verticalStackInset = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)

        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let imageInsetSpec = ASInsetLayoutSpec(insets: inset, child: imageNode)
        let textInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)
        let textInsetSpec1 = ASInsetLayoutSpec(insets: inset, child: gradientNode)
        let textInsetSpec2 = ASInsetLayoutSpec(insets: inset, child: backgroundImage)
       
        if post.muxPlaybackId != "" {
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: textInsetSpec)
            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        } else {
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: imageInsetSpec)
            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        }
        
    }
    
}


// Add a UIGestureRecognizerDelegate extension to allow simultaneous recognition
extension ReelNode: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ReelNode {
    
    func disableSroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    update1.collectionNode.view.isScrollEnabled = false
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func enableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is ReelVC {
                
                if let update1 = vc as? ReelVC {
                    
                    update1.collectionNode.view.isScrollEnabled = true
                    
                }
                
            }
            
            
        }
        
    }
    
}



