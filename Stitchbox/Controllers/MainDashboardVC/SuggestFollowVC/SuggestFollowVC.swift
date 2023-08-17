//
//  SuggestFollowVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class SuggestFollowVC: UIViewController {

    private var currPage = 1
    var userList = [FriendSuggestionModel]()
    @IBOutlet weak var contentView: UIView!
    var tableNode: ASTableNode!
  
    var refresh_request = false
    private var pullControl = UIRefreshControl()
    lazy var delayItem = workItem()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //must happen before setting up tablenode otherwise data is not enough to render
        setupTableNode()
        // Do any additional setup after loading the view.
        
    }


}


extension SuggestFollowVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
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
    
    @IBAction func findFriendsBtn(_ sender: Any) {
        
        if let FFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FindFriendsVC") as? FindFriendsVC {
            hideMiddleBtn(vc: self)
            FFVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(FFVC, animated: true)
            
        }
    }
    
}

extension SuggestFollowVC: ASTableDelegate {
    
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
        
        self.retrieveNextPageWithCompletion { [weak self] (newFollowers) in
            guard let self = self else { return }
            self.insertNewRowsInTableNode(newUsers: newFollowers)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = userList[indexPath.row]
        
        if user.userId != _AppCoreData.userDataSource.value?.userID {
            
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                //self.hidesBottomBarWhenPushed = true
                UPVC.userId = user.userId
                UPVC.nickname = user.username
                UPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(UPVC, animated: true)
                
            }
            
        }
        
        
    }
    
}

extension SuggestFollowVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        let array = userList
        
        
        if array.count == 0 {
            
            tableNode.view.setEmptyMessage("No suggestion found!")
            
        } else {
            tableNode.view.restore()
        }
        
        return array.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        //let array = inSearchMode ? searchChannelList : channels
        let user = userList[indexPath.row]
        
        return {
            var node: SuggestFollowNode!
            node = SuggestFollowNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            return node
        }
        
    }
    
    
}


extension SuggestFollowVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.suggestUser(page: currPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) users.")
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

    func insertNewRowsInTableNode(newUsers: [[String: Any]]) {
        guard newUsers.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newUsers.compactMap { FriendSuggestionModel(JSON: $0) }.filter { !self.userList.contains($0) }
        self.userList.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        userList.removeAll()
        tableNode.reloadData()
    }

    private func generateIndexPaths(for items: [FriendSuggestionModel]) -> [IndexPath] {
        let startIndex = self.userList.count - items.count
        return (startIndex..<self.userList.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newNotis) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newNotis.isEmpty {
                self.refresh_request = false
                self.userList.removeAll()
                self.tableNode.reloadData()
                if self.userList.isEmpty {
                    self.tableNode.view.setEmptyMessage("No suggestion found!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newUsers: newNotis)
            }
        }
        
    }

    @objc func clearAllData() {
      
        refresh_request = true
        currPage = 1
        updateData()
    }
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
}



