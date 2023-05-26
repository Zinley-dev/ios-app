//
//  SearchViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 29/12/2022.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage

class SearchViewController: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate {
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [UserSearchModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    var searchController: UISearchController?
    var recentList = [RecentModel]()
    var searchList = [UserSearchModel]()
    var recentTableNode: ASTableNode!
    var searchTableNode: ASTableNode!
    lazy var delayItem = workItem()
    var firstLoad = true
    var firstAnimated = true
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        setupButtons()
        setupSearchController()
        setupTableNode()
        loadRecentSearch()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLoad {
            
            firstLoad = false
            
            do {
                
                let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                let gifData = try NSData(contentsOfFile: path) as Data
                let image = FLAnimatedImage(animatedGIFData: gifData)
                
                
                self.loadingImage.animatedImage = image
                
            } catch {
                print(error.localizedDescription)
            }
            
            loadingView.backgroundColor = self.view.backgroundColor
            
        }
       
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    
}

extension SearchViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView == recentTableNode.view {
            
            let item = recentList[indexPath.row]
            
            if item.type != "game" {
                
                let size = recentTableNode.view.visibleCells[0].frame.height
                let iconSize: CGFloat = 35.0
                
                let removeAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    let objectId = self.recentList[indexPath.row].objectId
                    self.removeRecent(objectId: objectId ?? "" , row: indexPath.row)
                    actionHandler(true)
                }
                
                let removeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                //removeView.layer.borderColor = UIColor.white.cgColor
                removeView.layer.masksToBounds = true
                //removeView.layer.borderWidth = 1
                removeView.layer.cornerRadius = iconSize/2
                removeView.backgroundColor =  .secondary
                removeView.image = xBtn
                removeView.contentMode = .center
                
                removeAction.image = removeView.asImage()
                removeAction.backgroundColor = .background
               
                
                return UISwipeActionsConfiguration(actions: [removeAction])
                
                
            } else {
                return nil
            }
            
            
        } else {
            return nil
        }

    }
    
}

extension SearchViewController {
    
    func loadRecentSearch() {
        
        APIManager.shared.getRecent { result in
            switch result {
            case .success(let apiResponse):

                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    
                    return
                }
                

                if !data.isEmpty {
                    
                    for item in data {
                        
                        let item = RecentModel(RecentModel: item)
                        self.recentList.append(item)
                        
                    }
                    
                }
                
                self.getCurrentSupportGame()
                
            case .failure(let error):
                self.getCurrentSupportGame()
                print(error)
               
            }
        }
    
        
    }
    
    func getCurrentSupportGame() {
        
        if !global_suppport_game_list.isEmpty {
            
            for item in global_suppport_game_list {
                
                if item.name != "Other" {
                    
                    let newCustom = ["coverUrl": item.cover, "game_name": item.name, "game_shortName": item.shortName, "type": "game"]
                    
                    let item = RecentModel(RecentModel: newCustom)
                    self.recentList.append(item)
                    
                }
            
            }
           
            if !recentList.isEmpty {
                
                DispatchQueue.main.async {
                    self.hideAnimation()
                    self.recentTableNode.reloadData()
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    self.hideAnimation()
                }
            }
            
        }
      
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
        
    }
    
}

extension SearchViewController: UINavigationBarDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


extension SearchViewController {
    
    func setupButtons() {
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.title = "Search"
        setupBackButton()
    }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
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
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
    func setupTableNode() {
        
        
        self.recentTableNode = ASTableNode(style: .plain)
        contentview.addSubview(recentTableNode.view)
        
    
        self.recentTableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.recentTableNode.automaticallyAdjustsContentOffset = true
        self.recentTableNode.view.backgroundColor = self.view.backgroundColor
        
        
        self.recentTableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.recentTableNode.view.topAnchor.constraint(equalTo: self.contentview.topAnchor, constant: 0).isActive = true
        self.recentTableNode.view.leadingAnchor.constraint(equalTo: self.contentview.leadingAnchor, constant: 0).isActive = true
        self.recentTableNode.view.trailingAnchor.constraint(equalTo: self.contentview.trailingAnchor, constant: 0).isActive = true
        self.recentTableNode.view.bottomAnchor.constraint(equalTo: self.contentview.bottomAnchor, constant: 0).isActive = true
        
        self.searchTableNode = ASTableNode(style: .plain)
        searchView.addSubview(searchTableNode.view)
        
        self.searchTableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.searchTableNode.automaticallyAdjustsContentOffset = true
        self.searchTableNode.view.backgroundColor = self.view.backgroundColor
        
        self.searchTableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.searchTableNode.view.topAnchor.constraint(equalTo: self.searchView.topAnchor, constant: 0).isActive = true
        self.searchTableNode.view.leadingAnchor.constraint(equalTo: self.searchView.leadingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.trailingAnchor.constraint(equalTo: self.searchView.trailingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.bottomAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: -300).isActive = true
        
        self.recentTableNode.delegate = self
        self.searchTableNode.delegate = self
        self.recentTableNode.dataSource = self
        self.searchTableNode.dataSource = self
        
        self.applyStyle()
        
    }
    
    
    func applyStyle() {
        
        self.recentTableNode.view.separatorStyle = .none
        self.recentTableNode.view.separatorColor = UIColor.lightGray
        self.recentTableNode.view.isPagingEnabled = false
        self.recentTableNode.view.backgroundColor = UIColor.clear
        self.recentTableNode.view.showsVerticalScrollIndicator = false
        
        
        self.searchTableNode.view.separatorStyle = .none
        self.searchTableNode.view.separatorColor = UIColor.lightGray
        self.searchTableNode.view.isPagingEnabled = false
        self.searchTableNode.view.backgroundColor = UIColor.clear
        self.searchTableNode.view.showsVerticalScrollIndicator = false
        
    }

}

extension SearchViewController: ASTableDataSource, ASTableDelegate {
    
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
        
        if tableNode == recentTableNode {
            return recentList.count
        } else if tableNode == searchTableNode {
            return searchList.count
        } else {
            return 0
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if tableNode == recentTableNode {
            let item = recentList[indexPath.row]
            return {
                let node = RecentNode(with: item)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                return node
            }
        } else if tableNode == searchTableNode {
            
            let item = searchList[indexPath.row]
            return {
                let node = UserSearchNode(with: item)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                return node
            }
            
        } else {
            return { ASCellNode() }
        }
    }

    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        if tableNode == recentTableNode {
            
            let item = recentList[indexPath.row]
            
            if item.type == "game" {
                
                if let MSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainSearchVC") as? MainSearchVC {
                    
                    MSVC.initialType = "post"
                    MSVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    MSVC.currentSearchText = item.game_shortName
                    self.navigationController?.pushViewController(MSVC, animated: true)
                    
                }
                
            } else if item.type == "user" {
                
                saveRecentUser(userId: item.userId)
                
                if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                    //self.hidesBottomBarWhenPushed = true
                    UPVC.userId = item.userId
                    UPVC.nickname = item.user_nickname
                    UPVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    self.navigationController?.pushViewController(UPVC, animated: true)
                    
                }
                
            } else if item.type == "text" {
                
                if let MSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainSearchVC") as? MainSearchVC {
                    
                    MSVC.initialType = "post"
                    MSVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    MSVC.currentSearchText = item.text
                    self.navigationController?.pushViewController(MSVC, animated: true)
                    
                }
                
            }
            
            
        } else if tableNode == searchTableNode {
            
            let item = searchList[indexPath.row]
            saveRecentUser(userId: item.userId)
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                UPVC.userId = item.userId
                UPVC.nickname = item.user_nickname
                UPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(UPVC, animated: true)
                
            }
            
        }
        
        
    }
    
    
}



extension SearchViewController {
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        contentview.isHidden = false
        searchView.isHidden = true
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            contentview.isHidden = false
            searchView.isHidden = true
        } else {
            contentview.isHidden = true
            searchView.isHidden = false
            
            delayItem.perform(after: 0.35) {
                
                self.search(for: searchText)
                
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text, text != "" {
            
            saveRecentText(text: text)
            
            if let MSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainSearchVC") as? MainSearchVC {
                
                MSVC.initialType = "user"
                MSVC.hidesBottomBarWhenPushed = true
                MSVC.currentSearchText = text
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(MSVC, animated: true)
                
            }
            
        }
        
        
        
    }

    func search(for searchText: String) {
        
        //check local result first
        if checkLocalRecords(searchText: searchText){
            return
        }
        
        APIManager.shared.getAutoComplete(query: searchText) { result in
            switch result {
            case .success(let apiResponse):
                

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

extension SearchViewController {
    
    func saveRecentUser(userId: String) {
        
        APIManager.shared.addRecent(query: userId, type: "user") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
    
    func saveRecentText(text: String) {
        
        APIManager.shared.addRecent(query: text, type: "text") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
    func removeRecent(objectId: String, row: Int) {

        if objectId != "" {
        
            APIManager.shared.deleteRecent(id: objectId) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.recentList.remove(at: row)
                        self.recentTableNode.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                        showNote(text: "Search removed!")
                    }
                   
                case .failure(_):
                    DispatchQueue.main.async {
                        showNote(text: "Unable to remove recent!")
                    }
                    
                }
            }

        }
        
    }
    
    
    func hideAnimation() {
        
        if firstAnimated {
                    
                    firstAnimated = false
                    
                    UIView.animate(withDuration: 0.5) {
                        
                        Dispatch.main.async {
                            self.loadingView.alpha = 0
                        }
                        
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        if self.loadingView.alpha == 0 {
                            
                            self.loadingView.isHidden = true
                            
                        }
                        
                    }
                    
                    
                }
        
    }
    
}
