//
//  MainSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit

class MainSearchVC: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    enum SearchMode {
        case users
        case posts
        case hashTags
    }

    var initialType = ""
    var currentSearchText = ""
    let backButton: UIButton = UIButton(type: .custom)
    var searchController: UISearchController?
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var hashtagBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var userBtn: UIButton!
    
    var searchList = [UserSearchModel]()
    
    var userBorder = CALayer()
    var postBorder = CALayer()
    var hashTagBorder = CALayer()
    
    var selectedSearchMode = SearchMode.users
    var searchText = ""
    
    var prevSelectedSearchMode = SearchMode.users
    var prevSearchText = ""
    
    var tapGesture: UITapGestureRecognizer!

    lazy var delayItem = workItem()
    
    
    lazy var UserSearchVC: UserSearchVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSearchVC") as? UserSearchVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! UserSearchVC
        }
                
        
    }()
    
    
    lazy var PostSearchVC: PostSearchVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "PostSearchVC") as? PostSearchVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! PostSearchVC
        }
                
        
    }()
    
    lazy var HashtagSearchVC: HashtagSearchVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "HashtagSearchVC") as? HashtagSearchVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! HashtagSearchVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupSearchController()
        setupLayers()
        
        tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.closeKeyboard(_:)))
        //do not cancel touch gesture
        tapGesture.cancelsTouchesInView = false
        
        tapGesture.delegate = self
        self.contentView.addGestureRecognizer(tapGesture)
        
        if self.initialType == "user" {
            
            setCurrentBorderAndShowView(currentSelected: SearchMode.users)
            userBtn.setTitleColor(UIColor.white, for: .normal)
            postBtn.setTitleColor(UIColor.lightGray, for: .normal)
            hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
            
        } else if self.initialType == "post" {
            
            setCurrentBorderAndShowView(currentSelected: SearchMode.posts)
            postBtn.setTitleColor(UIColor.white, for: .normal)
            userBtn.setTitleColor(UIColor.lightGray, for: .normal)
            hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
            
        } else if self.initialType == "hashtag" {
            
            setCurrentBorderAndShowView(currentSelected: SearchMode.hashTags)
            hashtagBtn.setTitleColor(UIColor.white, for: .normal)
            postBtn.setTitleColor(UIColor.lightGray, for: .normal)
            userBtn.setTitleColor(UIColor.lightGray, for: .normal)
            
        }
        
    }
    

    
    @IBAction func userBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.users)
        userBtn.setTitleColor(UIColor.white, for: .normal)
        postBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.posts)
        postBtn.setTitleColor(UIColor.white, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.hashTags)
        hashtagBtn.setTitleColor(UIColor.white, for: .normal)
        postBtn.setTitleColor(UIColor.lightGray, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    private func setCurrentBorderAndShowView(currentSelected: SearchMode){
//        clearPreviousBorderAndHideView()
        prevSelectedSearchMode = selectedSearchMode
        selectedSearchMode = currentSelected
        
        switch selectedSearchMode {
        case SearchMode.users:
            userBtn.layer.addSublayer(userBorder)
            postBorder.removeFromSuperlayer()
            PostSearchVC.view.isHidden = true
            hashTagBorder.removeFromSuperlayer()
            HashtagSearchVC.view.isHidden = true
        case SearchMode.posts:
            postBtn.layer.addSublayer(postBorder)
            userBorder.removeFromSuperlayer()
            UserSearchVC.view.isHidden = true
            hashTagBorder.removeFromSuperlayer()
            HashtagSearchVC.view.isHidden = true
            
        case SearchMode.hashTags:
            hashtagBtn.layer.addSublayer(hashTagBorder)
            userBorder.removeFromSuperlayer()
            UserSearchVC.view.isHidden = true
            postBorder.removeFromSuperlayer()
            PostSearchVC.view.isHidden = true
        }
        sendSearchRequestToTargetVC()
    }
    
    func sendSearchRequestToTargetVC(){
        //print("Searching... \(searchText), previous search: \(self.prevSearchText)")
        if searchText.isEmpty {
            self.hideTableOnEmptySearchText()

        } else if selectedSearchMode == prevSelectedSearchMode && searchText == prevSearchText {
            //print("no change...")
            return
        } else {
            switch self.selectedSearchMode {
            case SearchMode.users:
                //print("search users...")
                UserSearchVC.view.isHidden = false
                self.UserSearchVC.searchUsers(searchText: searchText)
                
            case SearchMode.posts:
                //print("search video.. ")
                
                // introduce autocomplete vc to show keywords
                PostSearchVC.view.isHidden = false
                //self.PostSearchVC.searchKeywords(searchText: searchText)
               
                
                
            case SearchMode.hashTags:
                //print("search hashtag...")
                HashtagSearchVC.view.isHidden = false
                self.HashtagSearchVC.searchHashtags(searchText: searchText)
            }
        }
        
    }
    
    func hideTableOnEmptySearchText(){
        switch selectedSearchMode {
        case SearchMode.users:
            UserSearchVC.view.isHidden = true
            UserSearchVC.searchUserList.removeAll()
            UserSearchVC.tableNode.reloadData(completion: nil)
        case SearchMode.posts:
            PostSearchVC.view.isHidden = true
            //PostSearchVC.searchKeywordList.removeAll()
            //PostSearchVC.tableNode.reloadData(completion: nil)
        case SearchMode.hashTags:
            HashtagSearchVC.view.isHidden = true
            //HashtagSearchVC.searchHashtagList.removeAll()
            //HashtagSearchVC.tableNode.reloadData(completion: nil)
        }
    }
}

extension MainSearchVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    func setupLayers() {
        
        userBorder = userBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        postBorder = postBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        hashTagBorder = hashtagBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        self.navigationItem.title = "Search"
       
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
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for anything", attributes: [.foregroundColor: UIColor.lightGray])
        
        if currentSearchText != "" {
            
            self.searchController!.searchBar.text = currentSearchText
            
        }
    
    }

    
}

extension MainSearchVC {
    
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

extension MainSearchVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func closeKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    
    }

    
}

extension MainSearchVC {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        contentView.isHidden = false
        searchView.isHidden = true
        
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            contentView.isHidden = false
            searchView.isHidden = true
        } else {
            contentView.isHidden = true
            searchView.isHidden = false
            
            delayItem.perform(after: 0.35) {
                
                self.search(for: searchText)
                
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("default searching user with: \(searchBar.text)")
        
    }

    func search(for searchText: String) {
        
        APIManager().getAutoComplete(query: searchText) { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
}

