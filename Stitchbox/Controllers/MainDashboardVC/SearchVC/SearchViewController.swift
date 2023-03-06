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
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        setupButtons()
        setupSearchController()
        setupTableNode()
        loadRecentSearch()
        
        
        recentTableNode.isHidden = false
        searchTableNode.isHidden = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMiddleBtn(vc: self)
        
        
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
       
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    
}

extension SearchViewController {
    
    func loadRecentSearch() {
        
        APIManager().getRecent { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                if !data.isEmpty {
                    
                    for item in data {
                        
                        let item = RecentModel(type: "user", RecentModel: item)
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
                    
                    let newCustom = ["coverUrl": item.cover, "game_name": item.name, "game_shortName": item.shortName]
                    
                    let item = RecentModel(type: "game", RecentModel: newCustom)
                    self.recentList.append(item)
                    
                }
            
            }
           
            if !recentList.isEmpty {
                
                DispatchQueue.main.async {
                    self.recentTableNode.reloadData()
                    
                }
                
            }
            
            delay(0.25) {
                
                UIView.animate(withDuration: 0.5) {
                    
                    DispatchQueue.main.async {
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
        
        //definesPresentationContext = true
        
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
        self.searchTableNode.view.bottomAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: 0).isActive = true
        
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
                    MSVC.currentSearchText = item.game_name
                    self.navigationController?.pushViewController(MSVC, animated: true)
                    
                }
                
            } else if item.type == "user" {
                
                
                if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                    //self.hidesBottomBarWhenPushed = true
                    UPVC.userId = item.userId
                    UPVC.nickname = item.user_nickname
                    UPVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    self.navigationController?.pushViewController(UPVC, animated: true)
                    
                }
                
            }
            
            
        } else if tableNode == searchTableNode {
            
            
            
            
        }
        
        
    }
    
    
}



extension SearchViewController {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
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
        
        if let MSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainSearchVC") as? MainSearchVC {
            
            MSVC.initialType = "user"
            MSVC.hidesBottomBarWhenPushed = true
            MSVC.currentSearchText = searchBar.text ?? ""
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(MSVC, animated: true)
            
        }
        
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
