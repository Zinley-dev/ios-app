//
//  MainFollowVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import UIKit

class MainFollowVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
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
    
    
    lazy var FollowerVC: FollowerVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FollowerVC") as? FollowerVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! FollowerVC
        }
       
        
    }()
    
    lazy var FollowingVC: FollowingVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "FollowingVC") as? FollowingVC {
            
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
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupTitle() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName ?? "default"
        
        self.navigationItem.title = loadUsername
       
       
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
        
        
        followerBtn.backgroundColor = UIColor.primary
        followingBtn.backgroundColor = UIColor.clear
        
        
        FollowerVC.view.isHidden = false
        FollowingVC.view.isHidden = true
        
    }
    
    func setupFollowingView() {
        
        followerBtn.setTitleColor(UIColor.lightGray, for: .normal)
        followingBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        followerBtn.backgroundColor = UIColor.clear
        followingBtn.backgroundColor = UIColor.primary
        
        
        FollowerVC.view.isHidden = true
        FollowingVC.view.isHidden = false
        
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
            
            /*
            FollowerVC.searchChannelList.removeAll()
            FollowerVC.inSearchMode = false
            FollowerVC.groupChannelsTableView.reloadData()
             */
            
            return
            
        }
        
        
        if FollowingVC.view.isHidden == false {
            
            /*
            FollowingVC.searchChannelList.removeAll()
            FollowingVC.inSearchMode = false
            FollowingVC.groupChannelsTableView.reloadData()
             */
            
            return
            
        }
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    
        contentViewTopConstant.constant = -50
        
        if FollowerVC.view.isHidden == false {
            
            /*
            FollowerVC.searchChannelList = InboxVC.channels
            FollowerVC.inSearchMode = true
            FollowerVC.groupChannelsTableView.reloadData()
            */
            
            return
            
        }
        
        
        if FollowingVC.view.isHidden == false {
            
            /*
            FollowingVC.searchChannelList = RequestVC.channels
            FollowingVC.inSearchMode = true
            FollowingVC.groupChannelsTableView.reloadData()
             */
            
            return
            
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
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
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
