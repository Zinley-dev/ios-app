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

    private var scrollView: UIScrollView!
    private var containerView: UIView!
    let homeButton: UIButton = UIButton(type: .custom)
    
    
    var feedViewController: FeedViewController!
    var stitchViewController: StitchViewController!
    
    var isFeed = true
    var rootId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncSendbirdAccount()
        IAPManager.shared.configure()
        setupButtons()
        
        //----------------------------//
        setupScrollView()
        addViewControllers()
        setupNavBar()
        navigationControllerDelegate()
        
        
        
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
        
        
        
        loadNewestCoreData { [weak self] in
            guard let self = self else { return }
            self.loadSettings {
                print("Oke!")
            }
        }
        
        if _AppCoreData.userDataSource.value?.userID != "" {
            requestTrackingAuthorization(userId: _AppCoreData.userDataSource.value?.userID ?? "")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentViewController.observeRootChange), name: (NSNotification.Name(rawValue: "observeRootChange")), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTabBar()
        setupNavBar()
        checkNotification()
    
        if isFeed {
            if feedViewController.currentIndex != nil {
                feedViewController.playVideo(index: feedViewController.currentIndex!)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if isFeed {
            if feedViewController.currentIndex != nil {
                feedViewController.pauseVideo(index: feedViewController.currentIndex!)
            }
        }
        
        
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
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
        containerView.backgroundColor = .blue
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


extension ParentViewController {
    
    @objc func onClickHome(_ sender: AnyObject) {
        //shouldScrollToTop()
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
        let pageIndex = scrollView.contentOffset.x / view.frame.width

        switch pageIndex {
        case 0:
            print("FeedViewController is fully shown")
            isFeed = true
            if stitchViewController.currentIndex != nil {
                stitchViewController.pauseVideo(index: stitchViewController.currentIndex!)
            } else {
                stitchViewController.pauseVideo(index: 0)
            }
            
            if feedViewController.currentIndex != nil {
                feedViewController.playVideo(index: feedViewController.currentIndex!)
            }
            
            
        case 1:
            print("StitchViewController is fully shown")
            isFeed = false
            if feedViewController.currentIndex != nil {
                feedViewController.pauseVideo(index: feedViewController.currentIndex!)
            } else {
                feedViewController.pauseVideo(index: 0)
            }
            
            
            if stitchViewController.currentIndex != nil, !stitchViewController.posts.isEmpty {
                stitchViewController.playVideo(index: stitchViewController.currentIndex!)
               
            }
            
         
        default:
            print("Unknown page")
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
        if rootId == "" {
            
            rootId = mainRootId
            shouldReload = true
            
        } else if rootId != mainRootId {
            
            rootId = mainRootId
            shouldReload = true
            
        } else {
            print("observeRootChange - \(rootId) - \(mainRootId)")
        }
        
        if shouldReload {
            
            stitchViewController.rootId = rootId
            
            Dispatch.main.async { [weak self] in
                guard let self = self else { return }
                self.stitchViewController.clearAllData()
            }
            
            
        }
        
        
    }
    
    
}
