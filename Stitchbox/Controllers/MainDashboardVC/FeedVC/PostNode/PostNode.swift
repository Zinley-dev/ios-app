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
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: ASVideoNode
    var imageNode: ASImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonsNode: ASDisplayNode
    var hashtagsNode: ASDisplayNode
    var separatorNode = ASDisplayNode()
    var sidebuttonListView: ASDisplayNode!
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var hashtagView: HashtagView!
    var sideButtonView: SideButton!
    var gradientNode: GradienView
    var time = 0
    var likeCount = 0
    var isLike = false
    var isSelectedPost = false
    var settingBtn : ((ASCellNode) -> Void)?
    var isViewed = false
    var currentTimeStamp: TimeInterval!
    
    
    init(with post: PostModel) {
        self.post = post
        self.imageNode = ASImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonsNode = ASDisplayNode()
        self.hashtagsNode = ASDisplayNode()
        self.videoNode = ASVideoNode()
        self.sidebuttonListView = ASDisplayNode()
        self.separatorNode = ASDisplayNode()
        self.gradientNode = GradienView()
        super.init()
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false
        self.separatorNode.backgroundColor = .darkGray
        
        DispatchQueue.main.async {
            
            self.headerView = PostHeader()
            self.headerNode.view.addSubview(self.headerView)
            self.headerView.settingBtn.setTitle("", for: .normal)
            
            self.headerView.translatesAutoresizingMaskIntoConstraints = false
            self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            
            if self.isSelectedPost == false {
                
                if post.owner?.id == _AppCoreData.userDataSource.value?.userID {
                    
                    self.headerView.settingBtn.isHidden = true
                    
                }
                
            }
            
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
                
                
                if let muteStatus = shouldMute {
                    
                    if muteStatus {
                        self.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                    } else {
                        self.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                    }
                    
                } else {
                    
                    if globalIsSound {
                        self.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                    } else {
                        self.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                    }
                    
                    
                }
              
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
            
            
            let username2Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.userTapped))
            username2Tap.numberOfTapsRequired = 1
            self.headerView.timeLbl.isUserInteractionEnabled = true
            self.headerView.timeLbl.addGestureRecognizer(username2Tap)
            

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
                    
                    if update1.playTimeBar != nil {
                        update1.playTimeBar.setProgress(rate, animated: true)
                    }
                    
                }
                
            } else if vc is SelectedPostVC {
                
                if let update2 = vc as? SelectedPostVC {
                    
                    if update2.playTimeBar != nil {
                        update2.playTimeBar.setProgress(rate, animated: true)
                    }
                    
                }
                
                
            } else if vc is MainSearchVC {
                
                if let update2 = vc as? MainSearchVC {
                    
                    if update2.PostSearchVC.playTimeBar != nil {
                        update2.PostSearchVC.playTimeBar.setProgress(rate, animated: true)
                    }
                   
                }
                
                
            } else if vc is PostListWithHashtagVC {
                
                if let update2 = vc as? PostListWithHashtagVC {
                    
                    if update2.playTimeBar != nil {
                        update2.playTimeBar.setProgress(rate, animated: true)
                    }
                    
                    
                }
                
                
            }
                 
            
        }
        
        
        
    }
    

}

extension PostNode {
    
    
    func didTap(_ videoNode: ASVideoNode) {
        
        if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ReelVC") as? ReelVC {
            
            if let vc = UIViewController.currentViewController() {
                
                if vc is FeedViewController || vc is MainSearchVC || vc is PostListWithHashtagVC {
            
                    let nav = UINavigationController(rootViewController: RVC)

                    // Set the user ID, nickname, and onPresent properties of UPVC
                    RVC.posts = [post]
                    
                    if vc is FeedViewController {
                        RVC.isReel = true
                    } else if vc is MainSearchVC {
                        
                        if let update1 = vc as? MainSearchVC {
                            
                
                            RVC.keyword = update1.PostSearchVC.keyword
                            
                        }
                        
                        RVC.isSearch = true
                        
                    } else if vc is PostListWithHashtagVC {
                        
                        if let update1 = vc as? PostListWithHashtagVC {
                            
                           
                            RVC.searchHashtag = update1.searchHashtag
                            
                        }
                        
                        RVC.isHashtag = true
                    }
                    
                    if let update1 = vc as? FeedViewController {
                        if let currentIndex = update1.posts.firstIndex(of: post) {
                            if currentIndex < update1.posts.count - 1 {
                                let endIndex = min(currentIndex+5, update1.posts.count-1)
                                RVC.posts.append(contentsOf: Array(update1.posts[(currentIndex+1)...endIndex]))
                            }
                        }
                    } else if let update1 = vc as? MainSearchVC {
                        if let currentIndex = update1.PostSearchVC.posts.firstIndex(of: post) {
                            if currentIndex < update1.PostSearchVC.posts.count - 1 {
                                let endIndex = min(currentIndex+5, update1.PostSearchVC.posts.count-1)
                                RVC.posts.append(contentsOf: Array(update1.PostSearchVC.posts[(currentIndex+1)...endIndex]))
                            }
                        }
                    } else if let update1 = vc as? PostListWithHashtagVC {
                        if let currentIndex = update1.posts.firstIndex(of: post) {
                            if currentIndex < update1.posts.count - 1 {
                                let endIndex = min(currentIndex+5, update1.posts.count-1)
                                RVC.posts.append(contentsOf: Array(update1.posts[(currentIndex+1)...endIndex]))
                            }
                        }
                    }


                    // Customize the navigation bar appearance
                    nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
                    nav.navigationBar.shadowImage = UIImage()
                    nav.navigationBar.isTranslucent = true

                    nav.modalPresentationStyle = .fullScreen
                    vc.present(nav, animated: true, completion: nil)
                    
                } else {
                   
                    if vc is SelectedPostVC  {
                        
                        if let update1 = vc as? SelectedPostVC {
                            
                            if update1.onPresent == true {
                                
                                let nav = UINavigationController(rootViewController: RVC)

                                // Set the user ID, nickname, and onPresent properties of UPVC
                                RVC.posts = [post]
                                
                                if let currentIndex = update1.posts.firstIndex(of: post) {
                                    if currentIndex < update1.posts.count - 1 {
                                        let endIndex = min(currentIndex+5, update1.posts.count-1)
                                        RVC.posts.append(contentsOf: Array(update1.posts[(currentIndex+1)...endIndex]))
                                    }
                                }

                                // Customize the navigation bar appearance
                                nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
                                nav.navigationBar.shadowImage = UIImage()
                                nav.navigationBar.isTranslucent = true

                                nav.modalPresentationStyle = .fullScreen
                                vc.present(nav, animated: true, completion: nil)
                                
                            } else {
                                
                                soundProcess()
                                
                            }
                            
                        }
                        
                    } else {
                        
                        soundProcess()
                        
                    }
                    
                    
                }

            }
        }
      
    }
    
    @objc func soundProcess() {
        
        if videoNode.isPlaying() {
            
            if videoNode.muted == true {
                videoNode.muted = false
                shouldMute = false
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
                shouldMute = true
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
        
        currentTimeStamp = timeInterval
        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.duration.seconds)!))
    
        
        if (videoNode.currentItem?.duration.seconds)! <= 15 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.8 {
                
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
               
            }
            
        } else if (videoNode.currentItem?.duration.seconds)! > 15, (videoNode.currentItem?.duration.seconds)! <= 30 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.7 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.duration.seconds)! > 30, (videoNode.currentItem?.duration.seconds)! <= 60 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.6 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.duration.seconds)! > 60 , (videoNode.currentItem?.duration.seconds)! <= 90 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.duration.seconds)! > 90, (videoNode.currentItem?.duration.seconds)! <= 120 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.4 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo(watchTime: Double(timeInterval))
                }
            }
            
        } else if (videoNode.currentItem?.duration.seconds)! > 120 {
            
            if timeInterval/(videoNode.currentItem?.duration.seconds)! >= 0.5 {
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
    
    func endImage(id: String) {
        
        if _AppCoreData.userDataSource.value != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
            
                APIManager.shared.createView(post: id, watchTime: 0) { result in
                    
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
                
            } else {
                
                if let vc = UIViewController.currentViewController() {
                    
                    if vc is FeedViewController {
                        
                        if let update1 = vc as? FeedViewController {
                            
                            update1.switchToProfileVC()
                            
                        }
                        
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
            
            if vc is SelectedPostVC {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    update1.present(ac, animated: true, completion: nil)
                    
                }
                
            } else if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    update1.present(ac, animated: true, completion: nil)
                    
                }
                
            } else if vc is MainSearchVC {
                
                if let update1 = vc as? MainSearchVC {
                    
                    update1.PostSearchVC.present(ac, animated: true, completion: nil)
                    
                }
                
            } else if vc is PostListWithHashtagVC {
                
                if let update1 = vc as? PostListWithHashtagVC {
                    
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
                
            } else if vc is PostListWithHashtagVC {
                
                if let update1 = vc as? PostListWithHashtagVC {
                    
                    let slideVC = CommentVC()
                    
                    slideVC.post = self.post
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    update1.present(slideVC, animated: true, completion: nil)
                    
                }
                
                
            } else if vc is MainSearchVC {
                
                if let update1 = vc as? MainSearchVC {
                    
                    let slideVC = CommentVC()
                    
                    slideVC.post = self.post
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    update1.PostSearchVC.present(slideVC, animated: true, completion: nil)
                    
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
        imgView.image = popupLikeImage
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
                
            } else if vc is MainSearchVC {
                
                if let update2 = vc as? MainSearchVC {
                    
                    imgView.center = update2.view.center
                    update2.PostSearchVC.view.addSubview(imgView)
                    
                }
                
            } else if vc is PostListWithHashtagVC {
                
                if let update2 = vc as? PostListWithHashtagVC {
                    
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
        APIManager.shared.hasLikedPost(id: post.id) { [weak self] result in
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success",
                      let checkIsLike = apiResponse.body?["islike"] as? Bool  else {
                        return
                }
                
                self?.isLike = checkIsLike
                DispatchQueue.main.async {
                    if self?.isLike == true {
                        self?.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
                    } else {
                        self?.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
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
        
        APIManager.shared.likePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                // If you need to reference self here in the future, use self?
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

extension PostNode {
    
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
            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let likeCountFromQuery = apiResponse.body?["likes"] as? Int  else {
                        return
                }
                
                self?.likeCount = likeCountFromQuery
                
                DispatchQueue.main.async {
                    self?.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(likeCountFromQuery)))"
                }
               
            case .failure(let error):
                print("LikeCount: \(error)")
            }
        }
        
    }
    
    func totalCmtCount() {
        
        APIManager.shared.countComment(post: post.id) { [weak self] result in
            switch result {
            case .success(let apiResponse):
             
                guard apiResponse.body?["message"] as? String == "success",
                      let commentsCountFromQuery = apiResponse.body?["comments"] as? Int  else {
                        return
                }
                
                DispatchQueue.main.async {
                    self?.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(commentsCountFromQuery)))"
                }
                
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
        
    }
    
}



extension PostNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        setupHeaderNode(constrainedSize: constrainedSize)
        setupContentNode()

        // Set the preferred size for the separator node
        separatorNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 1)

        let children: [ASLayoutElement] = [
            createHeaderInsetSpec(),
            createContentInsetSpecIfNeeded(),
            createHashtagsInsetSpecIfNeeded(constrainedSize: constrainedSize),
            createMediaOverlaySpec(constrainedSize: constrainedSize),
            createButtonsInsetSpec(constrainedSize: constrainedSize),
            separatorNode
        ].compactMap { $0 }

        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = children

        return verticalStack
    }


    private func setupHeaderNode(constrainedSize: ASSizeRange) {
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
    }

    private func setupContentNode() {
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
    }

    private func createHeaderInsetSpec() -> ASInsetLayoutSpec {
        let headerInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        return ASInsetLayoutSpec(insets: headerInset, child: headerNode)
    }

    private func createContentInsetSpecIfNeeded() -> ASInsetLayoutSpec? {
        guard post.content != "" else { return nil }

        let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        return ASInsetLayoutSpec(insets: contentInset, child: contentNode)
    }

    private func createHashtagsInsetSpecIfNeeded(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec? {
        guard !post.hashtags.isEmpty else { return nil }

        hashtagsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 30)
        let hashtagsInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        return ASInsetLayoutSpec(insets: hashtagsInset, child: hashtagsNode)
    }

    private func createMediaOverlaySpec(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let mediaSize = calculateMediaSize(constrainedSize: constrainedSize)

        if post.muxPlaybackId != "" {
            return createVideoOverlaySpec(mediaSize: mediaSize)
        } else {
            imageNode.style.preferredSize = mediaSize
            return ASWrapperLayoutSpec(layoutElement: imageNode)
        }
    }

    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        buttonsNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 95)
        let buttonsInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonsNode)
    }

    private func calculateMediaSize(constrainedSize: ASSizeRange) -> CGSize {
        let originalWidth = CGFloat(post.metadata?.width ?? 1)
        let originalHeight = CGFloat(post.metadata?.height ?? 1)

        if originalWidth == 0 || originalHeight == 0 {
            return CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width * 4 / 5) // default to 4:5 aspect ratio
        }

        let aspectRatio = originalHeight / originalWidth
        let maxWidth = constrainedSize.max.width

        let minAspectRatio: CGFloat = 4 / 5 // 4:5 (portrait)
        let maxAspectRatio: CGFloat = 1.91 / 1 // 1.91:1 (landscape)

        let clampedAspectRatio = max(min(aspectRatio, maxAspectRatio), minAspectRatio)

        let newWidth = maxWidth
        let navigationBarHeight = navigationControllerHeight
        let tabBarHeight = tabBarControllerHeight
        let availableHeight = constrainedSize.max.height - 200 - navigationBarHeight - tabBarHeight
        let newHeight = min(maxWidth * clampedAspectRatio, availableHeight)

        return CGSize(width: newWidth, height: newHeight)
    }



    private func createVideoOverlaySpec(mediaSize: CGSize) -> ASLayoutSpec {
        sidebuttonListView.style.preferredSize = CGSize(width: 100, height: 60)
        videoNode.style.preferredSize = mediaSize
        gradientNode.style.preferredSize = mediaSize

        let sidebuttonListInset = UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 0, right: 0)
        let sidebuttonListInsetSpec = ASInsetLayoutSpec(insets: sidebuttonListInset, child: sidebuttonListView)

        let firstOverlay = ASOverlayLayoutSpec(child: videoNode, overlay: gradientNode)
        let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: sidebuttonListInsetSpec)

        return secondOverlay
    }


    
}
