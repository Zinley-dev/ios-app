//
//  FeedViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var preloadingView: UIActivityIndicatorView!
    let homeButton: UIButton = UIButton(type: .custom)

    var currentIndex: Int?
    var isfirstLoad = true
    var didScroll = false
    var imageIndex: Int?
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var refresh_request = false
    var startIndex: Int!
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var imageTimerWorkItem: DispatchWorkItem?
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    
    var lastLoadTime: Date?
    
    @IBOutlet weak var playTimeBar: UIProgressView!
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        navigationControllerHeight = self.navigationController!.navigationBar.frame.height
        tabBarControllerHeight = (self.tabBarController?.tabBar.frame.height)!
        
        setupButtons()
        setupCollectionNode()
        navigationControllerDelegate()
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
        
        //self.navigationController?.hidesBarsOnSwipe = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
       
        
        
        //
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.copyPost), name: (NSNotification.Name(rawValue: "copy_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.reportPost), name: (NSNotification.Name(rawValue: "report_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.removePost), name: (NSNotification.Name(rawValue: "remove_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.sharePost), name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        
        preloadingView.hidesWhenStopped = true
        preloadingView.startAnimating()
        
       
        if let tabBarController = self.tabBarController {
            let viewControllersToPreload = [tabBarController.viewControllers?[1], tabBarController.viewControllers?[4]].compactMap { $0 }
            for viewController in viewControllersToPreload {
                _ = viewController.view
            }
        }


    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMiddleBtn(vc: self)
        loadFeed()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delay(0.25) {
            NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.shouldScrollToTop), name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
        // Call API

        self.clearAllData()
        
    }



    
    @objc func clearAllData() {
        
        refresh_request = true
        currentIndex = 0
        isfirstLoad = true
        didScroll = false
        shouldMute = nil
        imageIndex = nil
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
                
                if self.posts.isEmpty == true {
                    
                    self.collectionNode.view.setEmptyMessage("We can't find any available posts for you right now, can you post something?")
                    
                 
                } else {
                    
                    self.collectionNode.view.restore()
                    
                }
                
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

extension FeedViewController {
    
    @objc func updateProgressBar() {
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = true
               
            }
            global_percentComplete = 0.00
            
        } else {
            
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = false
                self.progressBar.progress = (CGFloat(global_percentComplete)/100)
               
            }

        }
        
    }
    
    
    @objc func shouldScrollToTop() {
        
        if currentIndex != 0, currentIndex != nil {
            
            navigationController?.setNavigationBarHidden(false, animated: true)
            
            if collectionNode.numberOfItems(inSection: 0) != 0 {
                
                if currentIndex == 1 {
                    collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                } else {
                    
                    collectionNode.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredVertically, animated: false)
                    collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                
                }
                
        
            }
            
            
        } else {
            
            delayItem3.perform(after: 0.25) {
                self.clearAllData()
            }

        }
            
    }
    
}

extension FeedViewController {
    
    func setupButtons() {
        
        setupHomeButton()
        setupNotiButton()
    }
    
    
    func setupHomeButton() {
        
        // Do any additional setup after loading the view.
        homeButton.setImage(UIImage.init(named: "Logo")?.resize(targetSize: CGSize(width: 35, height: 35)), for: [])
        homeButton.addTarget(self, action: #selector(onClickHome(_:)), for: .touchUpInside)
        homeButton.frame = back_frame
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitle("", for: .normal)
        homeButton.sizeToFit()
        let homeButtonBarButton = UIBarButtonItem(customView: homeButton)
    
        self.navigationItem.leftBarButtonItem = homeButtonBarButton
       
    }
    
    
    func setupNotiButton() {
        
         let notiButton = UIButton(type: .custom)
         notiButton.setImage(UIImage.init(named: "homeNoti"), for: [])
         notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
         notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
         let notiBarButton = UIBarButtonItem(customView: notiButton)

         let searchButton = UIButton(type: .custom)
         searchButton.setImage(UIImage(named: "search"), for: [])
         searchButton.addTarget(self, action: #selector(onClickSearch(_:)), for: .touchUpInside)
         searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
         let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        
        self.navigationItem.rightBarButtonItems = [notiBarButton, fixedSpace, searchBarButton]
        
    }
    
}

extension FeedViewController {
    
    @objc func onClickHome(_ sender: AnyObject) {
        shouldScrollToTop()
    }
    
    @objc func onClickNoti(_ sender: AnyObject) {
        if let NVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            
            NVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(NVC, animated: true)
            
        }
    }
    
    @objc func onClickSearch(_ sender: AnyObject) {
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            
            SVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
    }
    
}

extension FeedViewController {
    
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


extension FeedViewController {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if this is the first visible cell and it contains a video.
    
        if isfirstLoad {
            isfirstLoad = false
            let post = posts[0]
            if !post.muxPlaybackId.isEmpty {
                currentIndex = 0
                newPlayingIndex = 0
                playVideoIfNeed(playIndex: currentIndex!)
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
                        pauseVideoIfNeed(pauseIndex: currentIndex)
                    }
                    // Play the new video.
                    currentIndex = newPlayingIndex
                    playVideoIfNeed(playIndex: currentIndex!)
                    isVideoPlaying = true
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? PostNode {
                        
                        resetView(cell: node)
                        
                    }
                    
                }
                
            } else {
                
                if let currentIndex = currentIndex {
                    pauseVideoIfNeed(pauseIndex: currentIndex)
                }

                imageTimerWorkItem?.cancel()
                imageTimerWorkItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    if self.imageIndex != nil {
                        if let node = self.collectionNode.nodeForItem(at: IndexPath(item: self.imageIndex!, section: 0)) as? PostNode {
                            if self.imageIndex == self.newPlayingIndex {
                                resetView(cell: node)
                                node.endImage()
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
                pauseVideoIfNeed(pauseIndex: currentIndex!)
                currentIndex = nil
            }
            
        }
        
    
    }


    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionNode.view {
            
            if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
               navigationController?.setNavigationBarHidden(true, animated: true)
                 changeTabBar(hidden: true, animated: true)
                 self.tabBarController?.tabBar.isTranslucent = true
                 hideMiddleBtn(vc: self)
                 bottomConstraint.constant = 20
                

            } else {
               navigationController?.setNavigationBarHidden(false, animated: true)
                changeTabBar(hidden: false, animated: false)
                self.tabBarController?.tabBar.isTranslucent = false
                showMiddleBtn(vc: self)
                bottomConstraint.constant = 0
            }
            
        }
       
    }
    
    func changeTabBar(hidden:Bool, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else {
            return
        }
        if tabBar.isHidden == hidden{
            return
        }
        
        let frame = tabBar.frame
        let frameMinY = frame.minY  //lower end of tabBar
        let offset = hidden ? frame.size.height : -frame.size.height
        let viewHeight = self.view.frame.height
        
        //hidden but moved back up after moving app to background
        if frameMinY < viewHeight && tabBar.isHidden {
            tabBar.alpha = 0
            tabBar.isHidden = false

            UIView.animate(withDuration: 0.5) {
                tabBar.alpha = 1
            }
            
            return
        }

        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        tabBar.isHidden = false

        UIView.animate(withDuration: duration, animations: {
            tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
        }, completion: { (true) in
            tabBar.isHidden = hidden
        })
    }
    

}

extension FeedViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath)) as! HashtagCell
        let item = posts[collectionView.tag]
        
     
        cell.hashTagLabel.text = item.hashtags[indexPath.row]
        
        return cell
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return posts[collectionView.tag].hashtags.count
        
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

extension FeedViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: view.bounds.height + 100);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}

extension FeedViewController: ASCollectionDataSource {
    
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
        
        if self.posts.count >= 150 {
            
            context.completeBatchFetching(true)
            clearAllData()
            
            
        } else {
            
            if refresh_request == false {
                self.retrieveNextPageWithCompletion { (newPosts) in
                    
                    self.insertNewRowsInCollectionNode(newPosts: newPosts)
                    

                    context.completeBatchFetching(true)
                    
                    
                }
            } else {
                context.completeBatchFetching(true)
            }
            
            
            
        }
    }
    

    
}


extension FeedViewController {
    
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
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
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
    
}

extension FeedViewController {
    

    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager().getUserFeed { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                    return
                }
                if !data.isEmpty {
                    self.lastLoadTime = Date()
                    print("Successfully retrieved \(data.count) posts.")
                    let items = data
                  
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
        
    }
    
    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        // Check if there are new posts to insert
        guard !newPosts.isEmpty else { return }
        
        // Check if a refresh request has been made
        if refresh_request {
            refresh_request = false
            
            // Delete existing rows if there are any
            let numExistingItems = posts.count
            if numExistingItems > 0 {
                let deleteIndexPaths = (0..<numExistingItems).map { IndexPath(row: $0, section: 0) }
                posts.removeAll()
                collectionNode.deleteItems(at: deleteIndexPaths)
            }
        }
        
        // Calculate the range of new rows
        let startIndex = posts.count
        let endIndex = startIndex + newPosts.count
        
        // Create an array of PostModel objects
        let newItems = newPosts.compactMap { PostModel(JSON: $0) }
        
        // Append the new items to the existing array
        posts.append(contentsOf: newItems)
        
        // Create an array of index paths for the new rows
        let insertIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        
        // Insert the new rows
        collectionNode.insertItems(at: insertIndexPaths)
        
        if preloadingView.isAnimating {
            preloadingView.stopAnimating()
        }
    
    }


    
}

extension FeedViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension FeedViewController {
    
    func settingPost(item: PostModel) {
        
        let newsFeedSettingVC = NewsFeedSettingVC()
        newsFeedSettingVC.modalPresentationStyle = .custom
        newsFeedSettingVC.transitioningDelegate = self
        
        global_presetingRate = Double(0.35)
        global_cornerRadius = 45
        newsFeedSettingVC.isOwner = false
        editeddPost = item
        self.present(newsFeedSettingVC, animated: true, completion: nil)
        
    }
    
    @objc func copyPost() {
    
        if let id = self.editeddPost?.id {
           
            let link = "https://dualteam.page.link/dual?p=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            showNote(text: "Post link is unable to be copied")
        }
        
    }
    
    @objc func copyProfile() {
        
        if let id = self.editeddPost?.owner?.id {
            
            let link = "https://dualteam.page.link/dual?up=\(id)"
            
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
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://dualteam.page.link/dual?p=\(editeddPost?.id ?? "")")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        delay(0.1) {
            self.present(ac, animated: true, completion: nil)
        }
      
    }
    
    func switchToProfileVC() {
        
        changeTabBar(hidden: false, animated: false)
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
       
        
    }
    
    
    func loadFeed() {
        let now = Date()
        let fortyFiveMinutesAgo = now.addingTimeInterval(-2700) // 2700 seconds = 45 minutes
        
        if lastLoadTime != nil, lastLoadTime! < fortyFiveMinutesAgo, !posts.isEmpty {
            pullControl.beginRefreshing()
            clearAllData()
        }
    }
    
}
