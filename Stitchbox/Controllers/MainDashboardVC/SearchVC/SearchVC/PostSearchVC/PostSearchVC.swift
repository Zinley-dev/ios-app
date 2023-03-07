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
    var page = 1
    var keyword = ""
    var post_list = [PostModel]()
    
    var willIndex: Int?
    var currentIndex: Int?
    var endIndex: Int?
    
    var isfirstLoad = true
    var didScroll = false

    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var refresh_request = false
    var startIndex: Int!
    
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    private var pullControl = UIRefreshControl()
    
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
        endIndex = 0
        willIndex = nil
        currentIndex = 0
        isfirstLoad = true
        didScroll = false
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
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        guard let cell = node as? PostNode else { return }
    
        willIndex = cell.indexPath?.row
        
        if isfirstLoad {
            isfirstLoad = false
            currentIndex = 0
            playVideoIfNeed(playIndex: currentIndex!)
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        
        // 1. Safely unwrap the indexPath of the cell node.
        guard let postNode = node as? PostNode, let indexPath = postNode.indexPath else { return }
        
        let post = posts[indexPath.row]
        // 2. If the muxPlaybackId property is empty, return immediately.
        guard !post.muxPlaybackId.isEmpty else {
            // 3. If the next item is a video, play it.
            if let willIndex = willIndex, willIndex > indexPath.row {
                let nextPost = posts[willIndex]
                if !nextPost.muxPlaybackId.isEmpty {
                    currentIndex = willIndex
                    playVideoIfNeed(playIndex: currentIndex!)
                }
            // 4. If the previous item is a video, play it.
            } else if let willIndex = willIndex, willIndex < indexPath.row {
                let previousPost = posts[willIndex]
                if !previousPost.muxPlaybackId.isEmpty {
                    currentIndex = willIndex
                    playVideoIfNeed(playIndex: currentIndex!)
                }
            }
            return
        }
        
        // 5. Pause the video that was previously playing.
        pauseVideoIfNeed(pauseIndex: indexPath.row)
        
        var shouldPlayNextVideo = false
        var shouldPlayPreviousVideo = false
        
        // 6. Check if there is a willIndex value, and if it does not match the current index path.
        if let willIndex = willIndex, willIndex != indexPath.row {
            // 7. If the willIndex is greater than the current index path, check if the next post contains a video.
            if willIndex > indexPath.row && willIndex < posts.count {
                let nextPost = posts[willIndex]
                shouldPlayNextVideo = !nextPost.muxPlaybackId.isEmpty
            // 8. If the willIndex is less than the current index path, check if the previous post contains a video.
            } else if willIndex < indexPath.row && willIndex >= 0 {
                let previousPost = posts[willIndex]
                shouldPlayPreviousVideo = !previousPost.muxPlaybackId.isEmpty
            }
        // 9. If there is no willIndex value, check if the next or previous post contains a video based on the first visible index path.
        } else if let firstVisibleIndexPath = collectionNode.indexPathsForVisibleItems.first {
            if indexPath.row < firstVisibleIndexPath.row {
                let previousPost = posts[firstVisibleIndexPath.row]
                shouldPlayPreviousVideo = !previousPost.muxPlaybackId.isEmpty
            } else if indexPath.row > firstVisibleIndexPath.row {
                let nextPost = posts[firstVisibleIndexPath.row]
                shouldPlayNextVideo = !nextPost.muxPlaybackId.isEmpty
            }
        }
        
        // 10. If shouldPlayNextVideo is true, play the next video and set the currentIndex variable to the index path of the next post.
        if shouldPlayNextVideo {
            currentIndex = indexPath.row + 1
            playVideoIfNeed(playIndex: currentIndex!)
        // 11. If shouldPlayPreviousVideo is true, play the previous video and set the currentIndex variable to the index path of the previous post.
        } else if shouldPlayPreviousVideo {
            currentIndex = indexPath.row - 1
            playVideoIfNeed(playIndex: currentIndex!)
        }
        
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            // User has scrolled to the very top
    
            currentIndex = 0
            playVideoIfNeed(playIndex: currentIndex!)
            
            
        }
    }
    
    
}


extension PostSearchVC {
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
    
}

extension PostSearchVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: view.bounds.height);
        
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
                if node.headerView != nil {
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
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentview.leadingAnchor, constant: 0).isActive = true
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
        
        self.searchPost { (newPosts) in
            
            if newPosts.count > 0 {
                
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                
            }
            
            
        }
        
    }
    
    func searchPost(block: @escaping ([[String: Any]]) -> Void) {
        
        if keyword != "" {
            
            print("Post search: \(keyword)")

                APIManager().searchPost(query: keyword, page: page) { result in
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
    
}



extension PostSearchVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        if keyword != "" {
            
            print("Post search: \(keyword)")

                APIManager().searchPost(query: keyword, page: page) { result in
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
    }

}


extension PostSearchVC {
    
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
               
            }
            
        }
        
       
    }
    
    @objc func reportPost() {
        
        let slideVC =  reportView()
        
        slideVC.video_report = true
        slideVC.highlight_id = editeddPost?.id ?? ""
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
    
}
