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
        //view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
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
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    
    private var headerView: PostHeader!
    private var sideButtonsView: ButtonSideList!
    
    private var label: ActiveLabel!
    private let maximumShowing = 100
    private var isSave = false
    private var isFollowingUser = false
    private var allowStitch = false
    private var saveCount = 0
    private var likeCount = 0
    private var isLike = false
    private var allowProcess = true
    fileprivate let FontSize: CGFloat = 14
    fileprivate let OrganizerImageSize: CGFloat = 30
    private var index: Int!
    
    init(with post: PostModel, at: Int) {
        print("VideoNode \(at) is loading post: \(post.id)")
        self.post = post
        self.index = at
        self.gradientNode = GradienView()
        self.videoNode = ASVideoNode()
      
        
        super.init()

        configureGradientNode()
        configureVideoNode(with: post)
    }

    
    override func didLoad() {
        super.didLoad()
    
         
         
        addPinchGestureRecognizer()
        addPanGestureRecognizer()
        
        if UIViewController.currentViewController() is ParentViewController {
          
            if isOriginal {
                // Handle count stitch if not then hide
                
            
                addSideButtons(isOwned: true, total: post.totalStitchTo + post.totalMemberStitch)
                
                
            } else {
                addSideButtons(isOwned: false)
            }
        }
        
        setupViews()
        setupLabel()
       
    
        setupSpace(width: self.view.frame.width)
        clearMode()

     }
    
    
    override func layout() {
        super.layout()
        if self.label != nil, self.headerView != nil {
            self.label.frame = self.headerView.contentLbl.bounds
            self.label.numberOfLines = Int(self.headerView.contentLbl.numberOfLines)
        }
        
    }
    
    func clearMode() {
        
        if globalSetting.ClearMode == true {
            
            hideAllInfo()
            
        }
        
    }
    

    
    private func setupSpace(width: CGFloat) {
        
        if let buttonsView = self.headerView {
         
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
    
    override func didExitVisibleState() {
        videoNode.pause()
    }

    private func addSideButtons(isOwned: Bool, total: Int? = 0) {
        setupSideButtonsView()

        if isOwned {
            configureForOwnedState(total: total)
        } else {
            configureForNonOwnedState()
        }
    }

    private func setupSideButtonsView() {
        sideButtonsView = ButtonSideList()
        sideButtonsView.backgroundColor = .clear
        sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideButtonsView)
        
        sideButtonsView.statusImg.isHidden = false
        
        NSLayoutConstraint.activate([
            sideButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sideButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
            sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
            sideButtonsView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }

    private func configureForOwnedState(total: Int?) {
        if let finalTotal = total, finalTotal > 0 {
            sideButtonsView.isHidden = false
            sideButtonsView.originalStack.isHidden = false
            sideButtonsView.stickStack.isHidden = true

            let pushToStitch = UITapGestureRecognizer(target: self, action: #selector(VideoNode.pushToStitchView))
            sideButtonsView.originalStack.addGestureRecognizer(pushToStitch)
            
            sideButtonsView.originalStack.isUserInteractionEnabled = true
            sideButtonsView.originalStitchCount.text = "\(formatPoints(num: Double(finalTotal)))"
        } else {
            sideButtonsView.isHidden = true
        }
    }

    private func configureForNonOwnedState() {
        sideButtonsView.isHidden = false

        let viewStitchTap = UITapGestureRecognizer(target: self, action: #selector(VideoNode.viewStitchTapped))
        sideButtonsView.viewStitchBtn.addGestureRecognizer(viewStitchTap)

        let backToOriginal = UITapGestureRecognizer(target: self, action: #selector(VideoNode.backToOriginal))
        sideButtonsView.backToOriginalBtn.addGestureRecognizer(backToOriginal)
        
        sideButtonsView.originalStack.isHidden = true
        sideButtonsView.stickStack.isHidden = false
        
        if let vc = UIViewController.currentViewController() as? ParentViewController {
                     
            var index = 0
            
            if vc.feedViewController.currentIndex != nil {
                index = vc.feedViewController.currentIndex!
            }
            
            if !vc.feedViewController.posts.isEmpty {
                
                let feedPost = vc.feedViewController.posts[index]
                
                
                if let stitchto = feedPost.stitchTo, !stitchto.isEmpty {
                    
                    if stitchto[0].rootId == post.id {
                        
                        sideButtonsView.statusImg.image = UIImage(named: "star white")
                        
                    } else {
                        
                        sideButtonsView.statusImg.image = UIImage(named: "partner white")
                        
                    }
                    
                } else {
                    
                    sideButtonsView.statusImg.image = UIImage(named: "partner white")
                    
                }
                
            } else {
                sideButtonsView.statusImg.image = UIImage(named: "partner white")
            }
        
            

        }
        
    }


    func updateStitchCount(text: String) {
        
        if sideButtonsView != nil {
            
            sideButtonsView.stitchCount.text = text
            
        }
        
    }

    private func configureGradientNode() {
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
    }

    private func configureVideoNode(with post: PostModel) {
        
        videoNode.url = getThumbnailURL(post: post)
        videoNode.player?.automaticallyWaitsToMinimizeStalling = true
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = true
        videoNode.delegate = self

        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
            let aspectRatio = Float(width) / Float(height)

            if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                videoNode.contentMode = .scaleAspectFill
                videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                videoNode.contentMode = .scaleAspectFit
                videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                   
            } else {
                // Default contentMode, adjust as needed
                videoNode.contentMode = .scaleAspectFit
                videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                   
            }
        } else {
                // Default contentMode, adjust as needed
            videoNode.contentMode = .scaleAspectFill
            videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                
        }
        
    
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)

            if self.isFirstItem {
                self.videoNode.muted = shouldMute ?? !globalIsSound
                self.videoNode.play()
            }
            
        }
    }

    private func addPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }

    private func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
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
    
    func playProcess() {
        
        if videoNode.isPlaying() {
            videoNode.pause()
        } else {
            videoNode.play()
        }
        
    }

  
    func didTap(_ videoNode: ASVideoNode) {
        if let vc = UIViewController.currentViewController() {
            switch vc {
            case _ as PreviewVC:
                playProcess()
            case let parentVC as ParentViewController:
                if parentVC.isFeed {
                    playProcess()
                } else if !parentVC.stitchViewController.selectPostCollectionView.isHidden {
                    parentVC.stitchViewController.selectPostCollectionView.isHidden = true
                    showAllInfo()
                } else {
                    playProcess()
                }
            default:
                break
            }
        }
    }

    func hideAllInfo() {

        label.isHidden = true
        gradientNode.isHidden = true
        sideButtonsView.isHidden = true
        headerView.isHidden = true
        
    }
    
    func showAllInfo() {
        
        label.isHidden = false
        gradientNode.isHidden = false
        sideButtonsView.isHidden = false
        headerView.isHidden = false
        
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
        guard let _ = _AppCoreData.userDataSource.value, time < 2 else { return }
        
        time += 1
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
            disableScroll()
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
                        }, completion: { [weak self]_ in
                            self?.enableScroll()
                })
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
                
            }
            
            
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
           
            UIView.animate(withDuration: 0.2, animations: {
                        
                    }, completion: { [weak self] _ in
                        self?.enableScroll()
                    })
            
        }
    }
    
    func setScrollEnabled(_ isEnabled: Bool) {
        if let vc = UIViewController.currentViewController() {
            switch vc {
            case let parentVC as ParentViewController:
                if parentVC.isFeed {
                    parentVC.feedViewController.collectionNode.view.isScrollEnabled = isEnabled
                } else {
                    parentVC.stitchViewController.collectionNode.view.isScrollEnabled = isEnabled
                }
            case let selectedPostVC as SelectedPostVC:
                selectedPostVC.collectionNode.view.isScrollEnabled = isEnabled
            default:
                break
            }
        }
    }

    func disableScroll() {
        setScrollEnabled(false)
    }

    func enableScroll() {
        setScrollEnabled(true)
    }


    
}


extension VideoNode: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UIPinchGestureRecognizer || otherGestureRecognizer is UIPinchGestureRecognizer {
                return true
            }

            // Check for the collectionNode's panGestureRecognizer
            if let collectionNodePanGestureRecognizer = self.panGestureRecognizer, otherGestureRecognizer == collectionNodePanGestureRecognizer {
                return true
            }
            
            if gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }

            return false
        }
    
    @objc func pushToStitchView() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if update1.isFeed {
                        // Calculate the next page index
                       
                        let offset = CGFloat(1) * update1.scrollView.bounds.width
                        
                        // Scroll to the next page
                        update1.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                        update1.showStitch()
                      
                    }
                }
            }
        }
    }
    
    @objc func viewStitchTapped() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if !update1.isFeed {
                        hideAllInfo()
                        update1.stitchViewController.selectPostCollectionView.isHidden = false
                      
                    }
                }
            }
        }
    }
    
    
    @objc func backToOriginal() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if !update1.isFeed {
                        // Calculate the next page index
                       
                        let offset = CGFloat(0) * update1.scrollView.bounds.width
        
                        // Scroll to the next page
                        update1.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                        update1.showFeed()
                       
                    }
                }
            }
        }
    }

    func setupLabel() {
        self.label = ActiveLabel()
    
        self.label.backgroundColor = .clear
        self.headerView.contentLbl.addSubview(self.label)
        self.headerView.contentLbl.isUserInteractionEnabled = true
        
      
        let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
        self.label.customColor[customType] = .lightGray
        self.label.enabledTypes = [.hashtag, .url, customType]
       
        self.label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        self.label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        
        self.label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            element == "*more" ? self.seeMore() : self.hideContent()
        }
        
        self.label.handleHashtagTap { [weak self] hashtag in
            guard let self = self else { return }
            self.presentPostListWithHashtagVC(for: "#" + hashtag)
        }

        self.label.handleURLTap { [weak self] string in
            guard let self = self else { return }
            self.handleURLTap(url: string.absoluteString)
        }
    
        
    
        setupDefaultContent()
        
    }
    
    func setupViews() {
        // Header View Setup
        self.headerView = PostHeader()
        self.view.addSubview(self.headerView)
        addConstraints(to: self.headerView, within: self.view)
    
        if post.setting?.allowStitch == false {
            hideStitchViews()
        } else if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
            hideStitchViews()
        }

        self.headerView.contentLbl.numberOfLines = 0
        self.headerView.contentLbl.lineBreakMode = .byWordWrapping
        
        self.headerView.contentLbl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.headerView.contentLbl.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)


        self.headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"

      
        self.headerView.shareBtn.setImage(shareImage, for: .normal)
        self.headerView.saveBtn.setImage(unsaveImage, for: .normal)
        self.headerView.commentBtn.setImage(cmtImage, for: .normal)

        // Gesture Recognizers
        setupGestureRecognizers()
        fillStats()
        loadReaction()
    }
    
    func fillStats() {
        
        likeCount = post.totalLikes
        saveCount = post.totalSave
        
        self.headerView.likeCountLbl.text = "\(formatPoints(num: Double(post.totalLikes)))"
        self.headerView.saveCountLbl.text = "\(formatPoints(num: Double(post.totalShares)))"
        self.headerView.commentCountLbl.text = "\(formatPoints(num: Double(post.totalComments)))"
        self.headerView.shareCountLbl.text = "\(formatPoints(num: Double(post.totalShares)))"
        
    }

    func addConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = true
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: constant).isActive = true
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant).isActive = true
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant).isActive = true
    }

    func hideStitchViews() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.createStitchView.isHidden = true
            self.headerView.createStitchStack.isHidden = true
            self.headerView.stichBtn.isHidden = true
        }
        
       
    }

    func showStitchViews() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.createStitchView.isHidden = false
            self.headerView.stichBtn.isHidden = false
            self.headerView.createStitchStack.isHidden = false
        }
    
    }

    func setupGestureRecognizers() {
     
        let usernameTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.userTapped))
        self.headerView.usernameLbl.isUserInteractionEnabled = true
        self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
        
        let shareTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.shareTapped))
        self.headerView.shareBtn.addGestureRecognizer(shareTap)

        let likeTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeTapped))
        self.headerView.likeBtn.addGestureRecognizer(likeTap)

        let stitchTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.stitchTapped))
        self.headerView.stichBtn.addGestureRecognizer(stitchTap)

        let saveTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.onClickSave))
        self.headerView.saveBtn.addGestureRecognizer(saveTap)

        let commentTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.commentTapped))
        self.headerView.commentBtn.addGestureRecognizer(commentTap)

        let doubleTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeHandle), taps: 2)
        doubleTap.delaysTouchesBegan = true
        self.view.addGestureRecognizer(doubleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
        longPress.minimumPressDuration = 0.65
        longPress.delaysTouchesBegan = true
        self.view.addGestureRecognizer(longPress)
        
    }


    func createTapGestureRecognizer(target: Any, action: Selector, taps: Int = 1) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = taps
        return tap
    }

    func handleURLTap(url: String) {
        if url.contains("https://stitchbox.net/app/account/") || url.contains("https://stitchbox.net/app/post/") {
            if let id = self.getUIDParameter(from: url) {
                url.contains("account") ? self.moveToUserProfileVC(id: id) : self.openPost(id: id)
            }
        } else if let requestUrl = URL(string: url), UIApplication.shared.canOpenURL(requestUrl) {
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
        }
    }

    func presentPostListWithHashtagVC(for selectedHashtag: String) {
        guard let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC,
              let vc = UIViewController.currentViewController() else { return }
        
        let nav = UINavigationController(rootViewController: PLHVC)
        PLHVC.searchHashtag = selectedHashtag
        PLHVC.onPresent = true
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen
        vc.present(nav, animated: true, completion: nil)
    }
    
    func seeMore() {
        
        setupHideContent()
        setNeedsLayout()
        
    }
    
    func hideContent() {
        
        setupDefaultContent()
        setNeedsLayout()
    }

    
    func setupDefaultContent() {

        headerView.backgroundColor = UIColor.clear

        let hashtagsText = post.hashtags?.joined(separator: " ")
        let finalText = post.content + " " + (hashtagsText ?? "")
        var truncatedText: String
        
        if post.content == "" {
            truncatedText = truncateTextIfNeeded(hashtagsText ?? "")
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
        
        self.headerView.contentLbl.attributedText = attr1
        label.attributedText = attr2
      
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()
        
        
        
    }
    
    func setupHideContent() {
        
        headerView.backgroundColor = UIColor.clear
        
        let hashtagsText = post.hashtags?.joined(separator: " ")
        let finalText = post.content + " " + (hashtagsText ?? "")
        var contentText: String

        if post.content == "" {
            contentText = processTextForHiding(hashtagsText ?? "")
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
        
        
        self.headerView.contentLbl.attributedText = attr1
        label.attributedText = attr2
        
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()

       
    }
    
    private func processTextForHiding(_ text: String) -> String {
        if text.count > maximumShowing {
            return text + " *hide"
        } else {
            return text
        }
    }
    
    func moveToUserProfileVC(id: String) {
        guard let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
              let vc = UIViewController.currentViewController() else { return }

        if general_vc != nil {
            general_vc.viewWillDisappear(true)
            general_vc.viewDidDisappear(true)
        }

        let nav = UINavigationController(rootViewController: UPVC)
        UPVC.userId = id
        UPVC.onPresent = true
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen
        vc.present(nav, animated: true, completion: nil)
    }

    
    func openPost(id: String) {
        presentSwiftLoader()

        APIManager.shared.getPostDetail(postId: id) { result in
            DispatchQueue.main.async {
                SwiftLoader.hide()
            }

            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body, !data.isEmpty, let post = PostModel(JSON: data) else {
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.presentSelectedPostVC(with: [post])
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func presentSelectedPostVC(with posts: [PostModel]) {
        guard let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC,
              let vc = UIViewController.currentViewController() else { return }

        if general_vc != nil {
            general_vc.viewWillDisappear(true)
            general_vc.viewDidDisappear(true)
        }

        RVC.onPresent = true
        RVC.posts = posts

        let nav = UINavigationController(rootViewController: RVC)
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen

        vc.present(nav, animated: true, completion: nil)
    }

    func getUIDParameter(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { $0.name == "uid" })?.value
        } else {
            return nil
        }
    }
    
    private func truncateTextIfNeeded(_ text: String) -> String {
        if text.count > maximumShowing, text.count - maximumShowing >= 20 {
            return String(text.prefix(maximumShowing)) + " ..." + " *more"
        } else {
            return text
        }
    }
    
}

extension VideoNode {
    
    @objc func userTapped() {
        guard let userId = post.owner?.id,
              let username = post.owner?.username,
              !userId.isEmpty,
              !username.isEmpty,
              userId != _AppCoreData.userDataSource.value?.userID else {
            return
        }
        
        showUserProfile(for: userId, with: username)
    }

    private func showUserProfile(for userId: String, with username: String) {
        guard let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
              let currentVC = UIViewController.currentViewController() else {
            return
        }

        configureUserProfileVC(UPVC, with: userId, nickname: username)

        let nav = UINavigationController(rootViewController: UPVC)
        configureNavigationController(nav)

        currentVC.present(nav, animated: true, completion: nil)
    }

    private func configureUserProfileVC(_ UPVC: UserProfileVC, with userId: String, nickname: String) {
        UPVC.userId = userId
        UPVC.nickname = nickname
        UPVC.onPresent = true
    }

    private func configureNavigationController(_ navigationController: UINavigationController) {
        navigationController.navigationBar.barTintColor = .background
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController.modalPresentationStyle = .fullScreen
    }

    
    @objc func onClickSave() {
        isSave.toggle()
        if isSave {
            handleSave()
        } else {
            handleUnsave()
        }
    }

    private func handleSave() {
        saveCount += 1
        saveAnimation()
        APIManager.shared.savePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("SaveCount: \(error)")
                self.isSave = false
                self.unSaveAnimation()
            case .success(let apiResponse):
                print(apiResponse)
            }
        }
    }

    private func handleUnsave() {
        saveCount -= 1
        unSaveAnimation()
        APIManager.shared.unsavePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("SaveCount: \(error)")
                self.isSave = true
                self.saveAnimation()
            case .success(let apiResponse):
                print(apiResponse)
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
                      let getIsSaved = apiResponse.body?["saved"] as? Bool else {
                    return
                }

                DispatchQueue.main.async {
                    self.isSave = getIsSaved
                    if self.isSave {
                        self.saveAnimation()
                    } else {
                        self.unSaveAnimation()
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
                      let countFromQuery = apiResponse.body?["saved"] as? Int else {
                    return
                }

                DispatchQueue.main.async {
                    self.saveCount = countFromQuery
                    self.headerView.saveCountLbl.text = "\(formatPoints(num: Double(countFromQuery)))"
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
                      let countFromQuery = apiResponse.body?["data"] as? Int else {
                    print("Error: Invalid or missing data in response")
                    return
                }

                DispatchQueue.main.async {
                    self.headerView.shareCountLbl.text = "\(formatPoints(num: Double(countFromQuery)))"
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
        
        createShare(userUID: userUID)
        
        if let loadUsername = userDataSource.userName {
            presentShareController(username: loadUsername)
        }
    }

    private func createShare(userUID: String) {
        APIManager.shared.createShare(postId: post.id, userId: userUID) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func presentShareController(username: String) {
        let items: [Any] = ["Hi I am \(username) from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let vc = UIViewController.currentViewController() {
            vc.present(ac, animated: true, completion: nil)
        }
    }

    
    
    @objc func commentTapped() {
        guard let viewController = UIViewController.currentViewController() else { return }

        general_vc = viewController

        let slideVC = CommentVC()
        slideVC.post = self.post
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = viewController
        global_presetingRate = 0.75
        global_cornerRadius = 35

        viewController.present(slideVC, animated: true, completion: nil)
    }

    @objc func stitchTapped() {
        guard let vc = UIViewController.currentViewController(), allowStitch else {
            showStitchError()
            return
        }

        if let updateVC = vc as? ParentViewController{
            if updateVC.isFeed {
                updateVC.feedViewController.editeddPost = post
            } else {
                updateVC.stitchViewController.editeddPost = post
            }
        
        }

        general_vc = vc

        let slideVC = StitchSettingVC()
        slideVC.isFeed = vc is FeedViewController
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = vc.self
        global_presetingRate = 0.25
        global_cornerRadius = 35

        vc.present(slideVC, animated: true, completion: nil)
    }

    private func showStitchError() {
        /*
        guard let vc = UIViewController.currentViewController() as? FeedViewController ?? UIViewController.currentViewController() as? SelectedPostVC, let username = post.owner?.username else { return }

        let myUsername = _AppCoreData.userDataSource.value?.userName
        let title = myUsername != nil ? "Hi \(myUsername!)," : "Oops!"
        let message = "@\(username) have to follow you to enable stitch."

        vc.showErrorAlert(title, msg: message)
        */
    }

    
    @objc func followTap() {
        guard allowProcess else { return }
        
        allowProcess = false
        isFollowingUser ? unfollowUser() : followUser()
    }

    
    
    @objc func likeTapped() {
        isLike ? performUnLike() : performLike()
    }

    
    @objc func settingTapped() {
        
        guard let vc = UIViewController.currentViewController() else { return }

        global_cornerRadius = 45
        
        if headerView.isHidden {
            
            global_presetingRate = 0.36
            
        } else {
            
            global_presetingRate = 0.35
        }

        if post.id == _AppCoreData.userDataSource.value?.userID {
            
            presentVC(vc, using: PostSettingVC())
            
        } else {
            
            let newsFeedSettingVC = NewsFeedSettingVC()
            newsFeedSettingVC.modalPresentationStyle = .custom
            newsFeedSettingVC.transitioningDelegate = vc.self
            newsFeedSettingVC.isInformationHidden = headerView.isHidden
            
            
            if let updateVC = vc as? ParentViewController {
                
                if updateVC.isFeed {
                    updateVC.feedViewController.editeddPost = post
                    setOwnership(for: newsFeedSettingVC)
                    updateVC.present(newsFeedSettingVC, animated: true)
                } else {
                    updateVC.stitchViewController.editeddPost = post
                    setOwnership(for: newsFeedSettingVC)
                    updateVC.present(newsFeedSettingVC, animated: true)
                }
                
            } else if let updateVC = vc as? SelectedPostVC {
                updateVC.editeddPost = post
                setOwnership(for: newsFeedSettingVC)
                vc.present(newsFeedSettingVC, animated: true)
            }
        }
    }

    func setOwnership(for vc: NewsFeedSettingVC) {
        if post.owner?.id == _AppCoreData.userDataSource.value?.userID {
            vc.isOwner = true
        } else {
            vc.isOwner = false
        }
    }

    func presentVC(_ viewController: UIViewController, using postSettingVC: PostSettingVC) {
        
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = viewController.self
        postSettingVC.isInformationHidden = headerView.isHidden
       

        if let updateVC = viewController as? ParentViewController {
            
            if updateVC.isFeed {
                updateVC.feedViewController.editeddPost = post
                updateVC.present(postSettingVC, animated: true)
            } else {
                updateVC.stitchViewController.editeddPost = post
                updateVC.present(postSettingVC, animated: true)
            }
            
        } else if let updateVC = viewController as? SelectedPostVC {
            updateVC.editeddPost = post
            viewController.present(postSettingVC, animated: true)
        }
    }


    
    @objc func likeHandle() {
        guard !isLike else { return }
        
        let imgView = createImageView()
        view.addSubview(imgView)
        
        fireworkController.addFirework(sparks: 10, above: imgView)
        fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
        
        animateImageView(imgView)
        
        performLike()
    }

    private func createImageView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = popupLikeImage
        imgView.frame.size = CGSize(width: 120, height: 120)
        imgView.contentMode = .scaleAspectFit
        imgView.center = view.center
        return imgView
    }

    private func animateImageView(_ imgView: UIImageView) {
        
        UIView.animate(withDuration: 0.5) {
            imgView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            imgView.removeFromSuperview()
        }
    }

    
    func performLike() {
        likeCount += 1
        updateLikeUI()

        APIManager.shared.likePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateLikeUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeAnimation()
            self.headerView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = true
        }
    }


    
    func performUnLike() {
        likeCount -= 1
        updateUnlikeUI()

        APIManager.shared.unlikePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
                
            }
        }
    }

    private func updateUnlikeUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unlikeAnimation()
            self.headerView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = false
        }
    }
    
    func likeAnimation() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.headerView.likeBtn.transform = scaleTransform
                self.headerView.likeBtn.setImage(likeImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.headerView.likeBtn.transform = CGAffineTransform.identity
                })
            })
            
        }
        
    }

    
    func saveAnimation() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)

            self.headerView.saveCountLbl.text = "\(formatPoints(num: Double(self.saveCount)))"

            UIView.animate(withDuration: 0.1, animations: {
                self.headerView.saveBtn.transform = scaleTransform
                self.headerView.saveBtn.setImage(saveImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.headerView.saveBtn.transform = CGAffineTransform.identity
                })
            })
            
        }
        
    }

    
    func unSaveAnimation() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            self.headerView.saveCountLbl.text = "\(formatPoints(num: Double(self.saveCount)))"

            UIView.animate(withDuration: 0.1, animations: {
                self.headerView.saveBtn.transform = scaleTransform
                self.headerView.saveBtn.setImage(unsaveImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.headerView.saveBtn.transform = CGAffineTransform.identity
                })
            })
        }
        
        
    }

    
    func unlikeAnimation() {
        let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.headerView.likeBtn.transform = scaleTransform
            self.headerView.likeBtn.setImage(emptyLikeImage!, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.headerView.likeBtn.transform = CGAffineTransform.identity
            })
        })
    }
    
    func unfollowUser() {
        guard let userId = post.owner?.id else { return }

        DispatchQueue.main.async { [weak self] in
            self?.headerView.followBtn.setTitle("Follow", for: .normal)
        }

        APIManager.shared.unFollow(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.isFollowingUser = false
                needRecount = true
                self.allowProcess = true

            case .failure:
                DispatchQueue.main.async {
                    self.allowProcess = true
                    self.headerView.followBtn.setTitle("Following", for: .normal)
                    showNote(text: "Something happened!")
                }
            }
        }
    }

    func followUser() {
        guard let userId = post.owner?.id else { return }

        DispatchQueue.main.async { [weak self] in
            self?.headerView.followBtn.setTitle("Following", for: .normal)
        }

        APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.isFollowingUser = true
                self.allowProcess = true

            case .failure:
                DispatchQueue.main.async {
                    self.allowProcess = true
                    self.headerView.followBtn.setTitle("Follow", for: .normal)
                    showNote(text: "Something happened!")
                }
            }
        }
    }

    
    func loadReaction() {
        APIManager.shared.getReactionPost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                guard let message = apiResponse.body?["message"] as? String,
                      message == "success",
                      let data = apiResponse.body?["data"] as? [String: Any],
                      let isFollower = data["isFollower"] as? Bool,
                      let isFollowing = data["isFollowing"] as? Bool,
                      let isLiked = data["isLike"] as? Bool,
                      let isSaved = data["isSaved"] as? Bool else {
                    print("Error: Invalid or missing data in response")
                    return
                }
                
                self.handleReaction(isFollower: isFollower, isFollowing: isFollowing, isLiked: isLiked, isSaved: isSaved)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleReaction(isFollower: Bool, isFollowing: Bool, isLiked: Bool, isSaved: Bool) {
        self.allowStitch = isFollower
        if !isFollower {
            self.hideStitchViews()
        } else {
            
            if post.setting?.allowStitch == true {
                self.showStitchViews()
            } else {
                self.hideStitchViews()
            }
            
        }

        if isFollowing {
            self.hideFollowBtn()
        } else {
            self.setupFollowBtn()
        }
            
        self.isSave = isSaved
        if isSaved {
            self.saveAnimation()
        } else {
            self.unSaveAnimation()
        }

            self.isLike = isLiked
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let likeImage = isLiked ? likeImage! : emptyLikeImage!
            self.headerView.likeBtn.setImage(likeImage, for: .normal)
        }
    }

    func hideFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = true
            self.isFollowingUser = true
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
    
}
