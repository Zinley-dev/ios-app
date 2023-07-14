//
//  FollowingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit
import RxSwift

class FollowingVC: UIViewController {
    
    deinit {
        print("FollowingVC is being deallocated.")
    }
    
    @IBOutlet weak var contentView: UIView!
    private var currPage = 1
    
    var inSearchMode = false
    var tableNode: ASTableNode!
    var searchUserList = [FollowModel]()
    var userList = [FollowModel]()
    var userId = ""
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableNode()
        // Do any additional setup after loading the view.
        
    }
    
}

extension FollowingVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
}

extension FollowingVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { [weak self] (newFollowings) in
            guard let self = self else { return }
            self.insertNewRowsInTableNode(newFollowings: newFollowings)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        if user.userId != _AppCoreData.userDataSource.value?.userID {
            
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                //self.hidesBottomBarWhenPushed = true
                UPVC.userId = user.userId
                UPVC.nickname = user.username
                self.navigationController?.pushViewController(UPVC, animated: true)
                
            }
            
            
        }
        
    }
    
}

extension FollowingVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        let array = inSearchMode ? searchUserList : userList
        
        
        if array.count == 0 {
            
            tableNode.view.setEmptyMessage("No following")
            
        } else {
            tableNode.view.restore()
        }
        
        return array.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        if let myId = _AppCoreData.userDataSource.value?.userID {
            
            if myId == self.userId {
                user.action = "following"
                user.needCheck = false
            }
        }
        
        user.loadFromMode = "following"
        user.loadFromUserId = self.userId
        
        return {
            var node: FollowNode!
            node = FollowNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            return node
        }
        
    }
    
    
    
}

extension FollowingVC {
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
}

extension FollowingVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getFollows(userId: userId, page: currPage) { [weak self] result in
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
                    self.currPage += 1
                    print("Successfully retrieved \(data.count) followings.")
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
    
    func insertNewRowsInTableNode(newFollowings: [[String: Any]]) {
        // Check if there are new posts to insert
        guard !newFollowings.isEmpty else { return }
        
        
        // Calculate the range of new rows
        let startIndex = userList.count
        let endIndex = startIndex + newFollowings.count
        
        // Create an array of PostModel objects
        let newItems = newFollowings.compactMap { FollowModel(JSON: $0) }
        
        // Append the new items to the existing array
        userList.append(contentsOf: newItems)
        
        // Create an array of index paths for the new rows
        let insertIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        
        // Insert the new rows
        tableNode.insertRows(at: insertIndexPaths, with: .automatic)
        
    }
    
}
