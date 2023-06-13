//
//  PostSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire

class PostSearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    
    var page = 1
    var keyword = ""
    var prev_keyword = ""
    var post_list = [PostModel]()
    
    
    var currentIndex: Int?
    var imageIndex: Int?
    
    
    var isfirstLoad = true
    var didScroll = false
    
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var refresh_request = false
    var startIndex: Int!
    var imageTimerWorkItem: DispatchWorkItem?
    
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    private var pullControl = UIRefreshControl()
    
    
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollectionNode()
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentIndex != nil {
            //newPlayingIndex
            pauseVideo(index: currentIndex!)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentIndex != nil {
            //newPlayingIndex
            playVideo(index: currentIndex!)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PostSearchVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile_search")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostSearchVC.copyPost), name: (NSNotification.Name(rawValue: "copy_post_search")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostSearchVC.reportPost), name: (NSNotification.Name(rawValue: "report_post_search")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostSearchVC.removePost), name: (NSNotification.Name(rawValue: "remove_post_search")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostSearchVC.sharePost), name: (NSNotification.Name(rawValue: "share_post_search")), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_profile_search")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_post_search")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_post_search")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "remove_post_search")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "share_post_search")), object: nil)
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    @objc func clearAllData() {
        
        refresh_request = true
        currentIndex = 0
        isfirstLoad = true
        didScroll = false
        shouldMute = nil
        page = 1
        updateData()
        
    }
    
    
    func updateData() {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            if newPosts.count > 0 {
                
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                
            } else {
                
                self.refresh_request = false
                self.posts.removeAll()
                self.collectionNode.reloadData()
                
            }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            self.delayItem.perform(after: 0.75) {
                
                
                self.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                
                
                
            }
            
            
        }
        
        
    }
    
    
}


extension PostSearchVC {
    
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


extension PostSearchVC {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if this is the first visible cell and it contains a video.
        
        if isfirstLoad {
            isfirstLoad = false
            let post = posts[0]
            if !post.muxPlaybackId.isEmpty {
                currentIndex = 0
                newPlayingIndex = 0
                playVideo(index: currentIndex!)
                isVideoPlaying = true
            }
            
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !posts.isEmpty, scrollView == collectionNode.view {
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? PostNode }
            
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
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? PostNode {
                        
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
                        if let node = self.collectionNode.nodeForItem(at: IndexPath(item: self.imageIndex!, section: 0)) as? PostNode {
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
            if let currentIndex = currentIndex, let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {
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


extension PostSearchVC {
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedHashtag = posts[collectionView.tag].hashtags[indexPath.row]
        
        if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
            
            PLWHVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            PLWHVC.searchHashtag = selectedHashtag
            self.navigationController?.pushViewController(PLWHVC, animated: true)
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    }
    
}

extension PostSearchVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: view.bounds.height + 200);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}


extension PostSearchVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            node.settingBtn = { (node) in
                
                self.settingPost(item: post)
                
            }
            
            delay(0.3) {
                if node.hashtagView != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                }
            }
            
            //
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            retrieveNextPageWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                self.cleanupPosts(collectionNode: collectionNode)
                
                context.completeBatchFetching(true)
            }
        } else {
            context.completeBatchFetching(true)
        }
    }

    private func cleanupPosts(collectionNode: ASCollectionNode) {
        let postThreshold = 100
        let postsToRemove = 50
        let startIndex = 15

        if self.posts.count > postThreshold {
            // check if we have enough posts to remove
            if (startIndex + postsToRemove) <= self.posts.count {
                // remove the posts from startIndex to startIndex + postsToRemove
                self.posts.removeSubrange(startIndex..<(startIndex + postsToRemove))

                // generate the index paths for old posts
                let indexPathsToRemove = Array(startIndex..<(startIndex + postsToRemove)).map { IndexPath(row: $0, section: 0) }

                // delete the old posts from collectionNode
                collectionNode.performBatchUpdates({
                    collectionNode.deleteItems(at: indexPathsToRemove)
                }, completion: nil)
            }
        }
    }


}



extension PostSearchVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.minimumInteritemSpacing = 5.0
        //flowLayout.minimumLineSpacing = 5.0
        //flowLayout.estimatedItemSize = .zero
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.contentview.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentview.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentview.leadingAnchor, constant: -1).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentview.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentview.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
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
    
    func searchRequest() {
        
        
        if prev_keyword == "" || prev_keyword != keyword {
            
            prev_keyword = keyword
            clearAllData()
            
        }
        
        
        
    }
    
}



extension PostSearchVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        if keyword != "" {
            
            APIManager.shared.searchPost(query: keyword, page: page) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                        return
                    }
                    if !data.isEmpty {
                        print("Successfully retrieved \(data.count) posts.")
                        let items = data
                        self.page += 1
                        DispatchQueue.main.async {
                            block(items)
                        }
                    } else {
                        
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                    }
                case .failure(let error):
                    print(error)
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                }
            }
            
        } else {
            
            let item = [[String: Any]]()
            DispatchQueue.main.async {
                block(item)
            }
        }
        
        
        
    }
    
    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {

        // checking empty
        guard newPosts.count > 0 else {
            return
        }

        if refresh_request {

            refresh_request = false

            if !self.posts.isEmpty {
                var delete_indexPaths: [IndexPath] = []
                for row in 0..<self.posts.count {
                    let path = IndexPath(row: row, section: 0) // single indexpath
                    delete_indexPaths.append(path) // append
                }

                self.posts.removeAll()
                self.collectionNode.deleteItems(at: delete_indexPaths)
            }
        }

        // Create new PostModel objects and append them to the current posts
        var items = [PostModel]()
        for i in newPosts {
            if let item = PostModel(JSON: i) {
                if !self.posts.contains(item) {
                    self.posts.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.posts.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.collectionNode.insertItems(at: indexPaths)
        }
    }


    
    
}


extension PostSearchVC {
    
    func settingPost(item: PostModel) {
        
        let newsFeedSettingVC = NewsFeedSettingVC()
        newsFeedSettingVC.modalPresentationStyle = .custom
        newsFeedSettingVC.transitioningDelegate = self
        
        global_presetingRate = Double(0.35)
        global_cornerRadius = 45
        
        if editeddPost?.owner?.id == _AppCoreData.userDataSource.value?.userID {
            newsFeedSettingVC.isOwner = true
        } else {
            newsFeedSettingVC.isOwner = false
        }
        
        newsFeedSettingVC.isSearch = true
        editeddPost = item
        self.present(newsFeedSettingVC, animated: true, completion: nil)
        
    }
    
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
    
    func reloadAllCurrentHashtag() {
        if !posts.isEmpty {
            for index in 0..<posts.count {
                let indexPath = IndexPath(item: index, section: 0) // Assuming there is only one section
                if let node = collectionNode.nodeForItem(at: indexPath) as? PostNode {
                    
                    if node.hashtagView != nil {
                        node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                        node.hashtagView.collectionView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    @objc func reportPost() {
        
        let slideVC =  reportView()
        
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
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PostNode {
            
            if cell.sideButtonView != nil {
                cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                
                if !cell.buttonsView.streamView.isHidden {
                    
                    cell.buttonsView.streamView.stopSpin()
                    
                }
            }
            
            cell.videoNode.pause()
            
        }
        
    }
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PostNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func playVideo(index: Int) {
        
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PostNode {
            
            if !cell.videoNode.isPlaying() {
                
                if !cell.buttonsView.streamView.isHidden {
                    
                    cell.buttonsView.streamView.spin()
                    
                }
                
                if let muteStatus = shouldMute {
                    
                    if cell.sideButtonView != nil {
                        
                        if muteStatus {
                            cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        } else {
                            cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                        }
                    }
                    
                    if muteStatus {
                        cell.videoNode.muted = true
                    } else {
                        cell.videoNode.muted = false
                    }
                    
                    cell.videoNode.play()
                    
                } else {
                    
                    if cell.sideButtonView != nil {
                        
                        if globalIsSound {
                            cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                        } else {
                            cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        }
                    }
                    
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
