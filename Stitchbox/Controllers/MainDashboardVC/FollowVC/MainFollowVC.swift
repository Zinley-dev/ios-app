//
//  MainFollowVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import UIKit
import FLAnimatedImage

class MainFollowVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    deinit {
        print("MainFollowVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var searchController: UISearchController?
    var showFollowerFirst = false
    var type = ""
    var ownerID = ""
    var username: String?
    var onPresent = false
    var followerCount = 0
    var followingCount = 0
    var userId: String?
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    // to override search task
    lazy var delayItem = workItem()
    
    
    lazy var FollowerVC: FollowerVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FollowerVC") as? FollowerVC {
            
            controller.userId = self.userId ?? ""
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! FollowerVC
        }
        
        
    }()
    
    lazy var FollowingVC: FollowingVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "FollowingVC") as? FollowingVC {
            
            controller.userId = self.userId ?? ""
            self.addVCAsChildVC(childViewController: controller)
            
            
            return controller
            
        } else {
            return UIViewController() as! FollowingVC
        }
        
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        
        if showFollowerFirst
        {
            setupFollowersView()
        }
        else {
            setupFollowingView()
        }
        
        setupSearchController()
        
        if let user = self.userId {
            
            countFollowers(userId: user) {
                Dispatch.main.async {
                    
                    self.followerBtn.setTitle("\(formatPoints(num: Double(self.followerCount))) Followers", for: .normal)
                }
            }
            
            countFollowings(userId: user) {
                Dispatch.main.async {
                    self.followingBtn.setTitle("\(formatPoints(num: Double(self.followingCount))) Followings", for: .normal)
                }
            }
            
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
        
        delay(1.0) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    func countFollowers(userId: String, completed: @escaping DownloadComplete) {
        
        
        APIManager.shared.getFollowers(userId: userId, page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    completed()
                    return
                }
                
                if let followersGet = data["total"] as? Int {
                    self.followerCount = followersGet
                } else {
                    self.followerCount = 0
                }
                
                completed()
                
            case .failure(let error):
                print("Error loading follower: ", error)
                completed()
                
            }
        }
        
    }
    
    
    func countFollowings(userId: String, completed: @escaping DownloadComplete) {
        
        APIManager.shared.getFollows(userId: userId, page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    completed()
                    return
                }
                
                if let followingsGet = data["total"] as? Int {
                    self.followingCount = followingsGet
                } else {
                    self.followingCount = 0
                }
                
                completed()
                
            case .failure(let error):
                print("Error loading follower: ", error)
                completed()
                
            }
        }
        
    }
    
    
    @IBAction func followerBtn(_ sender: Any) {
        
        setupFollowersView()
        
    }
    
    @IBAction func followingBtn(_ sender: Any) {
        
        setupFollowingView()
        
    }
    
    
}

extension MainFollowVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
        setupSearchBar()
    }
    
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
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
        
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Can't get userDataSource")
            return
        }
        
        if self.userId == userDataSource.userID {
            
            let loadUsername = userDataSource.userName
            if loadUsername != "" {
                self.navigationItem.title = loadUsername
            } else {
                self.navigationItem.title = "Follow"
            }
            
        } else {
            
            self.navigationItem.title = self.username ?? "Follow"
            
        }
        
        
        
        
        
    }
    
    func setupSearchBar() {
        
        let searchButton: UIButton = UIButton(type: .custom)
        
        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        
        self.navigationItem.rightBarButtonItem = searchBarButton
        
        
    }
    
    func setupFollowersView() {
        
        followerBtn.setTitleColor(UIColor.white, for: .normal)
        followingBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        followerBtn.backgroundColor = UIColor.secondary
        followingBtn.backgroundColor = UIColor.clear
        
        
        FollowerVC.view.isHidden = false
        FollowingVC.view.isHidden = true
        
        self.searchController?.searchBar.text = ""
        
    }
    
    func setupFollowingView() {
        
        followerBtn.setTitleColor(UIColor.lightGray, for: .normal)
        followingBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        followerBtn.backgroundColor = UIColor.clear
        followingBtn.backgroundColor = UIColor.secondary
        
        
        FollowerVC.view.isHidden = true
        FollowingVC.view.isHidden = false
        
        
        self.searchController?.searchBar.text = ""
        
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .lightGray
        self.searchController?.searchBar.isUserInteractionEnabled = true
        self.navigationItem.searchController = nil
        self.searchController?.searchBar.isHidden = true
    }
    
    
}

extension MainFollowVC {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        contentViewTopConstant.constant = 10
        
        buttonStackView.isHidden = false
        navigationItem.searchController = nil
        searchController?.searchBar.isHidden = true
        
        if FollowerVC.view.isHidden == false {
            
            FollowerVC.searchUserList.removeAll()
            FollowerVC.inSearchMode = false
            FollowerVC.tableNode.reloadData()
            
            return
            
        }
        
        
        if FollowingVC.view.isHidden == false {
            
            FollowingVC.searchUserList.removeAll()
            FollowingVC.inSearchMode = false
            FollowingVC.tableNode.reloadData()
            
            return
            
        }
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
        contentViewTopConstant.constant = -50
        
        if FollowerVC.view.isHidden == false {
            
            
            FollowerVC.searchUserList = FollowerVC.userList
            FollowerVC.inSearchMode = true
            FollowerVC.tableNode.reloadData()
            
            
            return
            
        }
        
        
        if FollowingVC.view.isHidden == false {
            
            
            FollowingVC.searchUserList = FollowingVC.userList
            FollowingVC.inSearchMode = true
            FollowingVC.tableNode.reloadData()
            
            return
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            clearSearchResults()
        } else {
            searchUsers(for: searchText)
        }
    }
    
    func clearSearchResults() {
        // Clear the search results for both view controllers
        FollowerVC.searchUserList.removeAll()
        FollowingVC.searchUserList.removeAll()
        
        // Check which view controller is currently visible
        if !FollowerVC.view.isHidden {
            // Set the searchUserList variable of the FollowerVC to the full list of users and reload the table view
            FollowerVC.searchUserList = FollowerVC.userList
            FollowerVC.tableNode.reloadData()
        } else if !FollowingVC.view.isHidden {
            // Set the searchUserList variable of the FollowingVC to the full list of users and reload the table view
            FollowingVC.searchUserList = FollowingVC.userList
            FollowingVC.tableNode.reloadData()
        }
    }
    
    
    func searchUsers(for searchText: String) {
        
        let follows = !FollowerVC.view.isHidden ? FollowerVC.userList : FollowingVC.userList
        
        let searchUserList = follows.filter { follow in
            
            if let username = follow.username {
                
                return (username.range(of: searchText, options: .caseInsensitive) != nil)
                
            }
            
            return true
        }
        
        if !searchUserList.isEmpty {
            
            if !FollowerVC.view.isHidden {
                FollowerVC.searchUserList = searchUserList
                FollowerVC.tableNode.reloadData()
            } else {
                FollowingVC.searchUserList = searchUserList
                FollowingVC.tableNode.reloadData()
            }
            
        } else {
            
            if !FollowerVC.view.isHidden {
                
                delayItem.perform(after: 0.35) {
                    print("Search followers using api")
                    self.searchFollowers(for: searchText)
                }
                
            } else {
                
                delayItem.perform(after: 0.35) {
                    print("Search following using api")
                    self.searchFollowings(for: searchText)
                }
            }
            
        }
        
        
    }
    
    func searchFollowers(for searchText: String) {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID {
            
            APIManager.shared.searchFollows(query: searchText, userid: userUID, page: 1) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success",
                          let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        return
                    }
                    
                    let list = data.map { item in
                        return FollowModel(JSON: item)!
                    }
                    
                    DispatchQueue.main.async {
                        self.FollowerVC.searchUserList = list
                        self.FollowerVC.tableNode.reloadData()
                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        
        
    }
    
    
    func searchFollowings(for searchText: String) {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID {
            
            APIManager.shared.searchFollowing(query: searchText, userid: userUID, page: 1) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    
                    guard apiResponse.body?["message"] as? String == "success",
                          let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        return
                    }
                    
                    let list = data.map { item in
                        return FollowModel(JSON: item)!
                    }
                    
                    DispatchQueue.main.async {
                        self.FollowingVC.searchUserList = list
                        self.FollowingVC.tableNode.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        
    }
    
}

extension MainFollowVC {
    
    @objc func searchBarSetting(_ sender: AnyObject) {
        if searchController?.searchBar.isHidden == true {
            buttonStackView.isHidden = true
            navigationItem.searchController = searchController
            searchController?.searchBar.isHidden = false
            
            delay(0.025) {
                self.searchController?.searchBar.becomeFirstResponder()
            }
            
        } else {
            buttonStackView.isHidden = false
            navigationItem.searchController = nil
            searchController?.searchBar.isHidden = true
        }
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if onPresent {
            self.dismiss(animated: true)
        } else {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
        
    }
    
    
}

extension MainFollowVC {
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
}

extension MainFollowVC {
    
}
