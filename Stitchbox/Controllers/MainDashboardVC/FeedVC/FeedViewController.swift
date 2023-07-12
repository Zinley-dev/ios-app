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
import FLAnimatedImage
import ObjectMapper
import AppsFlyerLib

class FeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var lastContentOffsetY: CGFloat = 0
    //let threshold: CGFloat = 100 // Adjust this value as needed.

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var currentIndex: Int?
    var newPlayingIndex: Int?
    var hasViewAppeared = false
    
    //let promotionButton = UIButton(type: .custom)
    let homeButton: UIButton = UIButton(type: .custom)
    var promotionList = [PromoteModel]()
   
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

    var imageTimerWorkItem: DispatchWorkItem?
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    var firstAnimated = true
    var lastLoadTime: Date?
    var isPromote = false

    
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view
        setupNavBar()
        syncSendbirdAccount()
        IAPManager.shared.configure()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.sharePost), name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one")), object: nil)
        
        
        
        if let tabBarController = self.tabBarController {
            let viewControllersToPreload = [tabBarController.viewControllers?[1], tabBarController.viewControllers?[4]].compactMap { $0 }
            for viewController in viewControllersToPreload {
                _ = viewController.view
            }
        }
        
        
        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.isTranslucent = false
        }
        
        
        
        self.loadNewestCoreData {
            self.loadSettings {
                print("Oke!")
            }
        }
        
        if _AppCoreData.userDataSource.value?.userID != "" {
            requestTrackingAuthorization(userId: _AppCoreData.userDataSource.value?.userID ?? "")
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        checkNotification()
        showMiddleBtn(vc: self)
        loadFeed()
        
        hasViewAppeared = true
        
        if firstAnimated {
            
            do {
                
                let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                let gifData = try NSData(contentsOfFile: path) as Data
                let image = FLAnimatedImage(animatedGIFData: gifData)
                
                
                loadingImage.animatedImage = image
                
            } catch {
                print(error.localizedDescription)
            }
            
            loadingView.backgroundColor = self.view.backgroundColor
            
        }
        
        if currentIndex != nil {
            //newPlayingIndex
            
            if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                
                node.playVideo(index: node.currentIndex!)
                
            }

            
        }
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delay(0.25) {[weak self] in
            guard let self = self else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.shouldScrollToTop), name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hasViewAppeared = false
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        
        if currentIndex != nil {
            //newPlayingIndex
            
            if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                
                node.pauseVideo(index: node.currentIndex!)
                
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
            
            self.delayItem.perform(after: 0.75) { [weak self] in
                guard let self = self else { return }
                
                
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
            
            delayItem3.perform(after: 0.25) { [weak self] in
                guard let self = self else { return }
                self.clearAllData()
            }
            
        }
        
    }
    
    func checkNotification() {
        
        APIManager.shared.getBadge { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                if let data = apiResponse.body {
                    
                    if let badge = data["badge"] as? Int {
                        
                        if badge == 0 {
                            
                            Dispatch.main.async {
                                self.setupEmptyNotiButton()
                            }
                            
                        } else {
                            Dispatch.main.async {
                                self.setupHasNotiButton()
                            }
                        }
                        
                    } else {
                        
                        Dispatch.main.async {
                            self.setupEmptyNotiButton()
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                Dispatch.main.async {
                    self.setupEmptyNotiButton()
                }
                print(error)
                
            }
        }
        
        
        
    }
    
    
    
}

extension FeedViewController {
    
    func setupButtons() {
        
        setupHomeButton()
        
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
    
    
    func setupEmptyNotiButton() {
        
        let notiButton = UIButton(type: .custom)
        notiButton.setImage(UIImage.init(named: "noNoti"), for: [])
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
        
        
        //let promotionBarButton = self.createPromotionButton()
        self.navigationItem.rightBarButtonItems = [notiBarButton, fixedSpace, searchBarButton]
        
        
    }
    
    
    func setupHasNotiButton() {
        
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
        
        
        //let promotionBarButton = self.createPromotionButton()
        self.navigationItem.rightBarButtonItems = [notiBarButton, fixedSpace, searchBarButton]
        
    }
    

}

extension FeedViewController {
    
    @objc func onClickHome(_ sender: AnyObject) {
        shouldScrollToTop()
    }
    
    
    @objc func onClickNoti(_ sender: AnyObject) {
        if let NVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            
            resetNoti()
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
    


    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        if isfirstLoad {
            isfirstLoad = false
            
            if let currentCell = collectionNode.nodeForItem(at: IndexPath(item: 0, section: 0)) as? OriginalNode {
                
                if !currentCell.posts[0].muxPlaybackId.isEmpty {
                    currentIndex = 0
                    newPlayingIndex = 0
                    currentCell.currentIndex = 0
                    currentCell.newPlayingIndex = 0
                    
                    currentCell.isVideoPlaying = true
                    
                    delay(0.25) { [weak self] in
                        guard let self = self else { return }
                        currentCell.playVideo(index: 0)
                    }
                }
                
            }
            
            
            
        }
        
    }
 
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
                    currentCell.cleanupPosts(collectionNode: currentCell.collectionNode)
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

extension FeedViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.collectionNode.layer.frame.width, height: 50);
        let max = CGSize(width: self.collectionNode.layer.frame.width, height: collectionNode.frame.height);
        
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
            let node = OriginalNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
        
            
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
        /*
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
        } */
    }


    
}


extension FeedViewController {
    
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
    
    
}

extension FeedViewController {
    
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getUserFeed { [weak self] result in
            guard let self = self else { return }
            
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

            if firstAnimated {
                firstAnimated = false

                UIView.animate(withDuration: 0.5) {
                    self.loadingView.alpha = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.loadingView.alpha == 0 {
                        self.loadingView.isHidden = true
                    }
                }
            }

            // Insert new items at index paths
            self.collectionNode.insertItems(at: indexPaths)
        }
    }

    
    
}

extension FeedViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.delegate = self
    }
    
}

extension FeedViewController {
    
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
    
 
    
    @objc func reportPost() {
        
        let slideVC =  reportView()
        
        slideVC.post_report = true
        slideVC.postId = editeddPost?.id ?? ""
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = Double(0.75)
        global_cornerRadius = 35
        
        delay(0.1) {[weak self] in
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
        
        delay(0.1) {[weak self] in
            guard let self = self else { return }
            self.present(ac, animated: true, completion: nil)
        }
        
    }
    
    @objc func createPostForStitch() {
        
        if let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC {
            
            // Customize the navigation bar appearance
            PNVC.navigationBar.barTintColor = .black
            PNVC.navigationBar.tintColor = .white
            PNVC.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            
            PNVC.modalPresentationStyle = .fullScreen
            
            delay(0.1) {
                self.present(PNVC, animated: true)
            }
            
        }
        
    }
    
    
    @objc func stitchToExistingPost() {
        
        if let ASTEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddStitchToExistingVC") as? AddStitchToExistingVC {
            
            ASTEVC.hidesBottomBarWhenPushed = true
            ASTEVC.post = editeddPost
            hideMiddleBtn(vc: self)
            
            delay(0.1) {
                self.navigationController?.pushViewController(ASTEVC, animated: true)
            }
            
        }
        
        
    }
    
    func switchToProfileVC() {
    
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
    
    func resetNoti() {
        
        APIManager.shared.resetBadge { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                Dispatch.main.async {
                    self.setupEmptyNotiButton()
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        }
        
        
    }

}


extension FeedViewController {
    
    
    func loadSettings(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getSettings { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body else {
                    completed()
                    return
                }
                
                let settings =  Mapper<SettingModel>().map(JSONObject: data)
                globalSetting = settings
                globalIsSound = settings?.AutoPlaySound ?? false
                
                completed()
                
            case .failure(_):
                
                completed()
                
            }
        }
        
    }
    
    
    func loadNewestCoreData(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getme { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                if let data = response.body {
                    
                    if !data.isEmpty {
                        
                        if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                            _AppCoreData.reset()
                            _AppCoreData.userDataSource.accept(newUserData)
                            completed()
                        } else {
                            completed()
                        }
                        
                        
                    } else {
                        completed()
                    }
                    
                } else {
                    completed()
                }
                
                
            case .failure(let error):
                print("Error loading profile: ", error)
                completed()
            }
        }
        
        
    }
    
    
}


