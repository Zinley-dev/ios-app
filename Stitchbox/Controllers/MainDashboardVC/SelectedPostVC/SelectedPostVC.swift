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

class SelectedPostVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
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
    var currentIndex: Int!
    var imageIndex: Int?
    var imageTimerWorkItem: DispatchWorkItem?
    var hasViewAppeared = false
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    
    var isfirstLoad = true
    var onPresent = false
    var selectedIndex = 0
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.copyPost), name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.reportPost), name: (NSNotification.Name(rawValue: "report_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.removePost), name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.sharePost), name: (NSNotification.Name(rawValue: "share_post_selected")), object: nil)
        
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
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        
        if currentIndex != nil {
            
            if posts[currentIndex].muxPlaybackId != "" {
                playVideo(index: currentIndex)
            }
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hasViewAppeared = false
        
        if currentIndex != nil {
            
            if posts[currentIndex].muxPlaybackId != "" {
                pauseVideo(index: currentIndex)
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
        
        if !posts.isEmpty, scrollView == collectionNode.view {
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? ReelNode }
            
            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            
            var foundVisibleVideo = false
            
            for cell in visibleCells {
                
                let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                let distanceFromCenter = abs(cellCenter.y - visibleRect.midY)
                if distanceFromCenter < minDistanceFromCenter {
                    newPlayingIndex = cell.indexPath!.row
                    minDistanceFromCenter = distanceFromCenter
                }
            }
            
            
            if !posts[newPlayingIndex!].muxPlaybackId.isEmpty {
                
                foundVisibleVideo = true
                playTimeBar.isHidden = false
                imageIndex = nil
            } else {
                playTimeBar.isHidden = true
                imageIndex = newPlayingIndex
            }
            
            
            if foundVisibleVideo {
                
                // Start playing the new video if it's different from the current playing video.
                if let newPlayingIndex = newPlayingIndex, currentIndex != newPlayingIndex {
                    // Pause the current video, if any.
                    if let currentIndex = currentIndex {
                        pauseVideo(index: currentIndex)
                    }
                    // Play the new video.
                    currentIndex = newPlayingIndex
                    playVideo(index: currentIndex!)
                    isVideoPlaying = true
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? ReelNode {
                        
                        resetView(cell: node)
                        
                    }
                    
                }
                
            } else {
                
                if let currentIndex = currentIndex {
                    pauseVideo(index: currentIndex)
                }
                
                imageTimerWorkItem?.cancel()
                imageTimerWorkItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    if self.imageIndex != nil {
                        if let node = self.collectionNode.nodeForItem(at: IndexPath(item: self.imageIndex!, section: 0)) as? ReelNode {
                            if self.imageIndex == self.newPlayingIndex {
                                resetView(cell: node)
                                node.endImage(id: node.post.id)
                            }
                        }
                    }
                }
                
                if let imageTimerWorkItem = imageTimerWorkItem {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: imageTimerWorkItem)
                }
                
                
                // Reset the current playing index.
                currentIndex = nil
                
            }
            
            
            // If the video is stuck, reset the buffer by seeking to the current playback time.
            if let currentIndex = currentIndex, let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? ReelNode {
                if let playerItem = cell.videoNode.currentItem, !playerItem.isPlaybackLikelyToKeepUp {
                    if let currentTime = cell.videoNode.currentItem?.currentTime() {
                        cell.videoNode.player?.seek(to: currentTime)
                    } else {
                        cell.videoNode.player?.seek(to: CMTime.zero)
                    }
                }
            }
            
            
            // If there's no current playing video and no visible video, pause the last playing video, if any.
            if !isVideoPlaying && currentIndex != nil {
                pauseVideo(index: currentIndex!)
                currentIndex = nil
            }
            
        }
        
        
    }
    
    
}

extension SelectedPostVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath) as! HashtagCell

        // Check if collectionView.tag is within the range of the posts array
        guard collectionView.tag < posts.count else {
            print("Error: No post for tag \(collectionView.tag)")
            cell.hashTagLabel.text = "Error: post not found"
            return cell
        }
        
        let item = posts[collectionView.tag]

        // Check if indexPath.row is within the range of the hashtags array
        guard indexPath.row < item.hashtags.count else {
            print("Error: No hashtag for index \(indexPath.row)")
            cell.hashTagLabel.text = "Error: hashtag not found"
            return cell
        }

        cell.hashTagLabel.text = item.hashtags[indexPath.row]
        cell.backgroundColor = .clear
        cell.hashTagLabel.backgroundColor = .clear
        return cell
    }

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag < posts.count {
            return posts[collectionView.tag].hashtags.count
        } else {
            // Handle the condition when there are no posts at the given index
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    }
    
}

extension SelectedPostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: contentView.frame.height);
        
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
            let node = ReelNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.isSelectedPost = true
            
            node.settingBtn = { (node) in
                
                self.settingPost(item: post)
                
            }
            
            delay(0.3) {
                if node.hashtagView != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                    node.hashtagView.collectionView.reloadData()
                }
            }
            
            //
            return node
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedHashtag = posts[collectionView.tag].hashtags[indexPath.row]
        
        if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
            
            navigationController?.setNavigationBarHidden(false, animated: true)
            PLWHVC.searchHashtag = selectedHashtag
            self.navigationController?.pushViewController(PLWHVC, animated: true)
            
        }
        
        
        
    }
    
}

extension SelectedPostVC {
    
    func loadPosts() {
        // 1. Check if the `selectedPost` array has any items. If it does not, return immediately.
        guard selectedPost.count > 0 else {
            return
        }
        
        // 3. Append the `selectedPost` items to the `posts` array, and update the `indexPaths` array with the new index paths.
        let section = 0
        var items = [PostModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + selectedPost.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for item in selectedPost {
            items.append(item)
        }
        
        self.posts.append(contentsOf: items)
        self.collectionNode.reloadData()
        
        // 4. If the `startIndex` is not `nil`, scroll to the item at the `startIndex` index path, and delay the play of the video for 0.25 seconds.
        guard startIndex != nil else {
            return
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) { [weak self] in
            guard let self = self else { return }
            self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .centeredVertically, animated: false)
            
            if !self.posts[self.startIndex].muxPlaybackId.isEmpty {
                
                self.currentIndex = self.startIndex
                self.newPlayingIndex = self.startIndex
                self.playVideo(index: self.startIndex)
                self.isVideoPlaying = true
                self.playTimeBar.isHidden = false
                
            } else {
                self.isVideoPlaying = false
                self.playTimeBar.isHidden = true
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
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        
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
        
        self.navigationItem.title = "Posts"
        
        
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
                    
                    Dispatch.main.async {
                        
                        self.removePost()
                        
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    SwiftLoader.hide()
                    
                    delay(0.1) {
                        Dispatch.main.async {
                            self.showErrorAlert("Oops!", msg: "Unable to delete this posts \(error.localizedDescription), please try again")
                        }
                        
                    }
                    
                }
            }
            
        } else {
            
            delay(0.1) {
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
            
            delay(0.1) {
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
            delay(0.1) {
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
                        
                        
                        DispatchQueue.main.async {
                            print("Error: \(error!.localizedDescription)")
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                        }
                        
                    } else {
                        
                        
                        DispatchQueue.main.async {
                            
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
                    reloadAllCurrentHashtag()
                    
                    delay(0.75) { [weak self] in
                        if indexPath < self?.posts.count ?? 0 {
                            self?.playVideo(index: indexPath)
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    
    
    func reloadAllCurrentHashtag() {
        if !posts.isEmpty {
            for index in 0..<posts.count {
                let indexPath = IndexPath(item: index, section: 0) // Assuming there is only one section
                if let node = collectionNode.nodeForItem(at: indexPath) as? ReelNode {
                    
                    if node.hashtagView != nil {
                        node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                        node.hashtagView.collectionView.reloadData()
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
        
        delay(0.1) {
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
        
        delay(0.1) {
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
    
}
