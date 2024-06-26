//
//  demoNode.swift
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
import ActiveLabel


fileprivate let FontSize: CGFloat = 14
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class demoNode: ASCellNode {
    
    deinit {
        print("ReelNode is being deallocated.")
    }
    

    var allowProcess = true
    var isFollowingUser = false
    var isSave = false
    var previousTimeStamp: TimeInterval = 0.0
    var totalWatchedTime: TimeInterval = 0.0
    var isStitched = false
    var collectionNode: ASCollectionNode?
    var post: PostModel!
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: ASVideoNode
    var allowStitch = false
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonNode: ASDisplayNode
    
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var sideButtonsView: ButtonSideList!
    var gradientNode: GradienView
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
 
    let maximumShowing = 100

    init(with post: PostModel, at: Int) {
            self.post = post
        
            print("demoNode at \(at) is loading post: \(post.id)")
          
            self.contentNode = ASTextNode()
            self.headerNode = ASDisplayNode()
          
            self.videoNode = ASVideoNode()
            self.gradientNode = GradienView()
            
            self.buttonNode = ASDisplayNode()
        
            super.init()
        
            self.gradientNode.isLayerBacked = true;
            self.gradientNode.isOpaque = false;
            
            if post.muxPlaybackId != "" {
                videoNode.url = self.getThumbnailBackgroundVideoNodeURL(post: post)
                videoNode.player?.automaticallyWaitsToMinimizeStalling = true
                videoNode.shouldAutoplay = false
                videoNode.shouldAutorepeat = true
                
                videoNode.muted = false
              
                
                
                if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                    // Calculate aspect ratio
                    let aspectRatio = Float(width) / Float(height)
                 
                    // Set contentMode based on aspect ratio
                    if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                        videoNode.contentMode = .scaleAspectFill
                        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                    } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                        videoNode.contentMode = .scaleAspectFit
                        videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                        //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                    } else {
                        // Default contentMode, adjust as needed
                        videoNode.contentMode = .scaleAspectFit
                        videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                        //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                    }
                } else {
                    // Default contentMode, adjust as needed
                    videoNode.contentMode = .scaleAspectFill
                    videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                    //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                }

                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
                }
                    
            }
        
          
        

        }
    
    /*
    
    override func didLoad() {
        super.didLoad()
        print("didLoad: \(post.id)")
     
        
        
        /*
         self.videoNode.view.layer.cornerRadius = 25
         self.videoNode.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
         self.videoNode.view.clipsToBounds = true
        */
        
        self.label = ActiveLabel()
        self.contentNode.backgroundColor = .clear
        self.label.backgroundColor = .clear
        self.contentNode.view.addSubview(self.label)
        self.contentNode.view.isUserInteractionEnabled = true
  
        let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
        self.label.customColor[customType] = .lightGray
        self.label.numberOfLines = Int(self.contentNode.lineCount)
        self.label.enabledTypes = [.hashtag, .url, customType]
       
        self.label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        self.label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        
        self.label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            if element == "*more" {
                self.seeMore()
            } else if element == "*hide" {
                self.hideContent()
            }
        }

        self.label.handleHashtagTap { hashtag in
            var selectedHashtag = hashtag
            selectedHashtag.insert("#", at: selectedHashtag.startIndex)
            
        
            if let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                
                if let vc = UIViewController.currentViewController() {
                    
                    let nav = UINavigationController(rootViewController: PLHVC)

                    // Set the user ID, nickname, and onPresent properties of UPVC
                    PLHVC.searchHashtag = selectedHashtag
                    PLHVC.onPresent = true

                    // Customize the navigation bar appearance
                    nav.navigationBar.barTintColor = .background
                    nav.navigationBar.tintColor = .white
                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                    nav.modalPresentationStyle = .fullScreen
                    vc.present(nav, animated: true, completion: nil)
           
                }
            }
            
            
        }

        self.label.handleURLTap { [weak self] string in
            guard let self = self else { return }
            let url = string.absoluteString
            
            if url.contains("https://stitchbox.net/app/account/") {
                
                if let id = self.getUIDParameter(from: url) {
                    self.moveToUserProfileVC(id: id)
                }
    
            } else if url.contains("https://stitchbox.net/app/post/") {
            
                if let id = self.getUIDParameter(from: url) {
                    self.openPost(id: id)
                }

            } else {
                
                guard let requestUrl = URL(string: url) else {
                    return
                }

                if UIApplication.shared.canOpenURL(requestUrl) {
                     UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                }
            }
            
        }
        
        
        self.setupDefaultContent()
        
        
        //----------------------------------------//
        self.sideButtonsView = ButtonSideList()
        self.sideButtonsView.backgroundColor = .clear
        self.sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.sideButtonsView)
        self.originalCenter = self.view.center

        NSLayoutConstraint.activate([
            self.sideButtonsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
                self.sideButtonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -55),
                self.sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
                self.sideButtonsView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
            ])

        let viewStitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.viewStitchTapped))
        viewStitchTap.numberOfTapsRequired = 1
        self.sideButtonsView.viewStitchBtn.addGestureRecognizer(viewStitchTap)
        
        
        self.headerView = PostHeader()
        self.headerNode.view.addSubview(self.headerView)

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
        self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
        self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
        self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
        
        if post.setting?.allowStitch == false {
            self.headerView.createStitchView.isHidden = true
            self.headerView.createStitchStack.isHidden = true
            self.headerView.stichBtn.isHidden = true
        } else {
            
            if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
                self.headerView.createStitchView.isHidden = true
                self.headerView.createStitchStack.isHidden = true
                self.headerView.stichBtn.isHidden = true
            } else {
                self.headerView.createStitchView.isHidden = false
                self.headerView.stichBtn.isHidden = false
                self.headerView.createStitchStack.isHidden = false
            }
        }
        
    
        
        if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
            
            self.headerView.followBtn.isHidden = true
            
        } else {
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                
                self?.checkIfFollow()
                self?.checkIfFollowedMe()
               
            }
            
         
        }
        
        self.buttonsView = ButtonsHeader()
        self.buttonNode.view.addSubview(self.buttonsView)
        self.buttonsView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
        self.buttonsView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
        self.buttonsView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
        self.buttonsView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true

        self.buttonsView.shareBtn.setImage(shareImage, for: .normal)
        self.buttonsView.saveBtn.setImage(unsaveImage, for: .normal)
        
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
        
        let stitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.stitchTapped))
        stitchTap.numberOfTapsRequired = 1
        self.headerView.stichBtn.addGestureRecognizer(stitchTap)
        
        
        let saveTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.onClickSave))
        saveTap.numberOfTapsRequired = 1
        self.buttonsView.saveBtn.addGestureRecognizer(saveTap)
        
        
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
        
        
        self.headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"
        
        
        setupSpace(width: self.view.frame.width)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.checkIfLike()
            self?.totalLikeCount()
            self?.totalCmtCount()
            self?.shareCount()
            self?.getSaveCount()
            self?.checkIfSave()
            
        }
        
        setupClearMode()
        
    }
    
    
    func setupClearMode() {
        
        if globalClear {
            
            contentNode.isHidden = true
            buttonNode.isHidden = true
            sideButtonsView.isHidden = true
            headerNode.isHidden = true

            
        }
        
    }
    
    
    override func layout() {
        super.layout()
        
        if label != nil {
            label.frame = contentNode.bounds
        }
     
    }
*/
    
    func setupDefaultContent() {

        headerNode.backgroundColor = UIColor.clear

        let hashtagsText = post.hashtags.joined(separator: " ")
        let finalText = post.content + " " + hashtagsText
        var truncatedText: String
        
        if post.content == "" {
            truncatedText = truncateTextIfNeeded(hashtagsText)
        } else {
            truncatedText = truncateTextIfNeeded(finalText)
        }
        
        let attr1 = NSAttributedString(string: truncatedText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ])

        let attr2 = NSAttributedString(string: truncatedText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        self.contentNode.attributedText = attr1
        label.attributedText = attr2
      
        setNeedsLayout()
        layoutIfNeeded()
       
        
    }

    private func truncateTextIfNeeded(_ text: String) -> String {
        if text.count > maximumShowing, text.count - maximumShowing >= 20 {
            return String(text.prefix(maximumShowing)) + " ..." + " *more"
        } else {
            return text
        }
    }


    func checkIfFollowedMe() {
        
        APIManager.shared.isFollower(uid: post.owner?.id ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                    
                    return
                }
                
                if isFollowing {
                    
                    self.allowStitch = true
                    
                } else {
                    
                    self.allowStitch = false
                    
                }
                
            case .failure(let error):
                print(error)
                self.allowStitch = false
                
            }
        }
        
    }

    
    func checkIfFollow() {
        
        APIManager.shared.isFollowing(uid: post.owner?.id ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                    hideFollowBtn()
                    return
                }
                
                if isFollowing {
                    hideFollowBtn()
                   
                    
                } else {
                    
                    setupFollowBtn()
                    
                }
                
            case .failure(let error):
                print(error)
                hideFollowBtn()
                
            }
        }
        
    }
    
    func setupFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = false
            self.isFollowingUser = false
            let followTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(demoNode.followTap))
            followTap.numberOfTapsRequired = 1
            self.headerView.followBtn.addGestureRecognizer(followTap)
            
        }
    }
    
    func followUser() {
        
        if let userId = post.owner?.id {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.followBtn.setTitle("Following", for: .normal)
            }
            
            
            APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    
                    self.isFollowingUser = true
                    self.allowProcess = true
                    
                    
                case .failure(_):
                    
                    DispatchQueue.main.async {
                        self.allowProcess = true
                        showNote(text: "Something happened!")
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.headerView.followBtn.setTitle("Follow", for: .normal)
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
    func unfollowUser() {
        
        if let userId = post.owner?.id {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.followBtn.setTitle("Follow", for: .normal)
            }

            APIManager.shared.unFollow(params: ["FollowId":userId]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    self.isFollowingUser = false
                    needRecount = true
                    self.allowProcess = true
                case .failure(_):
                    DispatchQueue.main.async {
                        self.allowProcess = true
                        showNote(text: "Something happened!")
                    }
                    
                    DispatchQueue.main.async {
                        self.headerView.followBtn.setTitle("Following", for: .normal)
                    }
                    
                    
                    
                }
            }
            
        }
        
        
    }
    
    
    
    func hideFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = true
            self.isFollowingUser = true
        }
        
    }
    
    func setupHideContent() {
        
        headerNode.backgroundColor = UIColor.clear
        
        let hashtagsText = post.hashtags.joined(separator: " ")
        let finalText = post.content + " " + hashtagsText
        var contentText: String

        if post.content == "" {
            contentText = processTextForHiding(hashtagsText)
        } else {
            contentText = processTextForHiding(finalText)
        }
        
        let attr1 = NSAttributedString(string: contentText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ])
        
        let attr2 = NSAttributedString(string: contentText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        
        self.contentNode.attributedText = attr1
        label.attributedText = attr2
        
        setNeedsLayout()
        layoutIfNeeded()
       
       
    }

    private func processTextForHiding(_ text: String) -> String {
        if text.count > maximumShowing {
            return text + " *hide"
        } else {
            return text
        }
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
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
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

extension demoNode {

  
    func didTap(_ videoNode: ASVideoNode) {
        
       
        if let vc = UIViewController.currentViewController() {
            if vc is PreviewVC {
                soundProcess()
            } else {
                soundBtn?(self)
            }
        }
        
        
    }
    
    
    @objc func soundProcess() {
        
        if videoNode.isPlaying() {
            videoNode.pause()
        } else {
            videoNode.play()
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


    
}


extension demoNode {
    
    
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
    
    @objc func onClickSave() {
        
        if isSave {
            
            isSave = false
            self.saveCount -= 1
            
            
            unSaveAnimation()
            
            APIManager.shared.unsavePost(postId: post.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                   
                case .failure(let error):
                    print("SaveCount: \(error)")
                    isSave = true
                    saveAnimation()
                }
            }

            
        } else {
            
            self.saveCount += 1
            isSave = true
            
            saveAnimation()
            
            APIManager.shared.savePost(postId: post.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                   
                case .failure(let error):
                    print("SaveCount: \(error)")
                    isSave = false
                    unSaveAnimation()
                }
            }
            
        }
        
        
        
        
    }
    
    
    func unsave() {
        
        APIManager.shared.unsavePost(postId: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print("Share get: \(apiResponse)")
                
                
            case .failure(let error):
                print("SaveCount: \(error)")
            }
        }
        
    }
    
    
    func checkIfSave() {
        
        APIManager.shared.checkSavedPost(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):

                print("Save checked: \(apiResponse)")
                
                guard apiResponse.body?["message"] as? String == "success",
                      let getIsSaved = apiResponse.body?["saved"] as? Bool  else {
                        return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
            
                    isSave = getIsSaved
                    
                    if isSave {
                        saveAnimation()
                    } else {
                        unSaveAnimation()
                    }
                }
            
            case .failure(let error):
                print("SaveCount: \(error)")
                
            }
        }
       
        
    }
    
    func getSaveCount() {
        
        APIManager.shared.countSavedPost(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                
                print("Save check: \(apiResponse)")
                
                guard apiResponse.body?["message"] as? String == "success",
                      let CountFromQuery = apiResponse.body?["saved"] as? Int  else {
                        return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.saveCount = CountFromQuery
                    self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(CountFromQuery)))"
                }
               
            case .failure(let error):
                print("SaveCount: \(error)")
            }
        }
        
    }
    
    
    func shareCount() {
        APIManager.shared.countShare(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print("shareCheck: \(apiResponse)")

                guard let message = apiResponse.body?["message"] as? String,
                      message == "success",
                      let CountFromQuery = apiResponse.body?["data"] as? Int else {
                    print("Error: Invalid or missing data in response")
                    return
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.buttonsView.shareCountLbl.text = "\(formatPoints(num: Double(CountFromQuery)))"
                }

            case .failure(let error):
                print("shareCount Error: \(error)")
            }
        }
    }

    
    @objc func shareTapped() {
    
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        APIManager.shared.createShare(postId: post.id, userId: userUID) { result in
            switch result {
            case .success(let apiResponse):
    
                print(apiResponse)
                
            case .failure(let error):
                print(error)
            }
        
        }
        
        
        let loadUsername = userDataSource.userName
        
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        
        if let vc = UIViewController.currentViewController() {
            
            vc.present(ac, animated: true, completion: nil)
            
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
    
    @objc func stitchTapped() {
        
        if let vc = UIViewController.currentViewController()  {
            
            if allowStitch {
                
                if let update1 = vc as? FeedViewController {
                    update1.editeddPost = post
                } else if let update1 = vc as? SelectedPostVC {
                    update1.editeddPost = post
                }
                
                general_vc = vc
                
                let slideVC = StitchSettingVC()
                
                if vc is FeedViewController {
                    slideVC.isFeed = true
                } else {
                    slideVC.isFeed = false
                }
                
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = vc.self
                global_presetingRate = Double(0.25)
                global_cornerRadius = 35
                vc.present(slideVC, animated: true, completion: nil)
                
            } else {
                
                if let update1 = vc as? FeedViewController {
                    
                    if let username = post.owner?.username {
                        
                        if let myUsername = _AppCoreData.userDataSource.value?.userName {
                            update1.showErrorAlert("Hi \(myUsername),", msg: "@\(username) have to follow you to enable stitch")
                        } else {
                            update1.showErrorAlert("Oops!", msg: "@\(username) have to follow you to enable stitch.")
                        }
                        
                    }
                    
                } else if let update1 = vc as? SelectedPostVC {
                    
                    if let username = post.owner?.username {
                        
                        if let myUsername = _AppCoreData.userDataSource.value?.userName {
                            update1.showErrorAlert("Hi \(myUsername),", msg: "@\(username) have to follow you to enable stitch")
                        } else {
                            update1.showErrorAlert("Oops!", msg: "@\(username) have to follow you to enable stitch")
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            
        }
         
    }
    
    @objc func followTap() {
        
        if allowProcess {
            self.allowProcess = false
            if isFollowingUser {
                
                unfollowUser()
                
            } else {
                
                followUser()
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
    
    
    @objc func viewStitchTapped() {
        
        viewStitchBtn?(self)
        
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
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = true
        }
        
        APIManager.shared.likePost(id: post.id) { result in
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unlikeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = false
        }
        
        APIManager.shared.unlikePost(id: post.id) { result in

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
    
    func saveAnimation() {
        
        
        self.buttonsView.saveCountLbl.text =  "\(formatPoints(num: Double(self.saveCount)))"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.saveBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.saveBtn.setImage(saveImage!, for: .normal)
            
            
            
            
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.saveBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func unSaveAnimation() {
        
        self.buttonsView.saveCountLbl.text =  "\(formatPoints(num: Double(self.saveCount)))"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.saveBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.saveBtn.setImage(unsaveImage!, for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.saveBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func unlikeAnimation() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
        })
    }

}

extension demoNode {
    
    func totalLikeCountFromLocal() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.post.estimatedCount?.sizeLikes ?? 0)))"
        }
        
    }
    
    func totalCmtCountFromLocal() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(commentsCountFromQuery)))"
                }
                
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
        
    }
    
}

extension demoNode {

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
        videoNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)

        let headerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 8)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)

        let contentInset = UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 70)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)

        let verticalStack = ASStackLayoutSpec.vertical()
        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)

        verticalStack.children = [headerInsetSpec]

        if !post.content.isEmpty || post.hashtags.contains(where: { !$0.isEmpty }) {
            verticalStack.children?.append(contentInsetSpec)
        }

        verticalStack.children?.append(buttonsInsetSpec)

        let verticalStackInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let gradientInsetSpec = ASInsetLayoutSpec(insets: inset, child: gradientNode)

        // Here we have removed the roundedCornerNode and using videoNode directly
        let videoInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)

        let overlay = ASOverlayLayoutSpec(child: videoInsetSpec, overlay: gradientInsetSpec)

        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)
        let finalOverlay = ASOverlayLayoutSpec(child: overlay, overlay: relativeSpec)

        return finalOverlay
    }




    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
        let buttonsInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }

    private func setupSpace(width: CGFloat) {
        if let buttonsView = self.buttonsView {
         
            let leftAndRightPadding: CGFloat = 16 * 2 // Padding for both sides
            let itemWidth: CGFloat = 60
            let numberOfItems: CGFloat = 4 // Number of items in the stack view
            let superViewWidth: CGFloat = width // Assuming this is the superview's width
            
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


extension demoNode: UIGestureRecognizerDelegate {
    
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

    
    func getUIDParameter(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { $0.name == "uid" })?.value
        } else {
            return nil
        }
    }

    func moveToUserProfileVC(id: String) {
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
                

                if general_vc != nil {
                    general_vc.viewWillDisappear(true)
                    general_vc.viewDidDisappear(true)
                }
                
              
                
                let nav = UINavigationController(rootViewController: UPVC)

                // Set the user ID, nickname, and onPresent properties of UPVC
                UPVC.userId = id
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
    
    
    func openPost(id: String) {
      
        presentSwiftLoader()

        APIManager.shared.getPostDetail(postId: id) { result in
         
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body else {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                    }
                  return
                }
               
                if !data.isEmpty {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                        
                        if let post = PostModel(JSON: data) {
                            
                            if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                                
                                if let vc = UIViewController.currentViewController() {
                                

                                    if general_vc != nil {
                                        general_vc.viewWillDisappear(true)
                                        general_vc.viewDidDisappear(true)
                                    }
                                    
                               
                                    
                                    RVC.onPresent = true
                                    
                                    let nav = UINavigationController(rootViewController: RVC)

                                    // Set the user ID, nickname, and onPresent properties of UPVC
                                    RVC.posts = [post]
                                   
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
                    
                } else {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                    }
                }

            case .failure(let error):
                print(error)
                Dispatch.main.async {
                    SwiftLoader.hide()
                }
                
            }
        }
        
    }
    
    
    func cleanup(view: UIView) {
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        for sub in view.subviews  {
            sub.removeFromSuperview()
        }
        
        if let recognizers = headerNode.view.gestureRecognizers {
            for recognizer in recognizers {
                headerNode.view.removeGestureRecognizer(recognizer)
            }
        }
        
        for sub in headerNode.view.subviews {
            sub.removeFromSuperview()
        }
        
        if let recognizers = buttonNode.view.gestureRecognizers {
            for recognizer in recognizers {
                buttonNode.view.removeGestureRecognizer(recognizer)
            }
        }
        
        for sub in buttonNode.view.subviews {
            sub.removeFromSuperview()
        }
               
        
    }

}

extension demoNode {
    
    func seeMore() {
        
        setupHideContent()
        setNeedsLayout()
        
    }
    
    func hideContent() {
        
        setupDefaultContent()
        setNeedsLayout()
    }
    
}



extension demoNode {
    
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
