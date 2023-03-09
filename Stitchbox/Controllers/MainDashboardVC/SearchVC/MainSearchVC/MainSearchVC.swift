//
//  MainSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit

class MainSearchVC: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [UserSearchModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()
    
    enum SearchMode {
        case users
        case posts
        case hashTags
    }

    var searchTableNode: ASTableNode!
    var searchType = ""
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
        setupTableNode()
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
        
        searchType = initialType
        
    }
    

    
    @IBAction func userBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.users)
        userBtn.setTitleColor(UIColor.white, for: .normal)
        postBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        searchType = "user"
        
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.posts)
        postBtn.setTitleColor(UIColor.white, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        searchType = "post"
        
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.hashTags)
        hashtagBtn.setTitleColor(UIColor.white, for: .normal)
        postBtn.setTitleColor(UIColor.lightGray, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        searchType = "hashtag"
        
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
               
               
                UserSearchVC.view.isHidden = false
                UserSearchVC.searchUsers(for: searchText)
                
            case SearchMode.posts:
                
                PostSearchVC.view.isHidden = false
                PostSearchVC.keyword = searchText
                PostSearchVC.page = 1
                PostSearchVC.searchRequest()
                
                
            case SearchMode.hashTags:
               
                
                HashtagSearchVC.view.isHidden = false
                HashtagSearchVC.searchHashtags(searchText: searchText)
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
            PostSearchVC.post_list.removeAll()
            PostSearchVC.collectionNode.reloadData()
        case SearchMode.hashTags:
            HashtagSearchVC.view.isHidden = true
            HashtagSearchVC.searchHashtagList.removeAll()
            HashtagSearchVC.tableNode.reloadData(completion: nil)
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
            searchText = currentSearchText
        }
    
    }
    
    func setupTableNode() {
        
        self.searchTableNode = ASTableNode(style: .plain)
        searchView.addSubview(searchTableNode.view)
        
        self.searchTableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.searchTableNode.automaticallyAdjustsContentOffset = true
        self.searchTableNode.view.backgroundColor = self.view.backgroundColor
        
        self.searchTableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.searchTableNode.view.topAnchor.constraint(equalTo: self.searchView.topAnchor, constant: 0).isActive = true
        self.searchTableNode.view.leadingAnchor.constraint(equalTo: self.searchView.leadingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.trailingAnchor.constraint(equalTo: self.searchView.trailingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.bottomAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: -235).isActive = true
        
        self.searchTableNode.delegate = self
        self.searchTableNode.dataSource = self
        
        self.applyStyle()
        
    }
    
    
    func applyStyle() {
        
        self.searchTableNode.view.separatorStyle = .none
        self.searchTableNode.view.separatorColor = UIColor.lightGray
        self.searchTableNode.view.isPagingEnabled = false
        self.searchTableNode.view.backgroundColor = UIColor.clear
        self.searchTableNode.view.showsVerticalScrollIndicator = false
        
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


extension MainSearchVC: ASTableDataSource, ASTableDelegate {
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return searchList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let item = searchList[indexPath.row]
        return {
            let node = UserSearchNode(with: item)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            return node
        }
    }

    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let item = searchList[indexPath.row]
        saveRecentUser(userId: item.userId)
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            UPVC.userId = item.userId
            UPVC.nickname = item.user_nickname
        
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
        
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
        
        
        if let text = searchBar.text {
            
            saveRecentText(text: text)
            self.searchText = text
            self.sendSearchRequestToTargetVC()
            
            contentView.isHidden = false
            searchView.isHidden = true
            
        }
        
        

    }

    func search(for searchText: String) {
        
        //check local result first
        if checkLocalRecords(searchText: searchText){
            return
        }
        
        APIManager().getAutoComplete(query: searchText) { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                if !data.isEmpty {
                    
                    var newSearchList = [UserSearchModel]()
                    
                    for item in data {
                        newSearchList.append(UserSearchModel(UserSearchModel: item))
                    }
                    
                    let newSearchRecord = SearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchList)
                    self.searchHist.append(newSearchRecord)
                    
                    if self.searchList != newSearchList {
                        self.searchList = newSearchList
                        DispatchQueue.main.async {
                            self.searchTableNode.reloadData()
                        }
                    }
                    
                }
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
    func checkLocalRecords(searchText: String) -> Bool {
       
        for (i, record) in searchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    let retrievedSearchList = record.items
                    
                    if self.searchList != retrievedSearchList {
                        self.searchList = retrievedSearchList
                        DispatchQueue.main.async {
                            self.searchTableNode.reloadData(completion: nil)
                        }
                    }
                    return true
                } else {

                    searchHist.remove(at: i)
                }
            }
        }

        return false
    }
    
}


extension MainSearchVC {
    
    func saveRecentUser(userId: String) {
        
        APIManager().addRecent(query: userId, type: "user") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
    
    func saveRecentText(text: String) {
        
        APIManager().addRecent(query: text, type: "text") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
}
