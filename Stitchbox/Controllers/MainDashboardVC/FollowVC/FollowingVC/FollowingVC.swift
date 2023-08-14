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
    
    var refresh_request = false
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableNode()
        // Do any additional setup after loading the view.
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
        
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
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
                    self.currPage += 1
                    DispatchQueue.main.async {
                        block(data)
                    }
                } else {
                    self.completeWithEmptyData(block)
                }
            case .failure(let error):
                print(error)
                self.completeWithEmptyData(block)
            }
        }
    }

    private func completeWithEmptyData(_ block: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            block([])
        }
    }

    func insertNewRowsInTableNode(newFollowings: [[String: Any]]) {
        guard newFollowings.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newFollowings.compactMap { FollowModel(JSON: $0) }.filter { !self.userList.contains($0) }
        self.userList.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        let deleteIndexPaths = userList.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        userList.removeAll()
        tableNode.deleteRows(at: deleteIndexPaths, with: .automatic)
    }

    private func generateIndexPaths(for items: [FollowModel]) -> [IndexPath] {
        let startIndex = self.userList.count - items.count
        return (startIndex..<self.userList.count).map { IndexPath(row: $0, section: 0) }
    }
    
}

extension FollowingVC {
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    @objc func clearAllData() {
        
        refresh_request = true
        currPage = 1
        updateData()
        
    }
    
    
    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newFollowings) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newFollowings.isEmpty {
                self.refresh_request = false
                self.userList.removeAll()
                self.tableNode.reloadData()
                if self.userList.isEmpty {
                    self.tableNode.view.setEmptyMessage("No following!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newFollowings: newFollowings)
            }
        }
    }
    
    
}
