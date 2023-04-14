//
//  RiotSyncVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage

class RiotSyncVC: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate {
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [UserSearchModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()
    var regionList = [RegionModel]()

    //@IBOutlet weak var contentview: UIView!
   
    
    var searchController: UISearchController?
    var searchList = [UserSearchModel]()
    var searchTableNode: ASTableNode!
    lazy var delayItem = workItem()
   
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        setupButtons()
        setupSearchController()
        setupTableNode()
        loadRegion()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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


extension RiotSyncVC {
    
    func setupSearchController() {
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search by your LOL username", attributes: [.foregroundColor: UIColor.lightGray])
        
    }
    
}


extension RiotSyncVC {
    
    func setupButtons() {
        self.navigationItem.title = "Sync Riot Account"
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
        
        

    }
    
    
    func applyStyle() {
        
        self.searchTableNode.view.separatorStyle = .none
        self.searchTableNode.view.separatorColor = UIColor.lightGray
        self.searchTableNode.view.isPagingEnabled = false
        self.searchTableNode.view.backgroundColor = UIColor.clear
        self.searchTableNode.view.showsVerticalScrollIndicator = false
        
    }

}

extension RiotSyncVC: ASTableDataSource, ASTableDelegate {
    
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
        if tableNode == searchTableNode {
            
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
        

        
    }
    
    
}



extension RiotSyncVC {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        

    }
    

    func search(for searchText: String) {
        

        
    }
    
    func checkLocalRecords(searchText: String) -> Bool {
       
        return false
    }
    
 
}

extension RiotSyncVC {
    
    func loadRegion() {
        
            APIManager().getSupportedRegion { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        return
                    }
                    
                    print(data)
                    
                case .failure(let error):
                    print(error)
                  
            }
        }
        
        
    }
    
}
