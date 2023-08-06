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
    lazy var delayItem3 = workItem()
    var firstAnimated = true
    var lastLoadTime: Date?
    var isPromote = false
    
    
    
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view
        setupNavBar()
        setupTabBar()
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
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.removePost), name: (NSNotification.Name(rawValue: "remove_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.sharePost), name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.onClickDelete), name: (NSNotification.Name(rawValue: "delete")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.onClickEdit), name: (NSNotification.Name(rawValue: "edit")), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.onClickDownload), name: (NSNotification.Name(rawValue: "download")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.onClickStats), name: (NSNotification.Name(rawValue: "stats")), object: nil)
        
        
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
        setupTabBar()
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
                
                if node.currentIndex != nil {
                    node.pauseVideo(index: node.currentIndex!)
                }
                
            }

            
        }
        
        
    }
    
    
    func setupTabBar() {
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .black
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .black
        self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
        
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
        
        self.retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            
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
        notiButton.setImage(UIImage.init(named: "noNoti")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let notiBarButton = UIBarButtonItem(customView: notiButton)
        
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "search")?.resize(targetSize: CGSize(width: 20, height: 20)), for: [])
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
        notiButton.setImage(UIImage.init(named: "homeNoti")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let notiBarButton = UIBarButtonItem(customView: notiButton)
        
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "search")?.resize(targetSize: CGSize(width: 20, height: 20)), for: [])
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
                    //currentCell.cleanupPosts(collectionNode: currentCell.collectionNode)
                }

                currentIndex = newPlayingIndex
                newPlayingCell.playVideo(index: newPlayingCell.currentIndex ?? 0)

                if let node = newPlayingCell.mainCollectionNode.nodeForItem(at: IndexPath(item: newPlayingCell.currentIndex ?? 0, section: 0)) as? ReelNode {
                    resetView(cell: node)
                }
            }
        } else {
            print("Couldn't find foundVisibleVideo")
        }

        if let currentIndex = newPlayingCell.currentIndex, let cell = newPlayingCell.mainCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? ReelNode {
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
        let frameWidth = self.collectionNode.frame.width
        let frameHeight = self.collectionNode.frame.height
        
        // Check for excessively large sizes
        guard frameWidth < CGFloat.greatestFiniteMagnitude,
              frameHeight < CGFloat.greatestFiniteMagnitude else {
            print("Frame width or height is too large")
            return ASSizeRangeMake(CGSize.zero, CGSize.zero)
        }
        
        let min = CGSize(width: frameWidth, height: 50);
        let max = CGSize(width: frameWidth, height: frameHeight);
        
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
            node.automaticallyManagesSubnodes = true
            
            if self.isfirstLoad, indexPath.row == 0 {
                self.isfirstLoad = false
                node.isFirst = true
                
            }
              
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            retrieveNextPageWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                
                
                context.completeBatchFetching(true)
            }
        } else {
            context.completeBatchFetching(true)
        }
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
                /*
                if !self.posts.contains(item) {
                    self.posts.append(item)
                    items.append(item)
                } */
                
                self.posts.append(item)
                items.append(item)
                
                
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.posts.count - items.count
            let endIndex = startIndex + items.count - 1
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            if firstAnimated {
                firstAnimated = false

                delay(0.15) {
                    
                    UIView.animate(withDuration: 0.5) {
                        self.loadingView.alpha = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if self.loadingView.alpha == 0 {
                            self.loadingView.isHidden = true
                        }
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
    
    @objc func onClickDelete(_ sender: AnyObject) {
        
        
        if let vc = UIViewController.currentViewController() {
            if vc is FeedViewController {
                
                presentSwiftLoader()
                
                if let id = editeddPost?.id, id != "" {
                    
                    
                    APIManager.shared.deleteMyPost(pid: id) { result in
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
        }
  

    }
    
    @objc func removePost() {
        
        if let deletingPost = editeddPost {
           
            if let indexPath = posts.firstIndex(of: deletingPost) {
                
                posts.removeObject(deletingPost)

                // check if there are no more posts
                if posts.isEmpty {
                    collectionNode.reloadData()
                } else {
                    collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                   
                }
            } else {
                
                if currentIndex != nil {
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? OriginalNode {
                        
                        if let indexPath = node.posts.firstIndex(of: deletingPost) {
                            
                            node.posts.removeObject(deletingPost)

                            node.mainCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            node.galleryCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            //node.selectPostCollectionView.collectionView.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            
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
    
    @objc func onClickEdit(_ sender: AnyObject) {
        
        if let vc = UIViewController.currentViewController() {
            if vc is FeedViewController {
                
                print("Edit requested")
                if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC {
                    
                    navigationController?.setNavigationBarHidden(false, animated: true)
                    EPVC.selectedPost = editeddPost
                    self.navigationController?.pushViewController(EPVC, animated: true)
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    @objc func onClickStats(_ sender: AnyObject) {
        
        
        if let vc = UIViewController.currentViewController() {
            if vc is FeedViewController {
                
                print("Stats requested")
                if let VVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ViewVC") as? ViewVC {
                    
                    
                    VVC.selected_item = editeddPost
                    delay(0.1) {
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.navigationController?.pushViewController(VVC, animated: true)
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
    @objc func onClickDownload(_ sender: AnyObject) {
        
        if let vc = UIViewController.currentViewController() {
            if vc is FeedViewController {
                
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
    
    @objc func copyPost() {
        
        if let id = self.editeddPost?.id {
            
            let link = "https://stitchbox.net/app/post/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            showNote(text: "Post link is unable to be copied")
        }
        
    }
    
    @objc func copyProfile() {
        
        if let id = self.editeddPost?.owner?.id {
            
            let link = "https://stitchbox.net/app/account/?uid=\(id)"
            
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
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(editeddPost?.id ?? "")")!]
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
        
        APIManager.shared.getSettings {  result in
           
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
        
        APIManager.shared.getme { result in
            
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


