//
//  SelectedPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/2/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage

class SelectedPostVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    
    deinit {
        print("SelectedPostVC is being deallocated.")
    }
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    var selectedPost = [PostModel]()
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var startIndex: Int!
    var currentIndex: Int?
    var imageIndex: Int?
    var imageTimerWorkItem: DispatchWorkItem?
    var hasViewAppeared = false
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    var firstAnimated = true
    var onPresent = false
    var selectedIndex = 0
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupCollectionNode()
        
        loadPosts()
       
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickDelete), name: (NSNotification.Name(rawValue: "delete")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickEdit), name: (NSNotification.Name(rawValue: "edit")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickShare), name: (NSNotification.Name(rawValue: "share")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickStats), name: (NSNotification.Name(rawValue: "stats")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickDownload), name: (NSNotification.Name(rawValue: "download")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickCopyLink), name: (NSNotification.Name(rawValue: "copyLink")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.removePost), name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.copyPost), name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.copyPost), name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.reportPost), name: (NSNotification.Name(rawValue: "report_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.removePost), name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.sharePost), name: (NSNotification.Name(rawValue: "share_post_selected")), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch_selected")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one_selected")), object: nil)
        
        setupNavBar()
        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.isTranslucent = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hasViewAppeared = true
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupNavBar()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAnimated {
            firstAnimated = false
            do {
                
                let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                let gifData = try NSData(contentsOfFile: path) as Data
                let image = FLAnimatedImage(animatedGIFData: gifData)
                
                
                self.loadingImage.animatedImage = image
                
            } catch {
                print(error.localizedDescription)
            }
            
            loadingView.backgroundColor = .white
            navigationController?.setNavigationBarHidden(false, animated: true)
      
            
            delay(1) {
                
                UIView.animate(withDuration: 0.5) {
                    
                    self.loadingView.alpha = 0
                    
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    if self.loadingView.alpha == 0 {
                        
                        self.loadingView.isHidden = true
                        
                    }
                    
                }
                
            }
            
        }
        
        
        setupNavBar()
        
        if currentIndex != nil {
            //newPlayingIndex
            
            if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                
                if node.currentIndex != nil {
                    node.playVideo(index: node.currentIndex!)
                }
                
            }

            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hasViewAppeared = false
        
        if currentIndex != nil {
            //newPlayingIndex
            
            if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                
                if node.currentIndex != nil {
                    node.pauseVideo(index: node.currentIndex!)
                }
                
            }
                  
        }
        
    }
    
    func setupNavBar() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundEffect = nil

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.isTranslucent = true

        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
}


extension SelectedPostVC {
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
        
    }
    
}


extension SelectedPostVC {
    
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           guard !posts.isEmpty, scrollView == collectionNode.view else {
               return
           }

           let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
           let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? OriginalNode }
           
           var minDistanceFromCenter = CGFloat.infinity
           var newPlayingIndex: Int? = nil
           var foundVisibleVideo = false

           for cell in visibleCells {
               let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
               let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
               let distanceFromCenter = abs(cellCenter.y - visibleRect.midY)
               
               if distanceFromCenter < minDistanceFromCenter {
                   newPlayingIndex = cell.indexPath?.row
                   minDistanceFromCenter = distanceFromCenter
               }
           }

           guard let newPlayingIndex = newPlayingIndex, let currentCell = collectionNode.nodeForItem(at: IndexPath(item: currentIndex ?? 0, section: 0)) as? OriginalNode, let newPlayingCell = collectionNode.nodeForItem(at: IndexPath(item: newPlayingIndex, section: 0)) as? OriginalNode else {
               return
           }
           
           // Safe guard for Array Out-of-Bounds
           guard newPlayingCell.currentIndex != nil && newPlayingCell.currentIndex! < newPlayingCell.posts.count else {
               return
           }
           
           if !newPlayingCell.posts[newPlayingCell.currentIndex!].muxPlaybackId.isEmpty {
               foundVisibleVideo = true
               imageIndex = nil
           } else {
               imageIndex = newPlayingIndex
           }

           if foundVisibleVideo {
               if currentIndex != newPlayingIndex {
                   if let currentIndex = currentCell.currentIndex {
                       currentCell.pauseVideo(index: currentIndex)
                   }

                   currentIndex = newPlayingIndex
                   newPlayingCell.playVideo(index: newPlayingCell.currentIndex ?? 0)

                   if let node = newPlayingCell.collectionNode.nodeForItem(at: IndexPath(item: newPlayingCell.currentIndex ?? 0, section: 0)) as? ReelNode {
                       resetView(cell: node)
                   }
               }
           } else {
               print("Couldn't find foundVisibleVideo")
           }

           if let currentIndex = newPlayingCell.currentIndex, let cell = newPlayingCell.collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? ReelNode {
               if let playerItem = cell.videoNode.currentItem, !playerItem.isPlaybackLikelyToKeepUp {
                   if let currentTime = cell.videoNode.currentItem?.currentTime() {
                       cell.videoNode.player?.seek(to: currentTime)
                   } else {
                       cell.videoNode.player?.seek(to: CMTime.zero)
                   }
               }
           }
       }

}


extension SelectedPostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.contentView.layer.frame.width, height: 50);
        let max = CGSize(width: self.contentView.layer.frame.width, height: contentView.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return false
    }
    
}

extension SelectedPostVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = OriginalNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
        
            
            return node
        }
    }

    
}

extension SelectedPostVC {
    
    func loadPosts() {
        // Ensure that there are posts to load
        guard !selectedPost.isEmpty else {
            return
        }

        // Append the `selectedPost` items to the `posts` array and update the `indexPaths` array with the new index paths.
        let indexPaths = selectedPost.enumerated().map { index, _ in
            return IndexPath(row: self.posts.count + index, section: 0)
        }
        self.posts.append(contentsOf: selectedPost)

        // It's better to insert items rather than reloading the whole collectionNode
        // If you are using UICollectionView, the method should be insertItems(at:)
        self.collectionNode.performBatchUpdates({
            self.collectionNode.insertItems(at: indexPaths)
        }, completion: nil)
        
        // If the `startIndex` is not `nil`, scroll to the item at the `startIndex` index path, and delay the play of the video for 0.25 seconds.
        guard let startIndex = self.startIndex else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: startIndex, section: 0)
            self.collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

            guard let currentCell = self.collectionNode.nodeForItem(at: indexPath) as? OriginalNode else {
                self.isVideoPlaying = false
                self.playTimeBar.isHidden = true
                return
            }

            // Update the playing status of the cell
            currentIndex = startIndex
            newPlayingIndex = startIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                
                
                currentCell.currentIndex = 0
                currentCell.newPlayingIndex = 0
                currentCell.isVideoPlaying = true
                currentCell.playVideo(index: 0)

                

            }
            
            

        }

    }


    
}

extension SelectedPostVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        self.collectionNode.backgroundColor = .black
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        //self.collectionNode.view.isScrollEnabled = false
        
        self.applyStyle()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
}


extension SelectedPostVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
        
    }
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    func setupTitle() {
        
        self.navigationItem.title = ""
        
        
    }
    
}


extension SelectedPostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "delete")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "edit")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "share")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "stats")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "download")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copyLink")), object: nil)
            
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_profile_selected")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_post_selected")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "share_post_selected")), object: nil)
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "create_new_for_stitch_selected")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "stitch_to_exist_one_selected")), object: nil)
           
            if onPresent {
                self.dismiss(animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
        }
    }
    
    
    @objc func onClickDelete(_ sender: AnyObject) {
        
        
        presentSwiftLoader()
        
        if let id = editeddPost?.id, id != "" {
            
            APIManager.shared.deleteMyPost(pid: id) { result in
                //guard let self = self else { return }
                
                switch result {
                case .success(_):
                    needReloadPost = true
                    
                    SwiftLoader.hide()
                    
                    Dispatch.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.removePost()
                        
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    SwiftLoader.hide()
                    
                    delay(0.1) { [weak self] in
                        guard let self = self else { return }
                        Dispatch.main.async { [weak self] in
                            guard let self = self else { return }
                            self.showErrorAlert("Oops!", msg: "Unable to delete this posts \(error.localizedDescription), please try again")
                        }
                        
                    }
                    
                }
            }
            
        } else {
            
            delay(0.1) { [weak self] in
                guard let self = self else { return }
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: "Unable to delete this posts, please try again")
            }
            
        }
        
        
    }
    
    @objc func onClickEdit(_ sender: AnyObject) {
        
        print("Edit requested")
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC {
            
            navigationController?.setNavigationBarHidden(false, animated: true)
            EPVC.selectedPost = editeddPost
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
        
    }
    
    @objc func onClickShare(_ sender: AnyObject) {
        
        print("Share requested")
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        if let postID = editeddPost?.id, postID != "" {
            
            let items: [Any] = ["Hi I am \(userDataSource.userName ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(postID)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                
                
            }
            
            delay(0.1) { [weak self] in
                guard let self = self else { return }
                self.present(ac, animated: true, completion: nil)
            }
            
            
        } else {
            print("Can't get postID")
        }
        
        
    }
    
    @objc func onClickStats(_ sender: AnyObject) {
        
        print("Stats requested")
        if let VVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ViewVC") as? ViewVC {
            
            
            VVC.selected_item = editeddPost
            delay(0.1) { [weak self] in
                guard let self = self else { return }
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.pushViewController(VVC, animated: true)
            }
            
        }
        
    }
    
    @objc func onClickCopyLink(_ sender: AnyObject) {
        
        if let postID = editeddPost?.id, postID != "" {
            
            let link = "https://stitchbox.gg/app/post/?uid=\(postID)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            print("Can't get postID")
        }
        
        
    }
    
    @objc func onClickDownload(_ sender: AnyObject) {
        
        if let post = editeddPost {
            
            if post.muxPlaybackId != "" {
                
                let url = "https://stream.mux.com/\(post.muxPlaybackId)/high.mp4"
                
                downloadVideo(url: url, id: post.muxAssetId)
                
            } else {
                
                if let data = try? Data(contentsOf: post.imageUrl) {
                    
                    downloadImage(image: UIImage(data: data)!)
                    
                }
                
            }
            
        }
        
        
    }
    
    func downloadVideo(url: String, id: String) {
         
        AF.request(url).downloadProgress(closure : { (progress) in
            
            self.swiftLoader(progress: "\(String(format:"%.2f", Float(progress.fractionCompleted) * 100))%")
            
        }).responseData{ (response) in
            
            switch response.result {
                
            case let .success(value):
                
                
                let data = value
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { saved, error in
                    
                    
                    DispatchQueue.main.async {
                        
                        SwiftLoader.hide()
                    }
                    
                    if (error != nil) {
                        
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            print("Error: \(error!.localizedDescription)")
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                        }
                        
                    } else {
                        
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                        
                    }
                }
                
            case let .failure(error):
                print(error)
                
            }
            
            
        }
        
    }
    
    func downloadImage(image: UIImage) {
        
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: image)
        
    }
    
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
    
    
}


extension SelectedPostVC {
    
    func settingPost(item: PostModel) {
        
        if item.owner?.id == _AppCoreData.userDataSource.value?.userID {
            
            let postSettingVC = PostSettingVC()
            postSettingVC.modalPresentationStyle = .custom
            postSettingVC.transitioningDelegate = self
            
            global_presetingRate = Double(0.35)
            global_cornerRadius = 45
            editeddPost = item
            self.present(postSettingVC, animated: true, completion: nil)
            
        } else {
            
            let newsFeedSettingVC = NewsFeedSettingVC()
            newsFeedSettingVC.modalPresentationStyle = .custom
            newsFeedSettingVC.transitioningDelegate = self
            
            global_presetingRate = Double(0.35)
            global_cornerRadius = 45
            newsFeedSettingVC.isOwner = false
            newsFeedSettingVC.isSelected = true
            editeddPost = item
            self.present(newsFeedSettingVC, animated: true, completion: nil)
            
            
        }
        
    }
    
}


extension SelectedPostVC {
    
    
    @objc func copyPost() {
        
        if let id = self.editeddPost?.id {
            
            let link = "https://stitchbox.gg/app/post/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            showNote(text: "Post link is unable to be copied")
        }
        
    }
    
    @objc func copyProfile() {
        
        if let id = self.editeddPost?.owner?.id {
            
            let link = "https://stitchbox.gg/app/account/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "User profile link is copied")
            
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
        
    }
    
    @objc func removePost() {
        
        if let deletingPost = editeddPost {
            
            if let indexPath = posts.firstIndex(of: deletingPost) {
                
                posts.removeObject(deletingPost)
                
                // check if there are no more posts
                if posts.isEmpty {
                    if onPresent {
                        self.dismiss(animated: true)
                    } else {
                        navigationController?.popViewController(animated: true)
                    }
                } else {
                    
                    collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
 
                }
            } else {
                
                if currentIndex != nil {
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                        
                        if let indexPath = node.posts.firstIndex(of: deletingPost) {
                            
                            node.posts.removeObject(deletingPost)

                            node.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            node.selectPostCollectionView.collectionView.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            // return the next index if it exists
                            if indexPath < node.posts.count {
                                node.playVideo(index: indexPath)
                            } else if node.posts.count == 1 {
                                node.playVideo(index: 0)
                            }
                        }
                        
                    }
                }
               
                
            }
            
        }
        
    }
    

    @objc func reportPost() {
        
        let slideVC = reportView()
        
        slideVC.post_report = true
        slideVC.postId = editeddPost?.id ?? ""
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = Double(0.75)
        global_cornerRadius = 35
        
        delay(0.1) { [weak self] in
            guard let self = self else { return }
            self.present(slideVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func sharePost() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        let loadUsername = userDataSource.userName
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(editeddPost?.id ?? "")")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        delay(0.1) { [weak self] in
            guard let self = self else { return }
            self.present(ac, animated: true, completion: nil)
        }
        
    }
    
    
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            cell.videoNode.pause()
            
        }
        
    }
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func playVideo(index: Int) {
        
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            if !cell.videoNode.isPlaying() {
                
                
                if let muteStatus = shouldMute {
                    
                    if muteStatus {
                        cell.videoNode.muted = true
                    } else {
                        cell.videoNode.muted = false
                    }
                    
                    cell.videoNode.play()
                    
                } else {
                    
                   
                    if globalIsSound {
                        cell.videoNode.muted = false
                    } else {
                        cell.videoNode.muted = true
                    }
                    
                    cell.videoNode.play()
                    
                }
 
              
            }
            
        }
        
    }
    
    @objc func createPostForStitch() {
        
        if let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC {
            
            
            PNVC.modalPresentationStyle = .fullScreen
            
            if let rootvc = PNVC.viewControllers[0] as? PostVC {
                rootvc.stitchPost = editeddPost
            } else {
                printContent(PNVC.viewControllers[0])
            }
            
            delay(0.1) {
                
                self.present(PNVC, animated: true)
            }
            
        }
        
    }
    
    
    @objc func stitchToExistingPost() {
        
        if let ASTEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddStitchToExistingVC") as? AddStitchToExistingVC {
            
            ASTEVC.hidesBottomBarWhenPushed = true
            ASTEVC.stitchedPost = editeddPost
            
            delay(0.1) {
                self.navigationController?.pushViewController(ASTEVC, animated: true)
            }
            
        }
        
        
    }
    
    
}
