//
//  ParentViewController.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/9/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import ObjectMapper

class ParentViewController: UIViewController {

    var scrollView: UIScrollView!
    private var containerView: UIView!
    let homeButton: UIButton = UIButton(type: .custom)
    let notiButton = UIButton(type: .custom)
    let searchButton = UIButton(type: .custom)
    
    var hasViewAppeared = false
    var feedViewController: FeedViewController!
    var stitchViewController: StitchViewController!
    
    var isFeed = true
    var rootId = ""
    var allowLoading = true
    lazy var delayItem = workItem()
    var count = 0
    var firstLoadDone = false
    var currentPageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservation()
        syncSendbirdAccount()
        IAPManager.shared.configure()

        setupButtons()
        
        //----------------------------//
        setupScrollView()
        addViewControllers()
        setupNavBar()
        navigationControllerDelegate()

        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.isTranslucent = false
        }
        
        if _AppCoreData.userDataSource.value?.userID != "" {
            requestTrackingAuthorization(userId: _AppCoreData.userDataSource.value?.userID ?? "")
        }
     
        setupCategoryIfNeed()
        firstLoadDone = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTabBar()
        setupNavBar()
        checkNotification()
        showMiddleBtn(vc: self)
        
        if firstLoadDone {
            loadFeed()
        }
    
        hasViewAppeared = true
        

        
        delay(1.25) {
            NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.shouldScrollToTop), name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "scrollToTop"), object: nil)

        hasViewAppeared = false
        
        if isFeed {
            if feedViewController.currentIndex != nil {
                feedViewController.pauseVideo(index: feedViewController.currentIndex!)
            }
        } else {
            if stitchViewController.currentIndex != nil {
                stitchViewController.pauseVideo(index: stitchViewController.currentIndex!)
            }
        }
        
        
    }
    
    func setupCategoryIfNeed() {
        
        if _AppCoreData.userDataSource.value?.isCategorySet != true {
            //UserDefaults.standard.set(true, forKey: "setupCategory")
            
            guard let CVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "CategoryVC") as? CategoryVC
                 else { return }
            
            NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.reloadFeedAfterSetCategory), name: (NSNotification.Name(rawValue: "reloadFeedAfterSetCategory")), object: nil)
            
            
            let nav = UINavigationController(rootViewController: CVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
            
        } else {
            
            feedViewController.readyToLoad = true
            feedViewController.collectionNode.reloadData()
            
        }
        
        
    }

    
    private func setupObservation() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.observeRootChange), name: (NSNotification.Name(rawValue: "observeRootChangeForFeed")), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.copyPost), name: (NSNotification.Name(rawValue: "copy_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.reportPost), name: (NSNotification.Name(rawValue: "report_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.removePost), name: (NSNotification.Name(rawValue: "remove_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.sharePost), name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickDelete), name: (NSNotification.Name(rawValue: "delete")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickEdit), name: (NSNotification.Name(rawValue: "edit")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickDownload), name: (NSNotification.Name(rawValue: "download")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickStats), name: (NSNotification.Name(rawValue: "stats")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickShowInfo), name: (NSNotification.Name(rawValue: "showInfo")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.onClickHideInfo), name: (NSNotification.Name(rawValue: "hideInfo")), object: nil)
        
    }
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        //scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 0)
        ])


        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .black
        scrollView.addSubview(containerView)

        NSLayoutConstraint.activate([
                   containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                   containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                   containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                   
                   containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                   containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
               ])
    }

    private func addViewControllers() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        
        feedViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController
        stitchViewController = storyboard.instantiateViewController(withIdentifier: "StitchViewController") as? StitchViewController
        
        add(childViewController: feedViewController, at: 0)
        add(childViewController: stitchViewController, at: 1)

        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2).isActive = true
    
    }

    private func add(childViewController: UIViewController, at index: Int) {
        addChild(childViewController)
        let childView = childViewController.view!
        containerView.addSubview(childView)

        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: view.bounds.width * CGFloat(index)),
            childView.topAnchor.constraint(equalTo: containerView.topAnchor),
            childView.widthAnchor.constraint(equalTo: view.widthAnchor),
            childView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor) // Constraint to containerView's bottom
        ])

        childViewController.didMove(toParent: self)
    }
}


extension ParentViewController: UIScrollViewDelegate {
   
    
    func setupTabBar() {
        
        if let tabbar = self.tabBarController as? DashboardTabBarController {
            
            tabbar.setupBlackTabBar()
            
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

extension ParentViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.delegate = self
    }
    
}

extension ParentViewController {
    
    func setupButtons() {
        
        setupHomeButton()
        
    }
    
    func setupHomeButton() {
        
        // Do any additional setup after loading the view.
        homeButton.setImage(UIImage.init(named: "gpt-white")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        homeButton.addTarget(self, action: #selector(openChatBot(_:)), for: .touchUpInside)
        homeButton.frame = back_frame
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitle("", for: .normal)
        homeButton.sizeToFit()
        let homeButtonBarButton = UIBarButtonItem(customView: homeButton)
        
        self.navigationItem.leftBarButtonItem = homeButtonBarButton
        
    }
    
    
    func setupEmptyNotiButton() {
        
    
        notiButton.setImage(UIImage.init(named: "noNoti")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let notiBarButton = UIBarButtonItem(customView: notiButton)
        
       
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
        
        notiButton.setImage(UIImage.init(named: "homeNoti")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let notiBarButton = UIBarButtonItem(customView: notiButton)
        
        
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


extension ParentViewController {
    
    @objc func openChatBot(_ sender: AnyObject) {
        if let SBCB = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ChatBot") as? SB_ChatBot {
            
            SBCB.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SBCB, animated: true)
    
        }
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

extension ParentViewController {
    
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



extension ParentViewController {
    
    func switchToProfileVC() {
        
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newPageIndex = Int(scrollView.contentOffset.x / view.frame.width)
        
        guard newPageIndex != currentPageIndex else {
            return
        }
        
        switch newPageIndex {
        case 0:
            print("FeedViewController is fully shown")
            showFeed()
                
        case 1:
            showStitch()
                
        default:
            print("Unknown page")
        }
        
        currentPageIndex = newPageIndex
    }

    
    func showFeed() {
        
        isFeed = true
        
        if stitchViewController.currentIndex != nil {
            print("Parent - Pause at: \(stitchViewController.currentIndex) for stitch")
            stitchViewController.pauseVideo(index: stitchViewController.currentIndex!)
        } else {
            print("Parent - Pause at: nil 0 for stitch")
            stitchViewController.currentIndex = 0
            stitchViewController.pauseVideo(index: 0)
        }
        
        if feedViewController.currentIndex != nil {
            print("Parent - Play at: \(feedViewController.currentIndex) for feed")
            feedViewController.playVideo(index: feedViewController.currentIndex!)
        } else {
            print("Parent - Play at: nil 0 for feed")
            feedViewController.currentIndex = 0
            feedViewController.playVideo(index: 0)
        }
        
    }
    
    func showStitch() {
        
        isFeed = false
        if feedViewController.currentIndex != nil {
            print("Parent - Pause at: \(feedViewController.currentIndex) for feed")
            feedViewController.pauseVideo(index: feedViewController.currentIndex!)
        } else {
            print("Parent - Pause at: nil 0 for feed")
            feedViewController.pauseVideo(index: 0)
        }
        
        
        if !stitchViewController.posts.isEmpty {
            if stitchViewController.currentIndex != nil {
                print("Parent - Play at: \(stitchViewController.currentIndex) for stitch")
                stitchViewController.playVideo(index: stitchViewController.currentIndex!)
            } else {
                print("Parent - Play at: nil 0 for stitch")
                stitchViewController.currentIndex = 0
                stitchViewController.playVideo(index: 0)
            }
    
        }
        
    }


}


extension ParentViewController {
    
    
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

extension ParentViewController {
    
    @objc func observeRootChange() {
        
        print("observeRootChange")
        var shouldReload = false
        
        if rootId == "" || rootId != mainRootId {
            rootId = mainRootId
            shouldReload = true
            print("observeRootChange - \(rootId)")
        } else {
            print("observeRootChange - \(rootId) - \(mainRootId)")
        }
        
        if shouldReload {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollView.isScrollEnabled = false
            }
            
            stitchViewController.rootId = rootId
            count += 1
            
            delayItem.perform(after: 1) { [weak self] in
                guard let self = self else { return }
                print("Loading stitches: \(self.count) - \(self.stitchViewController.rootId)")
                self.stitchViewController.clearAllData()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.scrollView.isScrollEnabled = true
                    
                    if !UserDefaults.standard.bool(forKey: "hasShowStitched") {
                        UserDefaults.standard.set(true, forKey: "hasShowStitched")
                        
                        delay(0.5) {[weak self] in
                            guard let self = self else { return }
                            self.processStichGuideline()
                        }
                    }
                }
            }
        }
         
    }

    
    func processStichGuideline() {
        
        // Calculate the offset that represents a slight move to the right.
        let nextOffset = scrollView.contentOffset.x + scrollView.frame.width * 0.2
        scrollView.setContentOffset(CGPoint(x: nextOffset, y: 0), animated: true)

        // Delay the scroll back by 0.75 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            guard let self = self else { return }
            // Scroll back to the original position (index 0).
            let originalOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(originalOffset, animated: true)
        }
        
        
    }
    
    
    @objc func shouldScrollToTop() {
        
        if isFeed {
            
            if feedViewController.currentIndex != 0, feedViewController.currentIndex != nil {
                
                navigationController?.setNavigationBarHidden(false, animated: true)
                
                if feedViewController.collectionNode.numberOfItems(inSection: 0) != 0 {
                    
                    if feedViewController.currentIndex == 1 {
                        feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                    } else {
                        
                        feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredVertically, animated: false)
                        feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                        
                    }
                    
                }
                
            } else {
                
                feedViewController.delayItem3.perform(after: 0.25) { [weak self] in
                    guard let self = self else { return }
                    self.rootId = ""
                    self.feedViewController.clearAllData()

                }
                
            }
            
            
        } else {
          
            
            let offset = CGFloat(0) * scrollView.bounds.width

            // Scroll to the next page
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            
            showFeed()
            currentPageIndex = 0
            
        }
    
    }
    
    
    @objc func reloadFeedAfterSetCategory() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadFeedAfterSetCategory"), object: nil)
        feedViewController.readyToLoad = true
        feedViewController.collectionNode.reloadData()
        
        
    }
    
}


extension ParentViewController {
    

    @objc func onClickDelete(_ sender: AnyObject) {
        presentSwiftLoader()

        // Check which view controller's post we should delete
        let postToDelete: String? = isFeed ? feedViewController.editeddPost?.id : stitchViewController.editeddPost?.id

        if let id = postToDelete, !id.isEmpty {
            APIManager.shared.deleteMyPost(pid: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    needReloadPost = true
                    SwiftLoader.hide()
                    Dispatch.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.isFeed {
                            self.removePostOnRequest(from: self.feedViewController)
                        } else {
                            self.removePostOnRequest(from: self.stitchViewController)
                        }
                    }
                case .failure(let error):
                    print(error)
                    SwiftLoader.hide()
                    self.showErrorAfterDelay(message: "Unable to delete this post. \(error.localizedDescription), please try again.")
                }
            }
        } else {
            self.showErrorAfterDelay(message: "Unable to delete this post, please try again.")
        }
    }

    func removePostOnRequest(from controller: UIViewController) {
        if let vc = controller as? FeedViewController, let deletingPost = vc.editeddPost, let indexPath = vc.posts.firstIndex(of: deletingPost) {
            vc.posts.removeObject(deletingPost)
            manageCollectionView(in: vc, for: indexPath)
        } else if let vc = controller as? StitchViewController, let deletingPost = vc.editeddPost, let indexPath = vc.posts.firstIndex(of: deletingPost) {
            vc.posts.removeObject(deletingPost)
            manageCollectionView(in: vc, for: indexPath)
        }
    }
    
    @objc func removePost(_ sender: AnyObject) {
        
        if isFeed {
            
            if let deletingPost = feedViewController.editeddPost {
                
                if let indexPath = feedViewController.posts.firstIndex(of: deletingPost) {
                    
                    feedViewController.posts.removeObject(deletingPost)
                    // check if there are no more posts
                    if feedViewController.posts.isEmpty {
                        feedViewController.collectionNode.reloadData()
                    } else {
                        feedViewController.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                        
                    }
                }
            }
        } else {
            
            if let deletingPost = stitchViewController.editeddPost {
                
                if let indexPath = stitchViewController.posts.firstIndex(of: deletingPost) {
                    
                    stitchViewController.posts.removeObject(deletingPost)
                    
                    // check if there are no more posts
                    if stitchViewController.posts.isEmpty {
                        stitchViewController.collectionNode.reloadData()
                        
                    } else {
                        stitchViewController.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                        
                        
                    }
                }
            }
            
        }
       
    }

    func manageCollectionView(in controller: UIViewController, for indexPath: Int) {
        
        if let vc = controller as? FeedViewController {
            if vc.posts.isEmpty {
                vc.collectionNode.reloadData()
            } else {
                vc.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            }
        } else if let vc = controller as? StitchViewController {
            if vc.posts.isEmpty {
                vc.collectionNode.reloadData()
               
            } else {
                vc.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
               
            }
        }
        
    }

    func showErrorAfterDelay(message: String) {
        delay(0.1) { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()
            self.showErrorAlert("Oops!", msg: message)
        }
    }

    

    
    @objc func onClickEdit(_ sender: AnyObject) {
        guard let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC else {
            return
        }

        navigationController?.setNavigationBarHidden(false, animated: true)
        EPVC.selectedPost = isFeed ? feedViewController.editeddPost : stitchViewController.editeddPost
        navigationController?.pushViewController(EPVC, animated: true)
    }

    @objc func onClickShowInfo(_ sender: AnyObject) {
        
        if isFeed, let index = feedViewController.currentIndex, !feedViewController.posts.isEmpty {
            if let node = feedViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.showAllInfo()
            }
        } else if let index = stitchViewController.currentIndex, !stitchViewController.posts.isEmpty {
            if let node = stitchViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.showAllInfo()
            }
        }
        
    }
    
    
    @objc func onClickHideInfo(_ sender: AnyObject) {
        
        if isFeed, let index = feedViewController.currentIndex, !feedViewController.posts.isEmpty {
            if let node = feedViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.hideAllInfo()
            }
        } else if let index = stitchViewController.currentIndex, !stitchViewController.posts.isEmpty {
            if let node = stitchViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.hideAllInfo()
            }
        }
    }

    @objc func onClickStats(_ sender: AnyObject) {
        guard let VVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ViewVC") as? ViewVC else {
            return
        }

        VVC.selected_item = isFeed ? feedViewController.editeddPost : stitchViewController.editeddPost

        delay(0.1) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(VVC, animated: true)
        }
    }

    @objc func onClickDownload(_ sender: AnyObject) {
        let post = isFeed ? feedViewController.editeddPost : stitchViewController.editeddPost
        
        guard let selectedPost = post else { return }
        
        if selectedPost.muxPlaybackId != "" {
            let url = "https://stream.mux.com/\(selectedPost.muxPlaybackId)/high.mp4"
            downloadVideo(url: url, id: selectedPost.muxAssetId)
        }
    }

    
    func downloadVideo(url: String, id: String) {
        AF.request(url).downloadProgress { [weak self] progress in
            guard let self = self else { return }
            self.swiftLoader(progress: String(format: "%.2f", progress.fractionCompleted * 100) + "%")
        }.responseData { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                self.saveVideoWithData(data, id: id)
            case .failure(let error):
                print(error)
            }
        }
    }

    func saveVideoWithData(_ data: Data, id: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
        do {
            try data.write(to: videoURL)
            self.addVideoToPhotoLibrary(url: videoURL)
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                SwiftLoader.hide()
                print("Something went wrong!")
                self.showErrorAlert("Oops!", msg: "Failed to save video.")
            }
        }
    }

    func addVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                SwiftLoader.hide()
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                } else {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }


    @objc func copyPost() {
        let postID = isFeed ? feedViewController.editeddPost?.id : stitchViewController.editeddPost?.id

        if let id = postID {
            let link = "https://stitchbox.net/app/post/?uid=\(id)"
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
        } else {
            showNote(text: "Post link is unable to be copied")
        }
    }

    
    @objc func copyProfile() {
        let ownerID = isFeed ? feedViewController.editeddPost?.owner?.id : stitchViewController.editeddPost?.owner?.id

        if let id = ownerID {
            let link = "https://stitchbox.net/app/account/?uid=\(id)"
            UIPasteboard.general.string = link
            showNote(text: "User profile link is copied")
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
    }

    
    
    
    @objc func reportPost() {
        let slideVC = reportView()
        slideVC.post_report = true
        slideVC.postId = isFeed ? feedViewController.editeddPost?.id ?? "" : stitchViewController.editeddPost?.id ?? ""
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = 0.75
        global_cornerRadius = 35
        
        delay(0.1) {[weak self] in
            guard let self = self else { return }
            self.present(slideVC, animated: true, completion: nil)
        }
    }

    
    @objc func sharePost() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value,
              let userUID = userDataSource.userID,
              userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }

        let postId = isFeed ? feedViewController.editeddPost?.id : stitchViewController.editeddPost?.id
        guard let id = postId else {
            print("Failed to get postId")
            return
        }

        let loadUsername = userDataSource.userName
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)

        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            // Completion logic here if needed
        }

        delay(0.1) {[weak self] in
            self?.present(ac, animated: true, completion: nil)
        }
    }

    @objc func createPostForStitch() {

        guard let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC else {
            return
        }

        PNVC.modalPresentationStyle = .fullScreen

        let postForStitch = isFeed ? feedViewController.editeddPost : stitchViewController.editeddPost

        if let rootvc = PNVC.viewControllers[0] as? PostVC {
            rootvc.stitchPost = postForStitch
        } else {
            printContent(PNVC.viewControllers[0])
        }

        delay(0.1) {
            self.present(PNVC, animated: true)
        }
    }

    
    
    @objc func stitchToExistingPost() {
        
        guard let ASTEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddStitchToExistingVC") as? AddStitchToExistingVC else {
            return
        }

        ASTEVC.hidesBottomBarWhenPushed = true
        ASTEVC.stitchedPost = isFeed ? feedViewController.editeddPost : stitchViewController.editeddPost
        hideMiddleBtn(vc: self)

        delay(0.1) {
            self.navigationController?.pushViewController(ASTEVC, animated: true)
        }
    }
    
    func loadFeed() {
        
        if feedViewController != nil {
            
            let now = Date()
            let thirtyMinutesAgo = now.addingTimeInterval(-1800) // 1800 seconds = 30 minutes
            
            if let lastLoadTime = feedViewController.lastLoadTime, lastLoadTime < thirtyMinutesAgo, !feedViewController.posts.isEmpty {
                if !isFeed {
                    let offset = CGFloat(0) * scrollView.bounds.width
                    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                }
                
                if feedViewController.currentIndex == 1 {
                    feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                } else {
                    
                    feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredVertically, animated: false)
                    feedViewController.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                    
                }
                currentPageIndex = 0
                rootId = ""
                feedViewController.clearAllData()

            } else {
                resumeVideo()
            }
            
        }
        
        
    }

    func resumeVideo() {
        if isFeed {
            if let currentIndex = feedViewController.currentIndex {
                feedViewController.playVideo(index: currentIndex)
            }
        } else {
            if let currentIndex = stitchViewController.currentIndex {
                stitchViewController.playVideo(index: currentIndex)
            }
        }
    }


    
}
