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
    var hashtagsNode: ASDisplayNode
    var sidebuttonListView: ASDisplayNode!
    
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var hashtagView: HashtagView!
    var sideButtonView: SideButton!
    var gradientNode: GradienView
  
    var likeCount = 0
    var isLike = false
    
    var settingBtn : ((ASCellNode) -> Void)?
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonsNode = ASDisplayNode()
        self.hashtagsNode = ASDisplayNode()
        self.videoNode = ASVideoNode()
        self.sidebuttonListView = ASDisplayNode()
        self.gradientNode = GradienView()
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
            
            self.hashtagView = HashtagView()
            self.hashtagsNode.view.addSubview(self.hashtagView)
            
            self.hashtagView.translatesAutoresizingMaskIntoConstraints = false
            self.hashtagView.topAnchor.constraint(equalTo: self.hashtagsNode.view.topAnchor, constant: 0).isActive = true
            self.hashtagView.bottomAnchor.constraint(equalTo: self.hashtagsNode.view.bottomAnchor, constant: 0).isActive = true
            self.hashtagView.leadingAnchor.constraint(equalTo: self.hashtagsNode.view.leadingAnchor, constant: 0).isActive = true
            self.hashtagView.trailingAnchor.constraint(equalTo: self.hashtagsNode.view.trailingAnchor, constant: 0).isActive = true
              
            if post.muxPlaybackId != "" {
                
                self.sideButtonView = SideButton()
                self.sidebuttonListView.view.addSubview(self.sideButtonView)
                self.sideButtonView.playSpeedBtn.setTitle("", for: .normal)
                self.sideButtonView.soundBtn.setTitle("", for: .normal)
                self.sideButtonView.playSpeedBtn.setImage(speedImage, for: .normal)
                self.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                self.sideButtonView.playSpeedBtn.isHidden = true
                
                self.sideButtonView.translatesAutoresizingMaskIntoConstraints = false
                self.sideButtonView.topAnchor.constraint(equalTo: self.sidebuttonListView.view.topAnchor, constant: 0).isActive = true
                self.sideButtonView.bottomAnchor.constraint(equalTo: self.sidebuttonListView.view.bottomAnchor, constant: 0).isActive = true
                self.sideButtonView.leadingAnchor.constraint(equalTo: self.sidebuttonListView.view.leadingAnchor, constant: 0).isActive = true
                self.sideButtonView.trailingAnchor.constraint(equalTo: self.sidebuttonListView.view.trailingAnchor, constant: 0).isActive = true
                
               
                let soundTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.soundProcess))
                soundTap.numberOfTapsRequired = 1
                self.sideButtonView.soundBtn.addGestureRecognizer(soundTap)

            }
            
            let avatarTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.userTapped))
            avatarTap.numberOfTapsRequired = 1
            self.headerView.avatarImage.isUserInteractionEnabled = true
            self.headerView.avatarImage.addGestureRecognizer(avatarTap)
            
            let usernameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.userTapped))
            usernameTap.numberOfTapsRequired = 1
            self.headerView.usernameLbl.isUserInteractionEnabled = true
            self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
            
            
            let shareTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.shareTapped))
            shareTap.numberOfTapsRequired = 1
            self.buttonsView.shareBtn.addGestureRecognizer(shareTap)
            
            
            let likeTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.likeTapped))
            likeTap.numberOfTapsRequired = 1
            self.buttonsView.likeBtn.addGestureRecognizer(likeTap)
            
            let commentTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.cmtTapped))
            commentTap.numberOfTapsRequired = 1
            self.buttonsView.commentBtn.addGestureRecognizer(commentTap)
            
            
            let settingTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.settingTapped))
            settingTap.numberOfTapsRequired = 1
            self.headerView.settingBtn.addGestureRecognizer(settingTap)
            
            
            let streamLinkTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.streamingLinkTapped))
            streamLinkTap.numberOfTapsRequired = 1
            self.buttonsView.streamlinkBtn.addGestureRecognizer(streamLinkTap)
            
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.likeHandle))
            doubleTap.numberOfTapsRequired = 2
            self.view.addGestureRecognizer(doubleTap)
            
            doubleTap.delaysTouchesBegan = true
            
            
            let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PostNode.settingTapped))
            longPress.minimumPressDuration = 0.5
            self.view.addGestureRecognizer(longPress)
            
            longPress.delaysTouchesBegan = true
            
            //-------------------------------------//
            
    
            
            //-------------------------------------//
            
            if let time = post.createdAt {
                
                self.headerView.timeLbl.text = timeAgoSinceDate(time, numericDates: true)
                
            } else {
                self.headerView.timeLbl.text = ""
            }
            
            
            if let url = URL(string: post.streamUrl), !post.streamUrl.isEmpty {
                if let domain = url.host {
                    if check_Url(host: domain) {
                        self.buttonsView.hostLbl.text = "  \(domain)  "
                    } else {
                        self.buttonsView.hostLbl.isHidden = true
                        self.buttonsView.streamView.isHidden = true
                    }
                } else {
                    self.buttonsView.hostLbl.isHidden = true
                    self.buttonsView.streamView.isHidden = true
                }
            } else {
                self.buttonsView.hostLbl.isHidden = true
                self.buttonsView.streamView.isHidden = true
            }

            
            
            
            
            /*
             streamlinkBtn
             */
         
            self.checkIfLike()
            self.totalLikeCount()
            self.totalCmtCount()
            
            
        }
       
        
        automaticallyManagesSubnodes = true
        self.imageNode.contentMode = .scaleAspectFill
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        headerNode.backgroundColor = UIColor.clear
        buttonsNode.backgroundColor = UIColor.clear
        
        self.contentNode.attributedText = NSAttributedString(string: post.content, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        
        
        if post.muxPlaybackId != "" {
            self.videoNode.url = self.getThumbnailVideoNodeURL(post: post)
            self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
            self.videoNode.shouldAutoplay = false
            self.videoNode.shouldAutorepeat = true
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            self.videoNode.contentMode = .scaleAspectFill
            self.videoNode.muted = false
            self.videoNode.delegate = self
            
            
            DispatchQueue.main.async {
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
 
            }
        } else {
            
            
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
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
    
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
       
        let headerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)
        
        
        var children: [ASLayoutElement] = [headerInsetSpec]
        
        let mediaSize: CGSize
        
        if post.content != "" {
            
            let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
            let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
            children.append(contentInsetSpec)
        }
        
        hashtagsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 25)
        
        let hashtagsInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        let hashtagsInsetSpec = ASInsetLayoutSpec(insets: hashtagsInset, child: hashtagsNode)
        
        
        children.append(hashtagsInsetSpec)
        
        if post.metadata?.width == post.metadata?.height {
            mediaSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width)
        } else {
            
            var newHeight = constrainedSize.max.width * (post.metadata?.height ?? constrainedSize.max.width) / (post.metadata?.width ?? constrainedSize.max.width)
            
            if newHeight > constrainedSize.max.height * 0.65 {
                newHeight = constrainedSize.max.height * 0.65
            } else if newHeight <= constrainedSize.max.height * 0.45 {
                newHeight = constrainedSize.max.height * 0.45
            }
            
            mediaSize = CGSize(width: constrainedSize.max.width, height: newHeight)
        }
        
        if post.muxPlaybackId != "" {
            
            sidebuttonListView.style.preferredSize = CGSize(width: 100, height: 60)
            videoNode.style.preferredSize = mediaSize
            gradientNode.style.preferredSize = mediaSize
            
            let sidebuttonListInset = UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 0, right: 0)
            let sidebuttonListInsetSpec = ASInsetLayoutSpec(insets: sidebuttonListInset, child: sidebuttonListView)
            
            let firsOverlay = ASOverlayLayoutSpec(child: videoNode, overlay: gradientNode)
            let secondOverlay = ASOverlayLayoutSpec(child: firsOverlay, overlay: sidebuttonListInsetSpec)
            
            children.append(secondOverlay)
            
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
    
    func setVideoProgress(rate: Float) {
        
        
        if let vc = UIViewController.currentViewController() {
            
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    update1.playTimeBar.setProgress(rate, animated: true)
                    
                }
                
            } else if vc is SelectedPostVC {
                
                if let update2 = vc as? SelectedPostVC {
                    
                    update2.playTimeBar.setProgress(rate, animated: true)
                    
                }
                
                
            }
                 
            
        }
        
        
        
    }
    

}

extension PostNode {
    
    
    func didTap(_ videoNode: ASVideoNode) {
        
        soundProcess()
      
    }
    
    @objc func soundProcess() {
        
        if videoNode.isPlaying() {
            
            if videoNode.muted == true {
                videoNode.muted = false
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.sideButtonView.soundBtn.transform = self.sideButtonView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                    self.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                          self.sideButtonView.soundBtn.transform = CGAffineTransform.identity
                      })
                    })
        
            } else {
                videoNode.muted = true
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.sideButtonView.soundBtn.transform = self.sideButtonView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                    self.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                          self.sideButtonView.soundBtn.transform = CGAffineTransform.identity
                      })
                    })
            }
            
        }
        
    }
    
    
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        
        //currentTimeStamp = timeInterval
        
        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.asset.duration.seconds)!))
    
        /*
        if (videoNode.currentItem?.asset.duration.seconds)! <= 15 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.8 {
                
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
               
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 15, (videoNode.currentItem?.asset.duration.seconds)! <= 30 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.7 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 30, (videoNode.currentItem?.asset.duration.seconds)! <= 60 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.6 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 60 , (videoNode.currentItem?.asset.duration.seconds)! <= 90 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 90, (videoNode.currentItem?.asset.duration.seconds)! <= 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.4 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        }
        */
        
    }
    
    
}


extension PostNode {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
    
    
        hashtagView.collectionView.delegate = dataSourceDelegate
        hashtagView.collectionView.dataSource = dataSourceDelegate
        hashtagView.collectionView.tag = row
        hashtagView.collectionView.setContentOffset(hashtagView.collectionView.contentOffset, animated:true) // Stops collection view if it was scrolling.
        hashtagView.collectionView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
        hashtagView.collectionView.reloadData()
        
    }

}


extension PostNode {
    
    
    @objc func userTapped() {
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
                
                let nav = UINavigationController(rootViewController: UPVC)
                
                UPVC.userId = post.owner?.id
                UPVC.nickname = post.owner?.username
                UPVC.onPresent = true
                nav.modalPresentationStyle = .fullScreen
                nav.navigationItem.titleView?.tintColor = .white
                nav.navigationBar.tintColor = .background
                vc.present(nav, animated: true, completion: nil)
       
            }
        }
        
        
    }
    
    @objc func shareTapped() {
        
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        let loadUsername = userDataSource.userName
        
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://dualteam.page.link/dual?p=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is SelectedPostVC {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    update1.present(ac, animated: true, completion: nil)
                    
                }
                
            } else if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    update1.present(ac, animated: true, completion: nil)
                    
                }
                
            }
            
            
        }
        
        
    }
    
    
    @objc func cmtTapped() {
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is SelectedPostVC {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    let slideVC = CommentVC()
                    
                    slideVC.post = self.post
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    update1.present(slideVC, animated: true, completion: nil)
                    
                }
                
            } else if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
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
        guard let url = URL(string: post.streamUrl), !post.streamUrl.isEmpty else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }


    @objc func likeHandle() {
        
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "likePopUp")
        imgView.frame.size = CGSize(width: 120, height: 120)
       
        if let vc = UIViewController.currentViewController() {
             
            if vc is SelectedPostVC {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    imgView.center = update1.view.center
                    update1.view.addSubview(imgView)
                    
                }
                
            } else if vc is FeedViewController {
                
                if let update2 = vc as? FeedViewController {
                    
                    imgView.center = update2.view.center
                    update2.view.addSubview(imgView)
                    
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
                        self.buttonsView.likeBtn.setImage(UIImage(named: "liked")?.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.buttonsView.likeBtn.setImage(UIImage(named: "likeEmpty")?.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
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
            self.buttonsView.likeBtn.setImage(UIImage(named: "liked")?.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
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
            self.buttonsView.likeBtn.setImage(UIImage(named: "likeEmpty")?.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
            })
        
    }

}

extension PostNode {
    
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


